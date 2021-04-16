Shader "LX/ComicBook"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    half4 _StripParams;
    half3 _StripInnerColor;
    half3 _StripOuterColor;

    half3 _FillColor;
    half3 _BackgroundColor;

    float _StripDensity;
    float _StripThickness;
    half _Amount;


    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    half3 strip_color(half2 uv)
    {
        half2 p = (uv - 0.5) * _StripDensity;
        half brightness = cos(dot(p, _StripParams.xy));
        half lum_strip = Luminance(1.0 - brightness);
        return lerp(_StripOuterColor, _StripInnerColor, step(lum_strip, _StripThickness));
    }


    v2f vert(appdata_base v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        return o;
    }

    half4 frag(v2f_img i) : SV_Target
    {
        half lum = Luminance(tex2D(_MainTex, i.uv).rgb);
        half s1 = step(lum, _StripParams.z);
        half s2 = step(_StripParams.z, lum) * step(lum, _StripParams.w);
        half3 color = lerp(lerp(_BackgroundColor, strip_color(i.uv), s2), _FillColor, s1);

        //用Amount对原像素颜色和处理后的像素颜色进行插值
        half3 oldColor = tex2D(_MainTex, i.uv).rgb;
        return half4(lerp(oldColor, color, _Amount), 1.0);
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