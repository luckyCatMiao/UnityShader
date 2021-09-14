Shader "LX/parallaxMap"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range( -8 , 8)) = 1
        _ParallaxMap("Parallax Map", 2D) = "black" {}
        _ParallaxScale("Parallax Scale", float) = 1
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
        sampler2D _NormalMap;
        float _NormalScale;

        sampler2D _ParallaxMap;
        float _ParallaxScale;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            _ParallaxScale /= 100.0f;
            //viewDir是切线空间的
            float2 offset = (tex2D(_ParallaxMap, IN.uv_MainTex).r - 1) * IN.viewDir.xy * _ParallaxScale + IN.uv_MainTex;
            float2 Offset1 = (tex2D(_ParallaxMap, offset).r - 1) * IN.viewDir.xy * _ParallaxScale + offset;
            float2 Offset2 = (tex2D(_ParallaxMap, Offset1).r - 1) * IN.viewDir.xy * _ParallaxScale + Offset1;
            float2 Offset3 = (tex2D(_ParallaxMap, Offset2).r - 1) * IN.viewDir.xy * _ParallaxScale + Offset2;
            float2 uv = Offset3;
            
            fixed4 c = tex2D(_MainTex, uv) * _Color;

            fixed3 normal = UnpackNormal(tex2D(_NormalMap, uv));
            normal.xy *= _NormalScale;
            normal = normalize(normal);
            o.Normal = normal;

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}