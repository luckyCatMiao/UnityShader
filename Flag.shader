Shader "LX/Flag"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR]_TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _wevalength ("wevalength", Float ) = 0.35
        _strength ("strength", Float ) = 2.5
        _frequency ("frequency", Float ) = 8
        _Soft ("Soft", Float ) = 1

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform float _wevalength;
            uniform float _frequency;
            uniform float _strength;
            uniform float _Soft;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv = v.uv;
                o.vertexColor = v.vertexColor;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float offset = sin(_frequency * _Time.g + (worldPos.x +_Soft * worldPos.y) * _wevalength) *_strength*v.uv.y ;
                v.vertex.y += offset;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR
            {
                float4 texColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv, _MainTex));
                float3 finalColor = texColor.rgb * _TintColor.rgb;
                float finalAlpha = texColor.a* _TintColor.a;
                return fixed4(finalColor, finalAlpha);
            }
            ENDCG
        }
    }
}