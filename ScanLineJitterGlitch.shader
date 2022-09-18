Shader "LX/ScanLineJitterGlitch"
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
            #pragma fragment frag

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
            float _Intensity;
            float _Threshold;


            float simpleNoise(float seed)
            {
                return frac(sin(seed * 213214.44233) * 66321.4423);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float noise = simpleNoise(i.uv.y + _Time.x);
                noise *= step(_Threshold,noise)* _Intensity;
                fixed4 col = tex2D(_MainTex, frac(i.uv + fixed2(noise, 0) * _MainTex_TexelSize.xy));
                return col;
            }
            ENDCG
        }
    }
}