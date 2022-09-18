Shader "LX/TwistedFull"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Opacity ("Opacity", Float ) = 0
        _Intensity ("Intensity", Range(0, 1)) = 0
        _Rotator ("Rotator", Float ) = 0
        _Mask ("Mask", 2D) = "white" {}

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
        [Enum(ColorMaskFull)] _ColorMask ("ColorMask", Float) = 15
    }
    SubShader
    {
        Tags
        {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        GrabPass{}
        
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ColorMask [_ColorMask]
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0
            uniform sampler2D _GrabTexture;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Opacity;
            uniform float _Intensity;
            uniform float _Rotator;
            uniform sampler2D _Mask;
            uniform float4 _Mask_ST;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                float4 projPos : TEXCOORD3;
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv = v.uv;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.projPos = ComputeScreenPos(o.pos);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR
            {
                float cosAngle = cos(_Time.y * _Rotator);
                float sinAngle = sin(_Time.y * _Rotator);
                float2 uvCenter = float2(0.5, 0.5);
                float2 rotatedUV = mul(i.uv, float2x2(cosAngle, -sinAngle, sinAngle, cosAngle)) + uvCenter; //uv旋转

                float4 texColor = tex2D(_MainTex,TRANSFORM_TEX(rotatedUV, _MainTex));
                 
                float4 maskColor = tex2D(_Mask,TRANSFORM_TEX(i.uv, _Mask));
                float2 sceneUVs = i.projPos.xy / i.projPos.w + float2(texColor.r, texColor.g) * texColor.a * _Intensity*  maskColor.a;
                float3 finalColor = tex2D(_GrabTexture, sceneUVs).rgb;
                finalColor=lerp(finalColor.rgb, 0,_Opacity);
                return fixed4(finalColor, maskColor.a);
            }
            ENDCG
        }
    }
}