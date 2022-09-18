Shader "LX/SphereBlur"
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
            int _Radius;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col;
                float totalWeight = 0;
                for (int y = -_Radius; y <= _Radius; y++)
                {
                    for (int x = -_Radius; x <= _Radius; x++)
                    {
                        float2 uv = i.uv + _MainTex_TexelSize * fixed2(x, y);
                        float dis = distance(float2(x, y), 0);
                        float inRange = step(dis, _Radius);

                        float weight = pow((float)1/(1+dis),2);
                        col += tex2D(_MainTex, uv) * inRange * weight;
                        totalWeight += inRange * weight;
                    }
                }

                return col / totalWeight;
            }
            ENDCG
        }
    }
}