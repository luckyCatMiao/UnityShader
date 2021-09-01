Shader "LX/postDistortion"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _DistortionScale ("DistortionScale", float) = 0.1
        _WaveLength ("WaveLength", float) = 1
        _Offset ("Offset", float) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Opaque"
        }
        LOD 200
        GrabPass
        {
            "_GrabTex"
        }
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _GrabTex;
        float4 _GrabTex_TexelSize;
        float _DistortionScale;
        float _WaveLength;
        float _Offset;

        struct Input
        {
            float4 screenPos;
        };

        fixed4 _Color;


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            IN.screenPos.xy /= IN.screenPos.w;
            IN.screenPos.y=-IN.screenPos.y+_Offset;
            IN.screenPos.xy+= fixed2(_DistortionScale, 0) * sin(_Time.y + IN.screenPos.y * _WaveLength);
            fixed4 c = tex2D(_GrabTex, IN.screenPos) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}