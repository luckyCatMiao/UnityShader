Shader "LX/PhongSpecular_vertex"
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
                float4 pos:SV_POSITION;
                fixed3 color:COLOR;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertData.position);
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal=normalize(mul(unity_ObjectToWorld,vertData.normal));
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));
                
                fixed3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));
                fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,vertData.position).xyz);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                o.color=ambient+diffuse+specular;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                return fixed4(i.color,1);
            }
            
            ENDCG

        }
    }
}