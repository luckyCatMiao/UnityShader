Shader "LX/postFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

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
                float3 direction:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;

            float _FogEnd;
            float _FogStart;
            fixed4 _FogColor;

            float4x4 _Directions;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                int index = 0;
                if (v.uv.x < 0.5 && v.uv.y < 0.5)
                {
                    index = 0;
                }
                else if (v.uv.x > 0.5 && v.uv.y < 0.5)
                {
                    index = 1;
                }
                else if (v.uv.x > 0.5 && v.uv.y > 0.5)
                {
                    index = 2;
                }
                else
                {
                    index = 3;
                }

                o.direction = _Directions[index];

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));
                float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.direction;

                float fogDensity = saturate((_FogEnd - worldPos.y) / (_FogEnd - _FogStart));

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 finalColor = lerp(col, _FogColor, fogDensity);


                return finalColor;
            }
            ENDCG
        }
    }
}