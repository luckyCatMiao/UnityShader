Shader "LX/receiveShadow"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
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
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            fixed4 _Diffuse;
            float _Gloss;

            struct a2v
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPosition:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v a)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(a.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(a.normal));
                o.worldPosition = mul(unity_ObjectToWorld, a.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f v):SV_Target
            {
                fixed shadow =SHADOW_ATTENUATION(v);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(v.worldPosition));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                fixed3 diffuse = _LightColor0.rgb * saturate(dot(v.worldNormal, worldLightDir));
                return fixed4(ambient + diffuse*shadow, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}