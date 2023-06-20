Shader "YiDou/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            half2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            #if Kernel5
            half2 uv[3]:TEXCOORD0;
            #elif Kernel9
            half2 uv[5]:TEXCOORD0;
            #endif
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;
        half _BlurSpreadSize;


        v2f vertV(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);

            //uv非整数，可以一次采样多个点 因此采样三个点等于采样五个，采样五个等于九个
            #if Kernel5
            o.uv[0] = v.uv + half2(0, _MainTex_TexelSize.y * -1.087 * _BlurSpreadSize);
            o.uv[1] = v.uv;
            o.uv[2] = v.uv + half2(0, _MainTex_TexelSize.y * 1.087 * _BlurSpreadSize);
            #elif Kernel9
            o.uv[0] = v.uv + half2(0, _MainTex_TexelSize.y * -3.2307692308 * _BlurSpreadSize); 
            o.uv[1] = v.uv + half2(0, _MainTex_TexelSize.y * -1.3846153846 * _BlurSpreadSize);
            o.uv[2] = v.uv;
            o.uv[3] = v.uv + half2(0, _MainTex_TexelSize.y * 1.3846153846 * _BlurSpreadSize);
            o.uv[4] = v.uv + half2(0, _MainTex_TexelSize.y * 3.2307692308 * _BlurSpreadSize);
            #endif

            return o;
        }

        v2f vertH(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            #if Kernel5
            o.uv[0] = v.uv + half2(_MainTex_TexelSize.y * -1.087 * _BlurSpreadSize, 0);
            o.uv[1] = v.uv;
            o.uv[2] = v.uv + half2(_MainTex_TexelSize.y * 1.087 * _BlurSpreadSize, 0);
            #elif Kernel9
            o.uv[0] = v.uv + half2(_MainTex_TexelSize.x * -3.2307692308 * _BlurSpreadSize, 0);
            o.uv[1] = v.uv + half2(_MainTex_TexelSize.x * -1.3846153846 * _BlurSpreadSize, 0);
            o.uv[2] = v.uv;
            o.uv[3] = v.uv + half2(_MainTex_TexelSize.x * 1.3846153846 * _BlurSpreadSize, 0);
            o.uv[4] = v.uv + half2(_MainTex_TexelSize.x * 3.2307692308 * _BlurSpreadSize, 0);
            #endif

            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            //手动展开,for会降低性能
            #if Kernel5
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * 0.2504;
            sum += tex2D(_MainTex, i.uv[1]).rgb * 0.4992;
            sum += tex2D(_MainTex, i.uv[2]).rgb * 0.2504;
            #elif Kernel9
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * 0.0702702703;
            sum += tex2D(_MainTex, i.uv[1]).rgb * 0.3162162162;
            sum += tex2D(_MainTex, i.uv[2]).rgb * 0.2270270270;
            sum += tex2D(_MainTex, i.uv[3]).rgb * 0.3162162162;
            sum += tex2D(_MainTex, i.uv[4]).rgb * 0.0702702703;
            #endif

            return fixed4(sum, 1);
        }
        ENDCG


        Pass
        {
            CGPROGRAM
            #pragma vertex vertV
            #pragma fragment frag
            #pragma multi_compile Kernel5 Kernel9
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertH
            #pragma fragment frag
            #pragma multi_compile Kernel5 Kernel9
            ENDCG
        }
    }
}