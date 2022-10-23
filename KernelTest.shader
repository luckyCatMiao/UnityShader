Shader "LX/KernelTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment extractBright

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            fixed4 extractBright(v2f i) : SV_Target
            {
                fixed4 col;
                float kernel[] =
                {
                    1, 1, 1,
                    1, 1, 1,
                    1, 1, 1
                };

                float weight = 0;
                for (int y = 0; y < 3; y++)
                {
                    for (int x = 0; x < 3; x++)
                    {
                        col += kernel[y * 3 + x] * tex2D(_MainTex, i.uv + _MainTex_TexelSize * fixed2(x - 1, y - 1));
                        weight += kernel[y * 3 + x];
                    }
                }

                return col / weight;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment extractBright

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _Tex;
            sampler2D _MainTex;
            float _Lerp;

            fixed4 extractBright(v2f i) : SV_Target
            {
                return lerp(tex2D(_MainTex, i.uv), tex2D(_Tex, i.uv), _Lerp);
            }
            ENDCG
        }

    }
}