Shader "LX/glass"
{
    Properties
    {
        _BumpMap ("BumpMap", 2D) = "white" {}
        _CubeMap ("CubeMap", Cube) = "_Skybox"
        _RefractionScale("RefractionScale",float)=-1
        _BumpScale("Bump Scale",float)=-1
        _RefractionAmount("RefractionAmount",float)=0.5
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Opaque"
        }

        GrabPass
        {
            "_RefractionTex"
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
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float4 tangent:TEXCOORD2;
                float3 normal:TEXCOORD3;
                float4 scrPos:TEXCOORD4;
            };


            sampler2D _BumpMap;
            samplerCUBE _CubeMap;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            float _RefractionScale;
            float _RefractionAmount;

            float _BumpScale;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.tangent = v.tangent;
                o.scrPos = ComputeGrabScreenPos(o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldViewDir = UnityWorldSpaceViewDir(i.worldPos);

                //从法线贴图中获取法线方向，此时在切线空间下
                fixed3 normal = UnpackNormal(tex2D(_BumpMap, i.uv));
                //使用Bumpscale控制凹凸程度 因为(0,0,1)表示原法线，因为在法线的xy上乘上某个倍数就代表在原偏移方向更加偏移
                normal.xy *= _BumpScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));

                //折射
                float2 offset = normal.xy * _RefractionScale;
                i.scrPos.xy = offset + i.scrPos.xy;
                fixed3 refractionCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;


                //转换到模型空间的矩阵
                float3x3 tangent2Object =
                {
                    i.tangent.xyz * i.tangent.w,
                    cross(i.tangent * i.tangent.w, i.normal),
                    i.normal
                };
                tangent2Object = transpose(tangent2Object);
                fixed3 worldNormal = UnityObjectToWorldNormal(mul(tangent2Object, normal));

                //反射
                float3 reflectionDir = normalize(reflect(-worldViewDir, worldNormal));
                float3 reflectionColor = texCUBE(_CubeMap, reflectionDir);

                //混合反射和折射
                return fixed4(refractionCol*_RefractionAmount + (1-_RefractionAmount)*reflectionColor, 1);
            }
            ENDCG
        }
    }
}