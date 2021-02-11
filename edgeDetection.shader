Shader "LX/edgeDetection"
{

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZTest Always
        Cull Off
        Zwrite Off


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
                float4 vertex : SV_POSITION;
                half2 uv[9]:TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            fixed3 edgeColor;
            float threshold;

            half sobel(v2f i)
            {
                const half Gx[9] =
                {
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };
                const half Gy[9] =
                {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };
                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for (int index = 0; index < 9; index++)
                {
                    texColor = Luminance(tex2D(_MainTex, i.uv[index]));
                    edgeX += texColor * Gx[index];
                    edgeY += texColor * Gy[index];
                }
                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);


                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv[4]);
                half edge = sobel(i);

                if (edge > threshold)
                    return col;
                else
                    return fixed4(edgeColor, 1);
            }
            ENDCG
        }
    }
}