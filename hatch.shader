Shader "LX/hatch"
{
    Properties
    {
        _Tex1 ("Tex1", 2D) = "white" {}
        _Tex2 ("Tex2", 2D) = "white" {}
        _Tex3 ("Tex3", 2D) = "white" {}
        _Tex4 ("Tex4", 2D) = "white" {}
        _Tex5 ("Tex5", 2D) = "white" {}
        _Tex6 ("Tex6", 2D) = "white" {}
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
                fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float weight : TEXCOORD1;
            };

            sampler2D _Tex1;
            sampler2D _Tex2;
            sampler2D _Tex3;
            sampler2D _Tex4;
            sampler2D _Tex5;
            sampler2D _Tex6;
            float4 _Tex1_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Tex1);

                fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                float weight = max(0, dot(worldLightDir, worldNormal)) * 7;

                o.weight = weight;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_Tex1, i.uv);
                if (i.weight > 6)
                {
                    col = tex2D(_Tex6, i.uv);
                }
                else if (i.weight > 5)
                {
                    col = tex2D(_Tex5, i.uv);
                }
                else if (i.weight > 4)
                {
                    col = tex2D(_Tex4, i.uv);
                }
                else if (i.weight > 3)
                {
                    col = tex2D(_Tex3, i.uv);
                }
                else if (i.weight > 2)
                {
                    col = tex2D(_Tex2, i.uv);
                }
                else if (i.weight > 1)
                {
                    col = tex2D(_Tex1, i.uv);
                }
                else
                {
                    col = fixed4(0, 0, 0, 1);
                }

                return col;
            }
            ENDCG
        }
    }
}