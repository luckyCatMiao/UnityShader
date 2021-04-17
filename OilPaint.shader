Shader "LX/OilPaint"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _PSize ("Pixel Size (XY)", Vector) = (0,0,0,0)
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #define H3Z half3(0.0, 0.0, 0.0)
    sampler2D _MainTex;
    half2 _PSize;
    int _Radius;
    half4 frag(v2f_img i) : SV_Target
    {
        half3 m0 = H3Z;
        half3 m1 = H3Z;
        half3 m2 = H3Z;
        half3 m3 = H3Z;
        half3 s0 = H3Z;
        half3 s1 = H3Z;
        half3 s2 = H3Z;
        half3 s3 = H3Z;
        int k, j;

        for (j = -_Radius; j <= 0; j++)
        {
            for (k = -_Radius; k <= 0; k++)
            {
                half3 c = tex2D(_MainTex, i.uv + half2(k, j) * _PSize).rgb;
                m0 += c;
                s0 += c * c;
            }
        }

        for (j = -_Radius; j <= 0; j++)
        {
            for (k = 0; k <= _Radius; k++)
            {
                half3 c = tex2D(_MainTex, i.uv + half2(k, j) * _PSize).rgb;
                m1 += c;
                s1 += c * c;
            }
        }

        for (j = 0; j <= _Radius; j++)
        {
            for (k = 0; k <= _Radius; k++)
            {
                half3 c = tex2D(_MainTex, i.uv + half2(k, j) * _PSize).rgb;
                m2 += c;
                s2 += c * c;
            }
        }

        for (j = 0; j <= _Radius; j++)
        {
            for (k = -_Radius; k <= 0; k++)
            {
                half3 c = tex2D(_MainTex, i.uv + half2(k, j) * _PSize).rgb;
                m3 += c;
                s3 += c * c;
            }
        }

        const half n = half((_Radius + 1) * (_Radius + 1));
        half minSigma2 = 1;
        half3 color = H3Z;

        m0 /= n;
        s0 = abs(s0 / n - m0 * m0);
        half sigma2 = Luminance(s0);
        if (sigma2 < minSigma2)
        {
            minSigma2 = sigma2;
            color = m0;
        }

        m1 /= n;
        s1 = abs(s1 / n - m1 * m1);
        sigma2 = Luminance(s1);
        if (sigma2 < minSigma2)
        {
            minSigma2 = sigma2;
            color = m1;
        }

        m2 /= n;
        s2 = abs(s2 / n - m2 * m2);
        sigma2 = Luminance(s2);
        if (sigma2 < minSigma2)
        {
            minSigma2 = sigma2;
            color = m2;
        }

        m3 /= n;
        s3 = abs(s3 / n - m3 * m3);
        sigma2 = Luminance(s3);
        if (sigma2 < minSigma2)
        {
            minSigma2 = sigma2;
            color = m3;
        }

        return half4(color, 1.0);
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