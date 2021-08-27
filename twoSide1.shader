Shader "LX/twoSide1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FrontTex ("FrontTex", 2D) = "white" {}
        _BackTex ("BackTex", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Mask ("Mask", 2D) = "white" {}
        _MaskClipValue ("MaskClipValue", range(0,1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200
        Cull Off
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _FrontTex;
        sampler2D _BackTex;
        sampler2D _Mask;

        struct Input
        {
            float2 uv_FrontTex;
            float2 uv_BackTex;
            float2 uv_Mask;
            fixed face : VFACE;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _MaskClipValue;


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            clip(tex2D(_Mask, IN.uv_Mask).a - _MaskClipValue);

            fixed4 frontC = tex2D(_FrontTex, IN.uv_FrontTex) * _Color;
            fixed4 backC = tex2D(_BackTex, IN.uv_FrontTex) * _Color;

            //虽然要做if判断会影响性能  但是比跑两个pass还是要好，而且两个pass如果里面有clip操作的话要跑两次clip
            if (IN.face > 0)
            {
                o.Albedo = frontC.rgb;
                o.Alpha = frontC.a;
            }
            else
            {
                o.Albedo = backC.rgb;
                o.Alpha = backC.a;
            }

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}