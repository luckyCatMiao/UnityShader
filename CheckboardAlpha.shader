Shader "LX/CheckboardAlpha"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Scale ("Scale", int) = 2
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        
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
        float _Scale;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            half2 newUV = IN.uv_MainTex * _Scale;
            int show1 = step(0.5f, frac(newUV.x)) * step(frac(newUV.y), 0.5f);
            int show2 = step(frac(newUV.x),0.5f) * step(0.5f,frac(newUV.y));
            clip((show1 || show2)-0.5);
        }
        ENDCG
    }
    FallBack "Diffuse"
}