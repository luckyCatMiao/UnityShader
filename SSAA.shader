//SSAA抗锯齿shader
Shader "LX/SSAA"
{
    Properties
    {
        _MainTex("Base(RGB)",2D)="white"{}
        _Size("Size",Range(0.1,2.0))=1.0
        _SobelSize("SobelSize",Range(0.1,1.0))=1.0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _Size;
            float _SobelSize;
            #pragma vertex vert
            #pragma fragment frag

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv[9]:TEXCOORD0;
            };

            //取灰度的方法，返回一个颜色的灰度值
            float luminance(float4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            //索贝尔算子求得当前像素点是否是边缘
            float Sobel(v2f i)
            {
                const float Gx[9] = {
                    -1, -2, -1,
                    0, 0, 0,
                    1, 2, 1
                };

                const float Gy[9] = {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };
                float texColor;
                float edgeX = 0;
                float edgeY = 0;
                for (int it = 0; it < 9; it++)
                {
                    //取灰度
                    texColor = luminance(tex2D(_MainTex, i.uv[it]));
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }
                float edge = 1 - abs(edgeX) - abs(edgeY);
                //值越小证明在边缘（和周边像素颜色差距大）
                return edge;
            }

            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float2 uv = v.texcoord;
                //像素周围八个点和自身
                o.uv[0] = uv + _MainTex_TexelSize.xy * float2(-1, -1) * _SobelSize;
                o.uv[1] = uv + _MainTex_TexelSize.xy * float2(0, -1) * _SobelSize;
                o.uv[2] = uv + _MainTex_TexelSize.xy * float2(1, -1) * _SobelSize;
                o.uv[3] = uv + _MainTex_TexelSize.xy * float2(-1, 0) * _SobelSize;
                o.uv[4] = uv + _MainTex_TexelSize.xy * float2(0, 0) * _SobelSize;
                o.uv[5] = uv + _MainTex_TexelSize.xy * float2(1, 0) * _SobelSize;
                o.uv[6] = uv + _MainTex_TexelSize.xy * float2(-1, 1) * _SobelSize;
                o.uv[7] = uv + _MainTex_TexelSize.xy * float2(0, 1) * _SobelSize;
                o.uv[8] = uv + _MainTex_TexelSize.xy * float2(1, 1) * _SobelSize;

                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float edge = Sobel(i);
                //采用了旋转网格采样，最佳的旋转角度是arctan (1/2) (大约 26.6°)
                //也可以采取别的采样方法，网上有很多算法
                float4 c0 = tex2D(_MainTex, i.uv[4] + float2(0.2 / 2, 0.8) * _Size * _MainTex_TexelSize);
                float4 c1 = tex2D(_MainTex, i.uv[4] + float2(0.8 / 2, -0.2) * _Size * _MainTex_TexelSize);
                float4 c2 = tex2D(_MainTex, i.uv[4] + float2(-0.2 / 2, -0.8) * _Size * _MainTex_TexelSize);
                float4 c3 = tex2D(_MainTex, i.uv[4] + float2(-0.8 / 2, 0.2) * _Size * _MainTex_TexelSize);

                float4 mainColor = tex2D(_MainTex, i.uv[4]);
                float4 color = (c0 + c1 + c2 + c3) * 0.25;
                //按边缘比重插值采样平均色和原颜色
                return lerp(color, mainColor, edge);
            }
            ENDCG
        }

    }
}