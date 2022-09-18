Shader "LX/RGBNoise"
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
            float _NoiseIntensity;
            float _NoiseLerp;

            float simpleNoise(float seed)
            {
                return frac(sin(seed * 213214.44233 ) * 66321.4423);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed2 noise=fixed2(simpleNoise(i.uv.x),simpleNoise(i.uv.y));
                fixed noiseR =tex2D(_MainTex,frac(i.uv+(noise+_Time.x*0.1234)*_MainTex_TexelSize.xy*_NoiseIntensity)).r;
                fixed noiseG =tex2D(_MainTex,frac(i.uv+(noise-_Time.x*0.2144)*_MainTex_TexelSize.xy*_NoiseIntensity)).g;
                fixed noiseB =tex2D(_MainTex,frac(i.uv+(noise+_Time.x*0.3534)*_MainTex_TexelSize.xy*_NoiseIntensity)).b;

                return col * (1 - _NoiseLerp) + _NoiseLerp *fixed4(noiseR,noiseG,noiseB,1);
            }
            ENDCG
        }
    }
}