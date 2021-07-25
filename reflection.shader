Shader "LX/reflection"
{
    Properties
    {
        _ReflectScale("Reflect Scale",Float)=1
        _ReflectAmount("Reflect Amount",Float)=0.5
        _Cubemap("Reflection Cubemap",Cube)="_Skybox"
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

            float _ReflectScale;
            float _ReflectAmount;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float3 worldRefl:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                float3 worldPos = mul(unity_ObjectToWorld, vertData.position).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(vertData.normal);
                o.worldRefl = normalize(reflect(-UnityWorldSpaceViewDir(worldPos), worldNormal));
                o.worldPos = worldPos;
                o.worldNormal = worldNormal;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
                fixed3 diffuse = dot(worldLightDir, i.worldNormal);
                fixed3 reflectColor = texCUBE(_Cubemap, i.worldRefl) * _ReflectScale;
                fixed3 finalColor = lerp(diffuse, reflectColor, _ReflectAmount);
                return fixed4(finalColor, 1.0);
            }
            ENDCG

        }
    }
}