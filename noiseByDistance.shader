Shader "LX/NoiseByDistance"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ChangeSpeed("ChangeSpeed",float)=10
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float3 worldNormal:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _ChangeSpeed;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float simpleNoise(float2 uv)
            {
                return frac(sin(dot(uv, float2(50, 50))) * 43758.5453);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = i.worldNormal;
                float3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos); 
                float diffuse = saturate(dot(worldNormal, worldLightDir));
                fixed4 col = tex2D(_MainTex, i.uv) * diffuse;

                float distance=length(UnityWorldSpaceViewDir(i.worldPos));

                clip(-simpleNoise(i.uv)+distance/_ChangeSpeed);
                return col;
            }
            ENDCG
        }
    }
}