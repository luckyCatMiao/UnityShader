Shader "LX/RandomChannel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
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


            fixed simpleRandom(fixed2 uv)
            {
                return frac(sin(dot(uv,fixed2(42.3, 55.22)) * 1423.322 + 1523.333) * 2313.33);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float random = simpleRandom(i.uv+_Time.yy);
                fixed r = step(random, 0.33);
                fixed g = step(0.33, random) * step(random, 0.66);
                fixed b = step(0.66, random) * step(random, 1);
                
                return fixed4(col.r*r,col.g*g,col.b*b,1);
            }
            ENDCG
        }
    }
}