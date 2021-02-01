// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "LX/struct"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            //pragma预处理指令用于设定编译器状态
            //此处为unity shader特有的指令，意思为指定顶点着色器和片元着色器的名字
            #pragma vertex vert
            #pragma fragment frag
            //include unity提供的帮助文件
            #include <UnityShaderUtilities.cginc>

            fixed4 _Color;
            //声明一个结构体，设为参数后就会作为顶点着色器的输入
            struct a2v
            {
                //模型空间顶点坐标
                float4 vertex:POSITION;
                //模型空间顶点法线
                float3 normal:NORMAL;
                //模型纹理坐标
                float4 texcoord:TEXCOORD0;
            };

            //顶点着色器的输出
            struct v2f
            {
                //裁剪空间中的顶点坐标
                float4 position:SV_POSITION;
                //颜色信息
                fixed3 color:COLOR0;
            };


            //希望输入的参数是一个结构体
            v2f vert(a2v v)
            {
                v2f data;
                data.position = UnityObjectToClipPos(v.vertex);
                //将法线映射为颜色，因为法线和颜色都可以看成三维单位向量，所以可以映射
                data.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return data;
            }


            fixed4 frag(v2f i):SV_Target
            {
                //返回上一步得出的颜色
                return fixed4(i.color*_Color.rgb, 1);
            }
            ENDCG

        }

    }

}