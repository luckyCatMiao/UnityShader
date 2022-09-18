Shader "LX/RebuildNormal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pixel ("Pixel", int) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _Pixel;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color=tex2D(_MainTex,floor(i.uv*_Pixel)/_Pixel);
                fixed3 normal=normalize(cross(ddy(i.worldPos),ddx(i.worldPos)));
                fixed3 worldNormal=UnityObjectToWorldNormal(normal);
                fixed diffuse=saturate(dot(worldNormal,UnityWorldSpaceLightDir(i.worldPos)));
                
                return fixed4(diffuse*fixed3(1,1,1),1)*color;
            }
            ENDCG
        }
    }
}