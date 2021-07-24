Shader "LX/bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uvMain : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;

        sampler2D _Bloom;

        float threshold;

        v2f vertExtractBright(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        fixed4 fragExtractBright(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uvMain);
            fixed val = clamp(Luminance(col) - threshold, 0, 1);

            return col * val;
        }


        v2f vertBloom(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        fixed4 fragBloom(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uvMain) + tex2D(_Bloom, i.uvMain);
            return col;
        }
        ENDCG


        ZTest Always
        Cull Off
        Zwrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }

        UsePass "LX/GaussianBlur/G_V"
        UsePass "LX/GaussianBlur/G_H"

    }
}