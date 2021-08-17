Shader "LX/WallGen"
{
    Properties
    {
        _FrontTex ("FrontTex", 2D) = "white" {}
        _BackTex ("BackTex", 2D) = "white" {}
        _XTiles("XTiles",int)=4
        _YTiles("YTiles",int)=4
        _XGap("XGap",range(0,1))=0.1
        _YGap("YGap",range(0,1))=0.1
        _Offset("_Offset",float)=0
        _StartOffset("_StartOffset",float)=0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


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

            sampler2D _FrontTex;
            float4 _FrontTex_ST;
            sampler2D _BackTex;
            float4 _BackTex_ST;

            float _XTiles;
            float _YTiles;

            float _XGap;
            float _YGap;

            float _Offset;
            float _StartOffset;

            v2f vert(appdata v)
            {
                v2f o;
                
                o.uv = TRANSFORM_TEX(v.uv, _FrontTex);

                //求出现在是在哪一行，用来进行偏移
                float lineValue = floor(v.uv.y * _YTiles);

                //求余之后和阈值比较，判断该位置应该采集哪个纹理 xValue加上y值是要形成每行的偏移效果，然后还要再加上起始偏移
                float xValue = frac((v.uv.x + lineValue * _Offset + _StartOffset) * _XTiles);
                float yValue = frac(v.uv.y * _YTiles);

                float isFront = step(1 - _XGap, xValue) || step(1 - _YGap, yValue);
                v.vertex.z+=-0.1f*isFront;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //求出现在是在哪一行，用来进行偏移
                float lineValue = floor(i.uv.y * _YTiles);

                //求余之后和阈值比较，判断该位置应该采集哪个纹理 xValue加上y值是要形成每行的偏移效果，然后还要再加上起始偏移
                float xValue = frac((i.uv.x + lineValue * _Offset + _StartOffset) * _XTiles);
                float yValue = frac(i.uv.y * _YTiles);

                float isFront = step(1 - _XGap, xValue) || step(1 - _YGap, yValue);

                fixed4 frontCol = tex2D(_FrontTex, i.uv);
                fixed4 backCol = tex2D(_BackTex, i.uv);

                //法线贴图


                //顶点偏移


                return lerp(frontCol, backCol, isFront);
            }
            ENDCG
        }
    }
}