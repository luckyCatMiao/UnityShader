﻿Shader "LX/screenSpaceTex"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
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
            float4 screenPos;
        };

        fixed4 _Color;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            IN.screenPos.xy/=IN.screenPos.w;
            fixed4 c = tex2D(_MainTex, IN.screenPos) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}