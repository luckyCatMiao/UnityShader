Shader "LX/RadialBlur"
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
            int _Iteration;
            float _Radius;
            float4 _Center;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col;
                float totalWeight = 0;
                fixed2 direction = i.uv - _Center.xy;
                for (int index = 0; index < _Iteration; index++)
                {
                    float2 newUV = i.uv + direction * index * _MainTex_TexelSize.xy * _Radius;
                    float singleWeight = 1 - dot(direction.x, direction.y);
                    col += tex2D(_MainTex, newUV) * singleWeight;
                    totalWeight += singleWeight;
                }
                return col / totalWeight;
            }
            ENDCG
        }
    }
}