Shader "LX/ImageBlockGlitch"
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
            int _RowCount;
            int _ColumnCount;
            int _RowCount2;
            int _ColumnCount2;
            float _Speed;
            float _Intensity;
            int _Pow;

            float simpleNoise(float seed)
            {
                return frac(sin(seed * 2114.442 + _Time.y * _Speed / 100+4546.112) * 6631.423);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float noise1 = simpleNoise(floor(i.uv.x * _ColumnCount) + floor(i.uv.y * _RowCount) * _ColumnCount);
                noise1 = pow(noise1, _Pow);
                float noise2 = simpleNoise(floor(i.uv.x * _ColumnCount2) + floor(i.uv.y * _RowCount2) * _ColumnCount2);
                noise2 = pow(noise2, _Pow);
                float noise=noise1*noise2;
                float colorR=tex2D(_MainTex, i.uv).r;
                float colorG=tex2D(_MainTex, i.uv + noise * _Intensity *_MainTex_TexelSize.xy).g;
                float colorB=tex2D(_MainTex, i.uv - noise * _Intensity *_MainTex_TexelSize.xy).b;
                return fixed4(colorR,colorG,colorB,1);
            }
            ENDCG
        }
    }
}