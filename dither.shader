Shader "LX/Dither"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _GrayScale("GrayScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vertexDataFunc
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            fixed4 screenPos;
        };

        float Dither2x2Bayer(int x, int y, float brightness)
        {
            const float dither[4] = {
                0, 2,
                3, 1
            };
            int r = y * 2 + x;
            return step(dither[r], brightness);
        }

        float Dither4x4Bayer(int x, int y, float brightness)
        {
            const float dither[16] = {
                0, 8, 2, 10,
                12, 4, 14, 6,
                3, 11, 1, 9,
                15, 7, 13, 5
            };
            int r = y * 4 + x;
            return step(dither[r], brightness);
        }


        float Dither8x8Bayer(int x, int y, float brightness)
        {
            const float dither[64] = {
                1, 49, 13, 61, 4, 52, 16, 64,
                33, 17, 45, 29, 36, 20, 48, 32,
                9, 57, 5, 53, 12, 60, 8, 56,
                41, 25, 37, 21, 44, 28, 40, 24,
                3, 51, 15, 63, 2, 50, 14, 62,
                35, 19, 47, 31, 34, 18, 46, 30,
                11, 59, 7, 55, 10, 58, 6, 54,
                43, 27, 39, 23, 42, 26, 38, 22
            };
            int r = y * 8 + x;
            return step(dither[r], brightness);
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _GrayScale;


        void vertexDataFunc(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float4 screenPos = ComputeScreenPos(UnityObjectToClipPos(v.vertex));
            o.screenPos = screenPos;
        }

        #define _8x8

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 screenPos = IN.screenPos.xy / IN.screenPos.w * _ScreenParams.xy;
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            int brightness = Luminance(c) * 256;
            int colorR = c.r * 256;
            int colorG = c.g * 256;
            int colorB = c.b * 256;

            fixed gray;
            fixed r;
            fixed g;
            fixed b;

            #ifdef _8x8
            brightness = brightness >> 2;
            colorR = colorR >> 2;
            colorG = colorG >> 2;
            colorB = colorB >> 2;
            gray = Dither8x8Bayer(screenPos.x % 8, screenPos.y % 8, brightness);
            r = Dither8x8Bayer(screenPos.x % 8, screenPos.y % 8, colorR);
            g = Dither8x8Bayer(screenPos.x % 8, screenPos.y % 8, colorG);
            b = Dither8x8Bayer(screenPos.x % 8, screenPos.y % 8, colorB);
            #elif defined (_4x4)
            brightness = brightness >> 4;
            colorR=colorR>>4;
            colorG=colorG>>4;
            colorB=colorB>>4;
            gray = Dither8x8Bayer(screenPos.x % 4, screenPos.y % 4, brightness);
            r = Dither8x8Bayer(screenPos.x % 4, screenPos.y % 4, colorR);
            g = Dither8x8Bayer(screenPos.x % 4, screenPos.y % 4, colorG);
            b = Dither8x8Bayer(screenPos.x % 4, screenPos.y % 4, colorB);
            #elif defined (_2x2)
            brightness = brightness >> 6;
            colorR=colorR>>6;
            colorG=colorG>>6;
            colorB=colorB>>6;
            gray = Dither8x8Bayer(screenPos.x % 2, screenPos.y % 2, brightness);
            r = Dither8x8Bayer(screenPos.x % 2, screenPos.y % 2, colorR);
            g = Dither8x8Bayer(screenPos.x % 2, screenPos.y % 2, colorG);
            b = Dither8x8Bayer(screenPos.x % 2, screenPos.y % 2, colorB);
            #endif

            fixed3 grayColor = fixed3(gray, gray, gray);
            fixed3 color = fixed3(r, g, b);
            o.Albedo = lerp(color, grayColor, _GrayScale);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}