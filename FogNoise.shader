Shader "LX/FogNoise"
{
    Properties
    {
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _MainTex ("Texture", 2D) = "white" {}
        _FogColor ("FogColor", Color) =(1,1,1,1)
        _FogDensity ("FogDensity", float) =1
        _FogStart ("FogStart", float) =0
        _FogEnd ("FogEnd", float) =1
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

            uniform float3 rayTopLeft;
            uniform float3 rayTopRight;
            uniform float3 rayBottomLeft;
            uniform float3 rayBottomRight;

            uniform sampler2D _CameraDepthTexture;
            uniform sampler2D _NoiseTex;

            uniform float4 _FogColor;
            uniform float _FogStart;
            uniform float _FogEnd;
            uniform float _FogDensity;
            uniform float2 _NoiseSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray:TEXCOORD01;
            };

            float3 uvToRay(fixed2 uv)
            {
                if (uv.x < 0.5 && uv.y < 0.5)
                {
                    return rayBottomLeft;
                }
                else if (uv.x < 0.5 && uv.y > 0.5)
                {
                    return rayTopLeft;
                }
                else if (uv.x > 0.5 && uv.y > 0.5)
                {
                    return rayTopRight;
                }
                else if (uv.x > 0.5 && uv.y < 0.5)
                {
                    return rayBottomRight;
                }

                return fixed3(0, 0, 0);
            }


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //给四个顶点分别赋值一个方向，片元所对应的方向则通过自动插值得到
                o.ray = uvToRay(v.uv);

                return o;
            }

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            fixed4 frag(v2f i) : SV_Target
            {
                half rayLength = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));
                fixed4 col = tex2D(_MainTex, i.uv);
                //还原世界坐标
                float3 worldPos = _WorldSpaceCameraPos + i.ray * rayLength;

                float fogDensity = (saturate((worldPos.y - _FogStart) / (_FogEnd - _FogStart))) * _FogDensity;
                float noise = tex2D(_NoiseTex, i.uv + _Time.y * _NoiseSpeed * _MainTex_TexelSize.xy);
                fogDensity *= noise;

                return (1 - fogDensity) * col + fogDensity * _FogColor;
            }
            ENDCG
        }
    }
}