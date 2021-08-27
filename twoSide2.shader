Shader "Custom/twoSide2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FrontTex ("FrontTex", 2D) = "white" {}
        _BackTex ("BackTex", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Mask ("Mask", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MaskClipValue ("MaskClipValue", range(0,1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        Cull Front
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _BackTex;
        sampler2D _Mask;

        struct Input
        {
            float2 uv_BackTex;
            float2 uv_Mask;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _MaskClipValue;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            //clip(tex2D(_Mask, IN.uv_Mask).a - _MaskClipValue);
            fixed4 c = tex2D(_BackTex, IN.uv_BackTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG



        Cull Back
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _FrontTex;
        sampler2D _Mask;

        struct Input
        {
            float2 uv_FrontTex;
            float2 uv_Mask;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _MaskClipValue;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            clip(tex2D(_Mask, IN.uv_Mask).a - _MaskClipValue);
            fixed4 c = tex2D(_FrontTex, IN.uv_FrontTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}