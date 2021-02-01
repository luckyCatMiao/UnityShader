// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LX/Test2"
{
    SubShader
    {
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 vert(float4 v:POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(v);
            }

            fixed4 frag():SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }
            ENDCG

        }

    }

}