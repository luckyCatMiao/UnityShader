Shader "UIShader/HotMap"
{
    Properties
    {
        _LowColor("LowColor",Color)=(0,1,0,1)
        _MidColor("MidColor",Color)=(1,1,0,1)
        _HighColor("HighColor",Color)=(1,0,0,1)


        //0,1,2 对应低中高的颜色
        _Area1("Area1",int)=0
        _Area2("Area2",int)=0
        _Area3("Area3",int)=0
        _Area4("Area4",int)=0
        _Area5("Area5",int)=0
        _Area6("Area6",int)=0

        _MergeStart("MergeStart",int)=0

        _LineColor("LineColor",Color)=(0,0,0,1)
        _LineWidth("LineWidth",float)=0.1

        _MergeColor("MergeColor",Color)=(1,0,0,1)
        _MergeColorOffset("MergeColorOffset",int)=0

        _Mask("Mask",2D)="white"
        _AtlasUV("AtlasUV",Vector)=(0,0,1,1)
        [Toggle]_Rotated("Rotated",int)=0 
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
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

            uniform fixed4 _LowColor;
            uniform fixed4 _MidColor;
            uniform fixed4 _HighColor;


            uniform int _Area1;
            uniform int _Area2;
            uniform int _Area3;
            uniform int _Area4;
            uniform int _Area5;
            uniform int _Area6;

            uniform fixed _MergeStart;

            uniform fixed4 _LineColor;
            uniform fixed _LineWidth;

            uniform fixed4 _MergeColor;
            uniform fixed _MergeColorOffset;

            uniform sampler2D _Mask;
            uniform fixed4 _AtlasUV;

            uniform bool _Rotated;

            #define _AtlasUVStartX _AtlasUV.x
            #define _AtlasUVStartY _AtlasUV.y
            #define _AtlasUVEndX _AtlasUV.z
            #define _AtlasUVEndY _AtlasUV.w

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                fixed alpha=tex2D(_Mask,i.uv).a;
  
                 //原图在fairyUI里的图集uv需要扩展到0~1的uv
                 if(_Rotated)
                 {
                     i.uv.x=(i.uv.y-_AtlasUVStartY)/(_AtlasUVEndY-_AtlasUVStartY);
                     i.uv.y= (i.uv.x-_AtlasUVStartX)/(_AtlasUVEndX-_AtlasUVStartX);
                 }
                 else
                 {
                     i.uv.x=(i.uv.x-_AtlasUVStartX)/(_AtlasUVEndX-_AtlasUVStartX);
                     i.uv.y=(i.uv.y-_AtlasUVStartY)/(_AtlasUVEndY-_AtlasUVStartY);
                 }
                
                 float areas[] = {_Area1, _Area2, _Area3, _Area4, _Area5, _Area6};
                 fixed4 colors[] = {_LowColor, _MidColor, _HighColor};
                
                 fixed area = floor(i.uv.x * 6);
                 fixed areaX = i.uv.x * 6 % 1;
                 fixed lastArea = max(area - 1, 0);
                 fixed nextArea = min(area + 1, 5);
                 fixed4 lastAreaColor = colors[areas[lastArea]];
                 fixed4 curAreaColor = colors[areas[area]];
                 fixed4 nextAreaColor = colors[areas[nextArea]];
                
                 fixed4 lastAndMidMergeColor = lerp(lastAreaColor, curAreaColor, 0.5f); //前一个区域和当前区域的均匀混色
                 fixed4 midAndNextMergeColor = lerp(curAreaColor, nextAreaColor, 0.5f); //当前区域和下一个区域的均匀混色
                
                 lastAndMidMergeColor = lerp(lastAndMidMergeColor, _MergeColor,_MergeColorOffset);
                 midAndNextMergeColor = lerp(midAndNextMergeColor, _MergeColor,_MergeColorOffset);
                
                 fixed4 finalColor;
                 //在当前区域的前半部分，和上一区域的颜色混合，在当前区域的下半，和下一区域的颜色混合
                 fixed startMergeLeftX = 0.5 * _MergeStart;
                 fixed startMergeRightX = 1 - 0.5 * _MergeStart;
                 if (areaX < startMergeLeftX)
                 {
                     if (area == 0) finalColor = curAreaColor;
                     else finalColor = lerp(lastAndMidMergeColor, curAreaColor, areaX * (1 / startMergeLeftX));
                 }
                 else if (areaX > startMergeRightX)
                 {
                     if (area == 5) finalColor = curAreaColor;
                     else
                         finalColor = lerp(curAreaColor, midAndNextMergeColor,
                                           (areaX - startMergeRightX) / (1 - startMergeRightX));
                 }
                 else
                 {
                     finalColor = curAreaColor;
                 }
                
                fixed4 color=saturate(step(1 - _LineWidth, areaX) + step(areaX, _LineWidth)) * _LineColor + finalColor *
                     step(areaX, 1 - _LineWidth) * step(_LineWidth, areaX);
                //遮罩
                color.a=alpha;
                
                
                return color;
                
          
            }
            ENDCG
        }
    }
}