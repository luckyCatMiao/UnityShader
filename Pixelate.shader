Shader "LX/Pixelate"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    int _PixelSize;
    int _AddStrip;

    half2 stitch(half2 uv)
    {
        half2 screenPos = floor(uv * _ScreenParams.xy);
        half2 reminder;
        reminder.y = (screenPos.y - screenPos.x) % _PixelSize;
        reminder.x = (screenPos.y + screenPos.x) % _PixelSize;
        return reminder;
    }

    half4 pixel(half2 uv)
    {
        half2 screenPos = floor(uv * _ScreenParams.xy / _PixelSize) * _PixelSize;
        return tex2D(_MainTex, screenPos / _ScreenParams.xy);
    }

    half4 frag(v2f_img i) : SV_Target
    {
        half2 reminder = stitch(i.uv);
        half4 color = pixel(i.uv);
        return (reminder.y == 0 || reminder.x == 0)&&_AddStrip==1 ? half4(0, 0, 0, 1) : color;
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