Shader "LX/Sharpen"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Intensity("Intensity", Range(0, 20)) = 2
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType"="Opaque"
            }
            Cull off ZWrite Off ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha

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
            float _Intensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 c = tex2D(_MainTex, i.uv).rgb;
                c += (ddx(c) + ddy(c)) * _Intensity;
                return fixed4(c, 1);
            }
            ENDCG
        }
    }
}