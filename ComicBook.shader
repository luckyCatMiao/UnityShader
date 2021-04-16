Shader "LX/ComicBook"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float _StripCosAngle;
    float _StripSinAngle;
    float _StripLimitsMin;
    float _StripLimitsMax;
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
        //fixed passStep=step(_StripThickness,sin(uv.x*_StripDensity)*sin(uv.y*_StripDensity));
        //网点化处理，通过cos函数进行周期变化，同时点积从原点出发到uv坐标的向量和传入的一个向量，实际效果是在单位向量上进行了投影
        fixed passStep = step(_StripThickness,
                              (cos(dot(uv * _StripDensity, float2(_StripCosAngle, _StripSinAngle))) + 1) / 2);
        return lerp(_StripInnerColor, _StripOuterColor, passStep);
    }


    v2f vert(appdata_base v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        return o;
    }

    half4 frag(v2f_img i) : SV_Target
    {
        //判断亮度落在哪个区域中，该shader一共有三个区域
        half lum = Luminance(tex2D(_MainTex, i.uv).rgb);
        half underMin = step(lum, _StripLimitsMin);
        half betweenLimit = step(_StripLimitsMin, lum) * step(lum, _StripLimitsMax);
        //设置最后的颜色，如果亮度落在中间区域中，还要进行网点化处理
        half3 color = lerp(lerp(_BackgroundColor, strip_color(i.uv), betweenLimit), _FillColor, underMin);

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