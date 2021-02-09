Shader "LX/reflection"
{
    Properties
    {
        _ReflectScale("Reflect Scale",Float)=0
        _Cubemap("Reflection Cubemap",Cube)="reflecCube"
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
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                float3 worldPos = mul(unity_ObjectToWorld, vertData.position).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(vertData.normal);
                o.worldRefl = normalize(reflect(-UnityWorldSpaceViewDir(worldPos), worldNormal));
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 reflectColor = texCUBE(_Cubemap, i.worldRefl) * _ReflectScale;
                return fixed4(reflectColor, 1.0);
            }
            ENDCG

        }
    }
}