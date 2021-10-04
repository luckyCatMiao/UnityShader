Shader "LX/triplaneProj"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _TexUp ("TexUp", 2D) = "white" {}
        _TexForward ("TexForward", 2D) = "white" {}
        _TexLeft ("TexLeft", 2D) = "white" {}
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

        sampler2D _TexUp;
        sampler2D _TexForward;
        sampler2D _TexLeft;

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
            fixed4 colorForward = tex2D(_TexForward, yz);
            fixed4 colorUp = tex2D(_TexUp, xz);
            fixed4 colorLeft = tex2D(_TexLeft, xy);

            worldNormal = abs(worldNormal);
            worldNormal = worldNormal / (worldNormal.x + worldNormal.y + worldNormal.z);
            fixed4 finalColor = colorForward * worldNormal.x + colorUp * worldNormal.y + colorLeft * worldNormal.z;
            
            // float forwardRate = abs(dot(worldNormal, fixed3(1, 0, 0)));
            // float upRate = abs(dot(worldNormal, fixed3(0, 1, 0)));
            // float leftRate = abs(dot(worldNormal, fixed3(0, 0, 1)));
            //
            // float4 total = forwardRate + upRate + leftRate;
            // fixed4 finalColor = (forwardRate * colorForward + upRate * colorUp + leftRate * colorLeft) / total;

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