Shader "LX/triplaneProj2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Tex1 ("Tex1", 2D) = "white" {}
        _Tex2 ("Tex2", 2D) = "white" {}
        _Tex3 ("Tex3", 2D) = "white" {}
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
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _Tex1;
        sampler2D _Tex2;
        sampler2D _Tex3;

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;


        fixed4 tex3D(float2 xy, float2 yz, float2 xz, fixed3 worldNormal)
        {
            fixed4 colorXY = tex2D(_Tex1, xy);
            fixed4 colorYZ = tex2D(_Tex2, yz);
            fixed4 colorXZ = tex2D(_Tex3, xz);
            float maskX = abs(dot(worldNormal, fixed3(1, 0, 0)));
            float maskY = abs(dot(worldNormal, fixed3(0, 1, 0)));

            fixed4 finalColor = lerp(colorXY, colorYZ, maskX);
            finalColor = lerp(finalColor, colorXZ, maskY);

            return finalColor;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 color = tex3D(IN.worldPos.xy, IN.worldPos.yz, IN.worldPos.xz, IN.worldNormal);
            o.Albedo = color.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}