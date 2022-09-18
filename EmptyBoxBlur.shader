Shader "LX/EmptyBoxBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment extractBright

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
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            int _Size;

            fixed4 extractBright(v2f i) : SV_Target
            {
                fixed4 col;
                float weight = 0;
                for (int index = -_Size; index <= _Size; index++)
                {
                    col += tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * fixed2(index, -_Size));
                    weight++;
                }
                for (int index = -_Size; index <= _Size; index++)
                {
                    col += tex2D(_MainTex, i.uv + _MainTex_TexelSize.xy * fixed2(index, _Size));
                    weight++;
                }
                for (int index = -_Size; index <= _Size; index++)
                {
                    col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * fixed2(-_Size, index));
                    weight++;
                }
                for (int index = -_Size; index <= _Size; index++)
                {
                    col += tex2D(_MainTex, i.uv + _MainTex_TexelSize * fixed2(_Size, index));
                    weight++;
                }


                return col / weight;
            }
            ENDCG
        }
    }
}