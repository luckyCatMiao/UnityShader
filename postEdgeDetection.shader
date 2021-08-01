Shader "LX/postEdgeDetection"
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
        LOD 100

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
                float4 vertex : SV_POSITION;
                half2 uv[5]: TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;

            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            float _ThresholdNormal;
            float _ThresholdDepth;


            half CheckSame(half4 sample1, half4 sample2)
            {
                float3 normal1;
                float depth1;
                DecodeDepthNormal(sample1, depth1, normal1);

                float3 normal2;
                float depth2;
                DecodeDepthNormal(sample2, depth2, normal2);


                bool normalSame = dot(normal1, normal2) > _ThresholdNormal;
                bool depthSame = abs(depth1 - depth2) < _ThresholdDepth;

                return normalSame && depthSame ? 1.0 : 0.0;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.uv;
                o.uv[0] = uv;
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, -1);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
                half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
                half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
                half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);


                half edge = CheckSame(sample1, sample2) && CheckSame(sample3, sample4);

                fixed4 color = lerp(_EdgeColor, _BackgroundColor, edge);

                return color;
            }
            ENDCG
        }
    }
}