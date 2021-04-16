Shader "LX/OldTV"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"


    sampler2D _MainTex;
    half4 _Params1;
    half4 _Params2;

    half2 barrelDistortion(half2 coord, half spherical, half barrel, half scale)
    {
        half2 h = coord.xy - half2(0.5, 0.5);
        half r2 = dot(h, h);
        half f = 1.0 + r2 * (spherical + barrel * sqrt(r2));
        return f * scale * h + 0.5;
    }

    float simpleNoise(float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    half4 filter_pass_h(half2 uv)
    {
        //half2 coord = barrelDistortion(uv, _Params2.y, _Params2.z, _Params2.w);
         float d2 = dot(uv - half2(0.5, 0.5), uv - half2(0.5, 0.5));
         half2 coord = (uv - half2(0.5, 0.5)) * (0.7+d2*0.3) + half2(0.5, 0.5);
        half4 color = tex2D(_MainTex, coord);

        float n = simpleNoise(coord.xy * _Params2.x);
        half3 result = color.rgb * 0.7 + 0.3 * color.rgb * n;

        half2 sc = half2(sin(coord.y * _Params1.z + _Params1.w), cos(coord.y * _Params1.z + _Params1.w));
        result += color.rgb * sc.xyx * _Params1.y;

        return half4(result, color.a);
    }

    half4 frag(v2f_img i) : SV_Target
    {
        return filter_pass_h(i.uv);
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