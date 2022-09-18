Shader "LX/Sharpen2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Intensity("Intensity", Range(0, 20)) = 2
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
            fixed4 _MainTex_TexelSize;
            float _Intensity;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 offset=fixed2(_MainTex_TexelSize.x,_MainTex_TexelSize.y);
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col1 = tex2D(_MainTex, i.uv+fixed2(0,1)*offset);
                fixed4 col2 = tex2D(_MainTex, i.uv+fixed2(1,0)*offset);
                fixed4 col3 = tex2D(_MainTex, i.uv+fixed2(0,-1)*offset);
                fixed4 col4 = tex2D(_MainTex, i.uv+fixed2(-1,0)*offset);
                fixed4 average=(col1+col2+col3+col4)/4;
               
                return col+col*_Intensity-average*_Intensity;
            }
            ENDCG
        }
    }
}