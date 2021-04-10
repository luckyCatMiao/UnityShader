Shader "LX/cartoon2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampTex ("Texture", 2D) = "white" {}
        _RampColor("RampColor",color)=(0.6,0.6,0.6,1)
        _OutLine ("OutLine",float)=1
        _OutLineColor("OutLineColor",color)=(0,0,0,0)
        _SpecularThreshold("SpecularThreshold",float)=0.5
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


            float _OutLine;
            fixed4 _OutLineColor;

            v2f vert(appdata v)
            {
                v2f o;
                //shader入门精要上的做法
                // float4 pos=mul(UNITY_MATRIX_MV,v.vertex);
                // float3 normal=mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                // normal.z=0.5;
                // pos=pos+float4(normalize(normal),0)*_OutLine;
                // o.vertex=mul(UNITY_MATRIX_P,pos);
                float3 pos = v.vertex + v.normal * _OutLine;
                o.vertex = UnityObjectToClipPos(pos);
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
          
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uvMain : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 objectVertex:TEXCOORD2;
                float3 worldLightDir:TEXCOORD3;
                float3 worldNormal:TEXCOORD4;
                float3 worldPos:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _RampTex;
            float4 _RampColor;

            float _SpecularThreshold;

            v2f vert(appdata v)
            {
                v2f o;
                o.objectVertex = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex + normalize(v.normal) * 0);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldLightDir = normalize(UnityWorldSpaceLightDir(mul(unity_ObjectToWorld, v.vertex)));
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uvMain);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldLightDir = i.worldLightDir;
                fixed3 worldNormal = i.worldNormal;

                fixed value = dot(worldNormal, worldLightDir) / 2 + 0.5;

                float3 diffuse = tex2D(_RampTex,fixed2(value, value)) * col * _RampColor;

                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 specluar = pow(max(0, dot(viewDir, reflectDir)), 8) * col;

                specluar = step(_SpecularThreshold, specluar);
                return fixed4(diffuse + specluar, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}