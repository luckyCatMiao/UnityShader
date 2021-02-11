Shader "LX/adjustImg"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZTest Always
        Cull Off
        Zwrite Off

        
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half brightness;
            half saturation;
            half contrast;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col*=brightness;
                fixed luminance=0.2125*col.r+0.7154*col.g+0.0721*col.b;
                fixed3 finalColor=lerp(luminance,col,saturation);
                fixed3 avgColor=fixed3(0.5,0.5,0.5);
                finalColor=lerp(avgColor,finalColor,contrast);
                
                return fixed4(finalColor,col.a);
            }
            ENDCG
        }
    }
}
