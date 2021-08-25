Shader "LX/reduceColor"
{

    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DiscreteLevel("DiscreteLevel",range(1,256))=256
        _GrayScale("_GrayScale",range(0,1))=0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        int _DiscreteLevel;
        float _GrayScale;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            //先计算出亮度
            fixed brightness = Luminance(c.rgb);
            //灰度离散化
            brightness = floor(brightness * 256 / (256 / _DiscreteLevel)) * (256 / _DiscreteLevel) / 256;
            fixed3 grayColor = fixed3(brightness, brightness, brightness);

            //彩色离散化
            fixed r = floor(c.r * 256 / (256 / _DiscreteLevel)) * (256 / _DiscreteLevel) / 256;
            fixed g = floor(c.g * 256 / (256 / _DiscreteLevel)) * (256 / _DiscreteLevel) / 256;
            fixed b = floor(c.b * 256 / (256 / _DiscreteLevel)) * (256 / _DiscreteLevel) / 256;
            fixed3 color = fixed3(r, g, b);

            //插值
            o.Albedo = lerp(color, grayColor, _GrayScale);
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}