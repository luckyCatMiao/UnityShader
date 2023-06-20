Shader "LX/DirectionalBlur"
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            int _Iteration;
            float2 _Direction;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                float totalWeight=0;
                for(int index=0;index<_Iteration;index++)
                {
                    float weight=(float)1/(index+1);
                    totalWeight+=weight;
                    col+=tex2D(_MainTex,i.uv+index*_Direction*_MainTex_TexelSize.xy)*weight;
                }
                return col/totalWeight;
            }
            ENDCG
        }
    }
}