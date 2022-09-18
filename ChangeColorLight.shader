Shader "LX/ChangeColorLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColorTex ("LightColorTex", 2D) = "white" {}
        _MaxLightLength ("MaxLightLength", float) = 10
        _LightPos ("LightPos", Vector) = (0,0,0)
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _LightColorTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float3 _LightPos;
            float _MaxLightLength;


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
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
                fixed diffuse = saturate(dot(normalize(i.worldNormal), worldLightDir));
                fixed lightLength = length(_LightPos - i.worldPos);
                fixed uv = fixed2(saturate(lightLength / _MaxLightLength),saturate(lightLength / _MaxLightLength));
                return col * diffuse * tex2D(_LightColorTex, uv);
            }
            ENDCG
        }
    }
}