Shader "LX/alpha"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
        _AlphaScale("Alpha Scale",Range(0,1))=1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _AlphaScale;

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
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            v2f vert(a2v vertData)
            {
                v2f o;
                o.position = UnityObjectToClipPos(vertData.position);
                o.uv.xy = vertData.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                o.worldPos = mul(unity_ObjectToWorld, vertData.position).xyz;
                o.worldNormal = UnityObjectToWorldNormal(vertData.normal);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                float3 worldPos = i.worldPos;
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldNormal = i.worldNormal;
                fixed3 texColor = tex2D(_MainTex, i.uv).rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * texColor;
                fixed3 diffuse = _LightColor0.rgb * texColor * saturate(dot(worldNormal, worldLightDir));

                return fixed4(ambient + diffuse, tex2D(_MainTex, i.uv).a * _AlphaScale);
            }
            ENDCG

        }


    }
}