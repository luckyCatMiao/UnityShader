Shader "LX/normalMap_world"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
        _BumpMap("Normal Map",2D)="bump"{}
        _BumpScale("Bump Scale",Float)=1.0
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;


            struct a2v
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float4 uv :TEXCOORD0;
                float4 ToW0:TEXCOORD1;
                float4 ToW1:TEXCOORD2;
                float4 ToW2:TEXCOORD3;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                o.uv.xy = vertData.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = vertData.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld,vertData.position).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(vertData.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(vertData.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * vertData.tangent.w;

                o.ToW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.ToW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.ToW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float3 worldPos=float3(i.ToW0.w,i.ToW1.w,i.ToW2.w);
                fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                bump.xy*=_BumpScale;
                bump.z=sqrt(1.0-saturate(dot(bump.xy,bump.xy)));
                bump=normalize(half3(dot(i.ToW0.xyz,bump),dot(i.ToW1.xyz,bump),dot(i.ToW2.xyz,bump)));

                fixed3 texColor = tex2D(_MainTex, i.uv).rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * texColor;
                fixed3 diffuse = _LightColor0.rgb * texColor * saturate(dot(bump, lightDir));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = texColor * _LightColor0.rgb * _Specular.rgb * pow(
                    saturate(dot(bump, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG

        }
    }
}