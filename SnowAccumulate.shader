Shader "LX/SnowAccumulate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SnowTex("SnowTex",2D)="white" {}
        _MainBumpTex("MainBumpTex",2D) = "white" {}
        _SnowBumpTex("SnowBumpTex",2D) = "white" {}
        _SnowDir("SnowDir",vector)=(0,1,0)
        _SnowAmount("SnowAmount",float)=1
        _BumpScale("BumpScale",float)=1
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
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal:TEXCOORD1;
                float4 ToW0:TEXCOORD2;
                float4 ToW1:TEXCOORD3;
                float4 ToW2:TEXCOORD4;
                float3 worldPos:TEXCOORD5;
            };

            sampler2D _MainTex;
            sampler2D _SnowTex;
            sampler2D _MainBumpTex;
            sampler2D _SnowBumpTex;
            float4 _MainTex_ST;
            float3 _SnowDir;
            float _SnowAmount;
            float _BumpScale;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos;
                fixed3 worldNormal = o.worldNormal;
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.ToW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.ToW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.ToW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //计算法线
                fixed3 mainNormal = UnpackNormal(tex2D(_MainBumpTex, i.uv));
                mainNormal.xy *= _BumpScale;
                mainNormal.z = sqrt(1.0 - saturate(dot(mainNormal.xy, mainNormal.xy)));
                mainNormal = normalize(half3(dot(i.ToW0.xyz, mainNormal), dot(i.ToW1.xyz, mainNormal),
                                             dot(i.ToW2.xyz, mainNormal)));

                fixed3 snowNormal = UnpackNormal(tex2D(_SnowBumpTex, i.uv));
                snowNormal.xy *= _BumpScale;
                snowNormal.z = sqrt(1.0 - saturate(dot(snowNormal.xy, snowNormal.xy)));
                snowNormal = normalize(half3(dot(i.ToW0.xyz, snowNormal), dot(i.ToW1.xyz, snowNormal),
                                             dot(i.ToW2.xyz, snowNormal)));

                //根据下雪方向和法线的点积来确定混合程度
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 snowColor = tex2D(_SnowTex, i.uv);

                float snowValue = saturate(dot(mainNormal, _SnowDir) * _SnowAmount);
                fixed4 finalColor = lerp(col, snowColor, snowValue);

                //混合法线
                fixed3 finalNormal = lerp(mainNormal, snowNormal, snowValue);

                //简易lambert光照
                float lightDir = UnityWorldSpaceLightDir(i.worldPos);
                float diffuse = saturate(dot(lightDir, finalNormal)) * finalColor;
                float4 ambient = UNITY_LIGHTMODEL_AMBIENT.rgba * finalColor;

                return diffuse + ambient;
            }
            ENDCG
        }
    }
}