Shader "LX/ViewDirOutLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutLineColor("OutLineColor",color)=(1,0,0,1)
        _OutLineWidth("OutLineWidth",range(0,1))=0.1
        _OutLineDamp("OutLineDamp",int)=1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        //pass 1 lambert
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


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
                float3 worldNormal = i.worldNormal;
                float3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos);
                float diffuse = saturate(dot(worldNormal, worldLightDir));
                fixed4 col = tex2D(_MainTex, i.uv) * diffuse;
                return col;
            }
            ENDCG
        }

        //pass 2 OutLine
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _OutLineColor;
            float _OutLineWidth;
            int _OutLineDamp;

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
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldNormal = normalize(i.worldNormal);
                float weight = pow(1 - saturate(dot(worldViewDir, worldNormal)), _OutLineDamp);
                fixed4 col = weight * _OutLineColor;
                col = step(1 - _OutLineWidth, weight) * col;
                return col;
            }
            ENDCG
        }
    }
}