Shader "LX/extrusion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed",float)=1
        _Length("Length",float)=1
        _WaveLength("WaveLength",float)=1
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
            float _Speed;
            float _Length;
            float _WaveLength;


            v2f vert(appdata v)
            {
                v2f o;
                v.vertex.xyz = v.vertex.xyz + v.normal * max(sin((_Time.x + v.vertex.y*_WaveLength) * _Speed) *_Length,0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = i.worldNormal;
                float3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
                float diffuse = saturate(dot(worldNormal, worldLightDir));
                fixed4 col = tex2D(_MainTex, i.uv) * diffuse;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}