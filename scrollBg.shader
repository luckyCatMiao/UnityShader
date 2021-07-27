Shader "LX/scrollBg"
{
    Properties
    {
        _MainTex ("BG1", 2D) = "white" {}
        _MainTex2 ("BG2", 2D) = "white" {}
        _ScrollSpeed1("_ScrollSpeed1",float)=1
        _ScrollSpeed2("_ScrollSpeed2",float)=1
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
                float2 backUV : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 frontUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _MainTex2;
            float4 _MainTex2_ST;

            float _ScrollSpeed1;
            float _ScrollSpeed2;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.backUV = TRANSFORM_TEX(v.uv, _MainTex);
                o.backUV.x = o.backUV.x + frac(_Time.y * _ScrollSpeed1);
                o.frontUV = TRANSFORM_TEX(v.uv, _MainTex2);
                o.frontUV.x = o.frontUV.x + frac(_Time.y * _ScrollSpeed2);;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 backCol = tex2D(_MainTex, i.backUV);
                fixed4 frontCol = tex2D(_MainTex2, i.frontUV);

                return lerp(backCol, frontCol, frontCol.a);
            }
            ENDCG
        }
    }
}