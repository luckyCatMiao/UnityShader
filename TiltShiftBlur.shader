﻿Shader "LX/TiltShiftBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment extractBright

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float _RotateDistance; //每次采样的旋转距离
            int _SampleCount; //采样数量
            float _Radius; //采样半径

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _Pow; 
            float _Offset; 

            fixed gridentUV(fixed2 uv)
            {
                return saturate(pow(abs((uv.y - 0.5+_Offset) * 2), _Pow/10));
            }

            fixed4 extractBright(v2f i) : SV_Target
            {
                fixed4 finalColor;
                float singleWeight = 1;
                float totalWeight = 0;
                float2 offset = float2(0, _Radius);
                float rotateCos = cos(_RotateDistance);
                float rotateSin = sin(_RotateDistance);
                float2x2 rotateMatrix = float2x2(float2(rotateCos, rotateSin),
                                                 float2(-rotateSin, rotateCos));

                for (int index = 0; index < _SampleCount; index++)
                {
                    singleWeight += 1 / singleWeight;
                    offset = mul(rotateMatrix, offset);
                    fixed4 color = tex2D(_MainTex, i.uv + offset * _MainTex_TexelSize.xy * (1 - singleWeight));
                    finalColor += color ;
                    totalWeight += 1;
                }

                float4 blurColor = finalColor / totalWeight;
                float4 texColor = tex2D(_MainTex, i.uv);
                float blurStrength=gridentUV(i.uv);
                return blurColor *blurStrength +(1-blurStrength)*texColor;
            }
            ENDCG
        }
    }
}