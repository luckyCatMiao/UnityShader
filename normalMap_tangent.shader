Shader "LX/normalMap_tangent"
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
                float3 lightDir:TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                o.uv.xy = vertData.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = vertData.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                
                float3 binormal = cross(normalize(vertData.normal), normalize(vertData.tangent.xyz)) * vertData.tangent.
                    w;
                float3x3 rotation = float3x3(vertData.tangent.xyz, binormal, vertData.normal);
                o.lightDir = mul(rotation, ObjSpaceLightDir(vertData.position)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(vertData.position)).xyz;

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 texColor = tex2D(_MainTex, i.uv).rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * texColor;
                fixed3 diffuse = _LightColor0.rgb * texColor * saturate(dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = texColor * _LightColor0.rgb * _Specular.rgb * pow(
                    saturate(dot(tangentNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG

        }
    }
}