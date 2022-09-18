Shader "LX/LineLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightPos1 ("LightPos1", Vector) =(0,0,0,0)
        _LightPos2 ("LightPos2", Vector) =(0,0,0,0)
        _AttenuationStrength ("AttenuationStrength", float) =1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

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

            float3 _LightPos1; //light pos in world coordinate
            float3 _LightPos2;
            float _AttenuationStrength;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed GetAtt(float3 worldPos, float3 lightPos)
            {
                float3 reduce = worldPos - lightPos;
                fixed len = length(reduce);
                //fall off
                float lightRange = distance(_LightPos1, _LightPos2);
                return 1 / (pow(len, 2)*_AttenuationStrength + 1) * saturate(pow(1 - (len / lightRange), 2));
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed att1 = GetAtt(i.worldPos, _LightPos1);
                fixed att2 = GetAtt(i.worldPos, _LightPos2);

                fixed3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir1 = normalize(_LightPos1 - i.worldPos);
                fixed diffuse1 = att1 * saturate(dot(worldNormal, worldLightDir1));

                float3 worldLightDir2 = normalize(_LightPos2 - i.worldPos);
                fixed diffuse2 = att2 * saturate(dot(worldNormal, worldLightDir2));


                return (diffuse1 + diffuse2) * col;
            }
            ENDCG
        }
    }
}