Shader "Unlit/AdjustImg2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Saturation ("Saturation", float) =1
        _Contrast ("Contrast", float) =1
        _Brightness ("Brightness", float) =1
    }
    SubShader
    {

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Saturation;
            float _Contrast;
            float _Brightness;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed maxColorV = max(max(col.r, col.g), col.b);
                fixed3 maxColor = fixed3(maxColorV, maxColorV, maxColorV);
                fixed3 finalColor = lerp(maxColor, col.rgb, _Saturation);

                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                fixed3 darkColor = fixed3(0, 0, 0);
                finalColor = lerp(darkColor, finalColor, _Brightness);

                return fixed4(finalColor, col.a);
            }
            ENDCG
        }
    }
}