Shader "LX/Led"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UVCenter ("UVCenter", Vector) = (0.5,0.5,0,0)
        _VCount ("VCount", float) = 2
        _HCount ("HCount", float) = 2
    }
    SubShader
    {
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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            fixed2 _UVCenter;
            float _VCount;
            float _HCount;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed2 uv = frac(i.uv * fixed2(_HCount,_VCount));
                fixed len = saturate(length(uv - _UVCenter) * 1.4);
                return col * (1 - len);
            }
            ENDCG
        }
    }
}