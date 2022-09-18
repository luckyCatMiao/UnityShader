Shader "LX/PointLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightPos ("LightPos", Vector) = (1,1,1,1)
        _LightRange ("LightRange", float) = 5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _LightPos; //light pos in world coordinate
            float _LightRange;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 reduce = i.worldPos - _LightPos;
                fixed len = length(reduce);
                float3 dir = normalize(reduce);
                fixed diffuse = saturate(dot(dir, i.worldNormal));
                fixed4 col = tex2D(_MainTex, i.uv);

                //fall off type0
                fixed att0 = 1 / (pow(len, 2));

                //fall off type1
                fixed att1 = 1 / (pow(len, 2) + 1);

                //fall off type2
                fixed att2 = 1 / (pow(len, 2) + 1) * saturate(pow(1 - len / _LightRange, 2));

                return col * diffuse * att2;
            }
            ENDCG
        }
    }
}