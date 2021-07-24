Shader "LX/refraction"
{
    Properties
    {
        _RefractScale("Refract Scale",Float)=0
        _RefractRatio("Refraction Ratio",Float)=0
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

            float _RefractScale;
            float _RefractRatio;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float3 worldRefr:TEXCOORD0;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                float3 worldPos = mul(unity_ObjectToWorld, vertData.position).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(vertData.normal);
                o.worldRefr = normalize(refract(-UnityWorldSpaceViewDir(worldPos), worldNormal,_RefractRatio));
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 refractionColor = texCUBE(_Cubemap, i.worldRefr) * _RefractScale;
                return fixed4(refractionColor, 1.0);
            }
            ENDCG

        }
    }
}