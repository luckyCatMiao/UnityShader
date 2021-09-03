Shader "LX/highLight"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _RimPow ("RimPow", float) = 2
        _RimColor ("RimColor", Color) = (1,1,0,1)
        _RimColorSpeed ("RimColorSpeed", float) = 1
        [Toggle]_Highlighted("Highlighted", Float) = 0
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
            float3 worldPos;
            float3 worldNormal;
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _RimPow;
        fixed4 _RimColor;
        float _Highlighted;
        float _RimColorSpeed;


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 viewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float3 normal = normalize(IN.worldNormal);
            float rimPower = pow(1 - saturate(dot(normal, viewDir)), _RimPow);
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Emission = _Highlighted * rimPower * _RimColor * lerp(0.5,1,(sin(_Time.x*_RimColorSpeed)+1)/2);
        }
        ENDCG
    }
    FallBack "Diffuse"
}