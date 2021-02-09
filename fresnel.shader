Shader "LX/fresnel"
{
    Properties
    {
        _FresnelScale("Fresnel Scale",float)=0.5
        _Cubemap("Refraction Cubemap",Cube)="refractCube"
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            float _FresnelScale;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldViewDir:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                float3 worldRefl:TEXCOORD3;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertData.position);
                o.worldPos = mul(unity_ObjectToWorld, vertData.position).xyz;
                o.worldNormal = normalize(UnityObjectToWorldNormal(vertData.normal));
                o.worldViewDir=normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.worldRefl=reflect(-o.worldViewDir,o.worldNormal);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 reflection=texCUBE(_Cubemap,i.worldRefl);
                fixed3 diffuse=_LightColor0.rgb*max(0,dot(i.worldNormal,i.worldViewDir));
                fixed fresnel=_FresnelScale+(1-_FresnelScale)*pow(1-dot(i.worldViewDir,i.worldNormal),5);
                fixed3 color=ambient+lerp(diffuse,reflection,saturate(fresnel));
                return fixed4(color, 1.0);
            }
            ENDCG

        }
    }
}