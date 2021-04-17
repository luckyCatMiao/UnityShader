Shader "LX/OldTV"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;

    float _Expand;
    float _NoiseIntensity;
    int _StripeIntensity;

    float simpleNoise(float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }


    half4 frag(v2f_img i) : SV_Target
    {
        float d2 = dot(i.uv - half2(0.5, 0.5), i.uv - half2(0.5, 0.5));
        half2 coord = (i.uv - half2(0.5, 0.5)) * (_Expand + d2 * (1 - _Expand)) + half2(0.5, 0.5);
        half4 color = tex2D(_MainTex, coord);

        float n = simpleNoise(coord.xy * _Time.x);
        half3 result = color.rgb * (1-_NoiseIntensity) + _NoiseIntensity * n;

        half2 sc = half2((sin(coord.y * _StripeIntensity) + 1) / 2, (cos(coord.y * _StripeIntensity) + 1) / 2);
        result += color.rgb * sc.xyx;

        return half4(result, color.a);
    }
    ENDCG

    SubShader
    {
        ZTest Always Cull Off ZWrite Off
        Fog
        {
            Mode off
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }

    FallBack off
}