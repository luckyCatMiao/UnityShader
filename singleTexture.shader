Shader "LX/singleTexture"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
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

            struct a2v
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPosition:TEXCOORD1;
                float2 uvMain:TEXCOORD2;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                o.worldNormal=normalize(UnityObjectToWorldNormal(vertData.normal));
                o.worldPosition=mul(unity_ObjectToWorld,vertData.position);
                o.uvMain=vertData.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPosition));
                fixed3 texColor=tex2D(_MainTex,i.uvMain).rgb;
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT*texColor;
                fixed3 diffuse=_LightColor0.rgb*texColor*saturate(dot(i.worldNormal,worldLightDir));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPosition));
                fixed3 halfDir=normalize(worldLightDir+viewDir);
                fixed3 specular=texColor*_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1.0);
            }
            
            ENDCG

        }
    }
}