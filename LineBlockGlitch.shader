Shader "LX/LineBlockGlitch"
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
            int _RowCount;
            int _RowCount2;
            int _RowCount3;
            float _Speed;
            int _Pow;
            float _Intensity;

            float simpleNoise(float seed)
            {
                return frac(sin(seed * 2134.44233 + _Time.y * _Speed / 100) * 6621.4423);
            }

            fixed4 extractBright(v2f i) : SV_Target
            {
                float noise = simpleNoise(floor(i.uv.y * _RowCount));
                float noise2 = simpleNoise(floor(i.uv.y * _RowCount2));
                float noise3 = simpleNoise(floor(i.uv.y * _RowCount3));
                noise=noise*noise2*noise3;
                noise=pow(noise,_Pow);

                float colorR=tex2D(_MainTex, i.uv).r;
                float colorG=tex2D(_MainTex, i.uv + noise * _Intensity *_MainTex_TexelSize.xy).g;
                float colorB=tex2D(_MainTex, i.uv - noise * _Intensity *_MainTex_TexelSize.xy).b;

                return fixed4(colorR, colorG, colorB, 1);
            }
            ENDCG
        }
    }
}