//使用3个采样点，实际进行5个采样的基于gpu双线性插值的高斯模糊
Shader "LX/GaussianBlurBilinear2"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[3]: TEXCOORD0;
        };

        v2f vertBlurVertical(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;

            o.uv[0] = uv + float2(0, _MainTex_TexelSize.y * -1.087) * _BlurSize;
            o.uv[1] = uv;
            o.uv[2] = uv + float2(0, _MainTex_TexelSize.y * 1.087) * _BlurSize;;

            return o;
        }

        v2f vertBlurHorizontal(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;

            o.uv[0] = uv + float2(_MainTex_TexelSize.x * -1.087, 0) * _BlurSize;
            o.uv[1] = uv;
            o.uv[2] = uv + float2(_MainTex_TexelSize.x * 1.087, 0) * _BlurSize;;

            return o;
        }

        fixed4 fragBlur(v2f i) : SV_Target
        {
            float weight[3] = {
                0.2504,
                0.4992,
                0.2504
            };
            fixed3 sum = 0;
            for (int index = 0; index < 3; index++)
            {
                sum += tex2D(_MainTex, i.uv[index]).rgb * weight[index];
            }

            return fixed4(sum, 1);
        }

        struct VertexInput
        {
            float4 vertex : POSITION;
            half2 texcoord : TEXCOORD0;
        };


        struct VertexOutput_DownSmpl
        {
            float4 pos : SV_POSITION;
            half2 uv20 : TEXCOORD0;
            half2 uv21 : TEXCOORD1;
            half2 uv22 : TEXCOORD2;
            half2 uv23 : TEXCOORD3;
        };
        ENDCG

        ZTest Always Cull Off ZWrite Off

        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur
            ENDCG
        }

        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur
            ENDCG
        }
    }
    FallBack Off
}