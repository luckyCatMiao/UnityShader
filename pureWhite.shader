// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
Shader "LX/pureWhite"
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

            //Position代表希望输入的值是顶点坐标
            //SV_POSITION代表裁剪空间中顶点的坐标
            float4 vert(float4 v:POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(v);
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