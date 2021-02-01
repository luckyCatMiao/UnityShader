// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "LX/struct"
{
    SubShader
    {
        Pass
        {

            CGPROGRAM
            //pragma预处理指令用于设定编译器状态
            //此处为unity shader特有的指令，意思为指定顶点着色器和片元着色器的名字
            #pragma vertex vert
            #pragma fragment frag
            //为了使用UnityObjectToClipPos方法需要进行Include
            #include <UnityShaderUtilities.cginc>

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

            //希望输入的参数是一个结构体
            float4 vert(a2v v):SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            //fixed4(1, 1, 1, 1)返回白色，所以每个面的颜色相同
            fixed4 frag():SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }
            ENDCG

        }

    }

}