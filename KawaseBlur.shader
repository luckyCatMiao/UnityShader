Shader "LX/KawaseBlur"
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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float _BlurDistance;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv + fixed2(0, 0) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(0, 1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(-1, 0) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(-1, -1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(0, -1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(1, -1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(-1, 1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(0, 1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                col += tex2D(_MainTex, i.uv + fixed2(1, 1) * _BlurDistance*_MainTex_TexelSize.xy) * 1/9;
                return col;
            }
            ENDCG
        }
    }
}