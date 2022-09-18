Shader "LX/SpotLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightDir ("LightDir", Vector) = (1,1,1,1)
        _LightPos ("LightPos", Vector) = (1,1,1,1)
        _LightRange ("LightRange", float) = 5
        _LightAngleRange ("LightAngleRange", float) = 50
        _Attenuation ("Attenuation", float) = 1
        _LightIntensity ("LightIntensity", float) = 2
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
                float4 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _LightDir;
            float3 _LightPos;
            float _LightRange;
            float _LightAngleRange;
            float _Attenuation;
            float _LightIntensity;

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
                float4 col = tex2D(_MainTex, i.uv);
                float3 worldLightDir = normalize(_LightPos-i.worldPos);
                float lightLength = length(_LightPos-i.worldPos );
                float3 worldNormal = normalize(i.worldNormal);
                float diffuse = saturate(dot(worldNormal, worldLightDir));
                float rangeAtt = 1 / (pow(lightLength, 2)*_Attenuation + 1) * saturate(pow(1-lightLength / _LightRange, 2));
                float angle = acos(saturate(dot(-worldLightDir, normalize(_LightDir)))) * 180 / UNITY_PI;
                float angleAtt = pow(saturate(dot(-worldLightDir, normalize(_LightDir))),10)* saturate(pow(1 - angle / _LightAngleRange, 2))*_Attenuation;
                return col * diffuse*rangeAtt*_LightIntensity*angleAtt;
            }
            ENDCG
        }
    }
}