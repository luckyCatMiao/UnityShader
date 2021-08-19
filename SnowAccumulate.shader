Shader "Unlit/SnowAccumulate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SnowTex("SnowTex",2D)="white" {}
        _SnowDir("SnowDir",vector)=(0,1,0)
        _SnowAmount("SnowAmount",float)=1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float3 _SnowDir;
            sampler2D _SnowTex;
            
            float _SnowAmount;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 snowColor = tex2D(_SnowTex, i.uv);

                //根据下雪方向和法线的点积来确定混合程度
                float snowValue = saturate(dot(i.worldNormal, _SnowDir) * _SnowAmount);
                fixed4 finalColor = lerp(col, snowColor, snowValue);
                return finalColor;
            }
            ENDCG
        }
    }
}