Shader "LX/RotationFull"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR]_TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _Speed ("Speed", Float ) = 0
        [MaterialToggle] _Mask ("Mask", Float ) = 1

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
            uniform float _Speed;
            uniform fixed _Mask;

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
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR
            {
                float cosSpeed = cos(_Time.y * _Speed);
                float sinSpeed = sin(_Time.y * _Speed);
                float2x2 rotateMatrix = float2x2(float2(cosSpeed, sinSpeed),
                                                 float2(-sinSpeed, cosSpeed));
                float2 uvCenter = float2(0.5, 0.5);
                float2 newUV = mul(rotateMatrix, i.uv - uvCenter) + uvCenter; //左乘旋转矩阵

                float4 texColor = tex2D(_MainTex,TRANSFORM_TEX(newUV, _MainTex));
                float3 finalColor = texColor.rgb * i.vertexColor.rgb * _TintColor.rgb;
                fixed distanceFromCenter = distance(uvCenter, newUV); //uv距离中心点的距离
                fixed mask = lerp(1.0, saturate((1.0 - distanceFromCenter) * 6.0 - 3.0), _Mask);
                //如果开启mask,则距离中心点较远的uv采样到的点不可见
                float finalAlpha = texColor.a * _TintColor.a * mask;

               return fixed4(finalColor, finalAlpha);
            }
            ENDCG
        }
    }
}