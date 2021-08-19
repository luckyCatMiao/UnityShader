Shader "Test/Water2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DeepColor("DeepColor",Color)=(0,0,1,1)
        _ShallowColor("ShallowColor",Color)=(0,0,0.5,1)
        _StartDepth("StartDepth",float)=1
        _ChangeSpeed("ChangeSpeed",float)=1
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"
        }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _CameraDepthTexture;

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _DeepColor;
            fixed4 _ShallowColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 screenPos = ComputeScreenPos(i.vertex);
                screenPos.xy /= screenPos.w;

                //水底的深度值，使用深度纹理计算,转换成linearEyeDepth，最后得出的结果其实就是水底顶点在摄像机空间的z值
                float underWaterDepth=LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,screenPos.xy));
               
                //水面的深度值，使用该点在摄像机空间中的z值，这个z值即顶点屏幕空间坐标的w值(如果不理解可以看下坐标空间的变换过程)
                float surfaceWaterDepth=screenPos.w;

                //计算得到深度插值，来对水面颜色进行插值
                float depthDifference=abs(underWaterDepth-surfaceWaterDepth);

                fixed4 col = lerp(_DeepColor,_ShallowColor,depthDifference/100);
                return fixed4(col.rgb,0.5f);
            }
            ENDCG
        }
    }
}