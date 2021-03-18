// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LX/cartoon2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampTex ("Texture", 2D) = "white" {}
        _OutLine ("OutLine",float)=1
        _OutLineColor("_OutLineColor",color)=(0,0,0,0)
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
            NAME "OUTLINE"
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _RampTex;

            float _OutLine;
            fixed4 _OutLineColor;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex + normalize(v.normal) * _OutLine);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(_OutLineColor);
            }
            ENDCG
        }




        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            Cull Back
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
                float4 objectVertex:TEXCOORD2;
                float3 worldLightDir:TEXCOORD3;
                float3 worldNormal:TEXCOORD4;
                float3 worldPos:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _RampTex;


            v2f vert(appdata v)
            {
                v2f o;
                o.objectVertex = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex + normalize(v.normal) * 0);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);

                o.worldLightDir = normalize(UnityWorldSpaceLightDir(mul(unity_ObjectToWorld, v.vertex)));
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture

                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldLightDir = i.worldLightDir;
                fixed3 worldNormal = i.worldNormal;
                fixed value = dot(worldNormal, worldLightDir) / 2 + 0.5;

                float3 diffuse = tex2D(_RampTex,fixed2(value, value)) * col * 0.6;
                //fixed3 diffuse = max(0, dot(worldLightDir, worldNormal)) * col;
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 specluar = pow(max(0, dot(viewDir, reflectDir)), 8) * col;

                specluar = step(0.5, specluar);
                return fixed4(diffuse + specluar, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}