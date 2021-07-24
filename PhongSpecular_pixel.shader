Shader "LX/PhongSpecular_pixel"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
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
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPosition:TEXCOORD1;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                o.worldNormal=UnityObjectToWorldNormal(vertData.normal);
                o.worldPosition=mul(unity_ObjectToWorld,vertData.position);
             
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT;
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPosition));
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(i.worldNormal,worldLightDir));
                fixed3 reflectDir=normalize(reflect(-worldLightDir,i.worldNormal));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPosition));
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1);
            }
            
            ENDCG

        }
    }
}