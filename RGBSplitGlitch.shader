Shader "LX/RGBSplitGlitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UseTime("UseTime",float)=0
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
            float _Distance;
            float _UseTime;
            float _Speed;

            float randomNoise(float x, float y)
            {
                return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
            }

            fixed4 extractBright(v2f i) : SV_Target
            {
                float noise=randomNoise(_Time.x*_UseTime*_Speed,_Time.x*_UseTime*_Speed)*_Distance;
                fixed colorR = tex2D(_MainTex, i.uv).r;
                fixed colorG = tex2D(_MainTex, fixed2(i.uv.x + _MainTex_TexelSize.x*noise,i.uv.y)).g;
                fixed colorB = tex2D(_MainTex, fixed2(i.uv.x - _MainTex_TexelSize.x*noise,i.uv.y)).b;
                return fixed4(colorR, colorG, colorB, 1);
            }
            ENDCG
        }
    }
}