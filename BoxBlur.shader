Shader "LX/BoxBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SampleCount("SampleCount",int)=3
        _BlurSize("BlurSize",float)=1
    }
    SubShader
    {
       
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform int _SampleCount;
            uniform float _BlurSize;
            uniform float _StartIndex;
            uniform float _EndIndex;
            uniform float _SamplePercent;

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
            uniform half4 _MainTex_TexelSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 finalColor = fixed4(0, 0, 0, 1);
                for (int y = _StartIndex; y <= _EndIndex; y++)
                {
                    for (int x = _StartIndex; x <= _EndIndex; x++)
                    {
                        fixed2 finalUV = i.uv + fixed2(x, y) * _MainTex_TexelSize.xy * _BlurSize;
                        finalColor += tex2D(_MainTex, finalUV) / _SamplePercent;
                    }
                }
                return finalColor;
            }

            
            ENDCG
        }
    }
}