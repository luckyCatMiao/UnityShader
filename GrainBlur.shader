Shader "LX/GrainBlur"
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
            float _Radius;
            int _Iteration;

            fixed4 extractBright(v2f i) : SV_Target
            {
                fixed4 col;
                for (int index = 0; index < _Iteration; index++)
                {
                    fixed2 noise=frac(sin(i.uv * 14223 * index));
                    fixed2 offset = noise.xy;
                    col += tex2D(_MainTex, i.uv + offset * _Radius * _MainTex_TexelSize.xy);
                }
                return col / _Iteration;
            }
            ENDCG
        }
    }
}