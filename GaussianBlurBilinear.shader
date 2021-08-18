//使用5个采样点，实际进行9个采样的基于gpu双线性插值的高斯模糊
Shader "LX/GaussianBlurBilinear"
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
            float4 vertex : SV_POSITION;
            half2 uv[5]:TEXCOORD0;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;


        v2f vertV(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv + float2(0, _MainTex_TexelSize.y * -3.2307692308);
            o.uv[1] = v.uv + float2(0, _MainTex_TexelSize.y * -1.3846153846);
            o.uv[2] = v.uv ;
            o.uv[3] = v.uv + float2(0, _MainTex_TexelSize.y * 1.3846153846);
            o.uv[4] = v.uv + float2(0, _MainTex_TexelSize.y * 3.2307692308);

            return o;
        }

        v2f vertH(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv + float2( _MainTex_TexelSize.x * -3.2307692308,0);
            o.uv[1] = v.uv + float2( _MainTex_TexelSize.x * -1.3846153846,0);
            o.uv[2] = v.uv ;
            o.uv[3] = v.uv + float2( _MainTex_TexelSize.x * 1.3846153846,0);
            o.uv[4] = v.uv + float2( _MainTex_TexelSize.x * 3.2307692308,0);
            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            float weight[5] = {
                0.0702702703,
                0.3162162162,
                0.2270270270,
                0.3162162162,
                0.0702702703
            };
            fixed3 sum = 0;
            for (int index = 0; index < 5; index++)
            {
                sum += tex2D(_MainTex, i.uv[index]).rgb * weight[index];
            }

            return fixed4(sum, 1);
        }
        ENDCG


        ZTest Always
        Cull Off
        Zwrite Off

        Pass
        {
            NAME "G_V"
            CGPROGRAM
            #pragma vertex vertV
            #pragma fragment frag
            ENDCG
        }
        Pass
        {
            NAME "G_H"
            CGPROGRAM
            #pragma vertex vertH
            #pragma fragment frag
            ENDCG
        }
    }
}