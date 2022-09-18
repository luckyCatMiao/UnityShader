Shader "LX/BloomFull"
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
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        struct v2f2
        {
            float4 vertex : SV_POSITION;
            half2 uv[5]:TEXCOORD0;
        };

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _BrightTex;
        float _BlurDistance;
        float _Threshold;
        float _Intensity;
        float _Lerp;
        float4 _BloomTint;


        v2f vert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv);
            return col * step(_Threshold, Luminance(col))*_BloomTint;
        }

        fixed4 kawaseBlur(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv + fixed2(0.5, 0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(-0.5, -0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(0.5, -0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(-0.5, 0.5) * _BlurDistance * _MainTex_TexelSize.xy) * 0.25;

            return col;
        }

        fixed4 boxBlur(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv + fixed2(1, 0) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(-1, 0) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(0, 1) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;
            col += tex2D(_MainTex, i.uv + fixed2(0, -1) * _MainTex_TexelSize.xy * _BlurDistance) * 0.25;

            return col;
        }

        v2f2 vertV(appdata v)
        {
            v2f2 o;
            o.vertex = UnityObjectToClipPos(v.vertex);

            o.uv[0] = v.uv + float2(0, _MainTex_TexelSize.y * -3.2307692308 * _BlurDistance);
            o.uv[1] = v.uv + float2(0, _MainTex_TexelSize.y * -1.3846153846 * _BlurDistance);
            o.uv[2] = v.uv;
            o.uv[3] = v.uv + float2(0, _MainTex_TexelSize.y * 1.3846153846 * _BlurDistance);
            o.uv[4] = v.uv + float2(0, _MainTex_TexelSize.y * 3.2307692308 * _BlurDistance);

            return o;
        }

        v2f2 vertH(appdata v)
        {
            v2f2 o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv + float2(_MainTex_TexelSize.x * -3.2307692308 * _BlurDistance, 0);
            o.uv[1] = v.uv + float2(_MainTex_TexelSize.x * -1.3846153846 * _BlurDistance, 0);
            o.uv[2] = v.uv;
            o.uv[3] = v.uv + float2(_MainTex_TexelSize.x * 1.3846153846 * _BlurDistance, 0);
            o.uv[4] = v.uv + float2(_MainTex_TexelSize.x * 3.2307692308 * _BlurDistance, 0);

            return o;
        }

        fixed4 gaussianBlur(v2f2 i) : SV_Target
        {
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * 0.0702702703;
            sum += tex2D(_MainTex, i.uv[1]).rgb * 0.3162162162;
            sum += tex2D(_MainTex, i.uv[2]).rgb * 0.2270270270;
            sum += tex2D(_MainTex, i.uv[3]).rgb * 0.3162162162;
            sum += tex2D(_MainTex, i.uv[4]).rgb * 0.0702702703;

            return fixed4(sum, 1);
        }

        fixed4 combine(v2f i) : SV_Target
        {
            fixed4 rawColor = tex2D(_MainTex, i.uv);
            fixed4 brightColor = tex2D(_MainTex, i.uv) + tex2D(_BrightTex, i.uv) * _Intensity;
            return lerp(rawColor, brightColor, _Lerp);
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment kawaseBlur
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment boxBlur
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertV
            #pragma fragment gaussianBlur
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vertH
            #pragma fragment gaussianBlur
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment combine
            ENDCG
        }
    }
}