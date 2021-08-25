Shader "LX/Dither"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
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

        
        float Dither8x8Bayer(int x, int y,float brightness)
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
            return step(dither[r],brightness);
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;


        void vertexDataFunc(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float4 screenPos = ComputeScreenPos(UnityObjectToClipPos(v.vertex));
            o.screenPos = screenPos;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 screenPos=IN.screenPos.xy/IN.screenPos.w*_ScreenParams.xy;
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            int brightness = Luminance(c)*256;
            brightness=brightness>>2;
            fixed color=Dither8x8Bayer(screenPos.x%8,screenPos.y%8,brightness);
            o.Albedo = fixed3(color,color,color);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}