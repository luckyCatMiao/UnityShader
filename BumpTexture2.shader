Shader "LX/BumpTexture2"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _EmissiveColor("EmissiveColor",Color)=(0,0,0,0)
        _Speclur("Speclur",int)=2

        _Texture("Texture",2d)="white"{}
        _BumpTexture("Bump Texture",2d)="white"{}
        _BumpScale("Bump Scale",float)=-1

    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            float4 _EmissiveColor;
            float _Speclur;

            sampler2D _Texture;
            float4 _Texture_ST;

            sampler2D _BumpTexture;
            float _BumpScale;
            


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv:TEXCOORD0;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uvMain:TEXCOORD2;
                float4 tangent:TEXCOORD3;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _Texture);
                o.normal = v.normal;
                o.tangent = v.tangent;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 texColor = tex2D(_Texture, i.uvMain);
                //从法线贴图中获取法线方向，此时在切线空间下
                float3 normal = UnpackNormal(tex2D(_BumpTexture, i.uvMain));
                //使用Bumpscale控制凹凸程度
                normal.xy*=_BumpScale;
                normal.z=sqrt(1-saturate(dot(normal.xy,normal.xy)));
                //转换到模型空间的矩阵
                float3x3 tangent2Object =
                {
                    i.tangent.xyz*i.tangent.w,
                    cross(i.tangent*i.tangent.w, i.normal),
                    i.normal
                };
                tangent2Object=transpose(tangent2Object);
                normal = mul(tangent2Object, normal);

                //最终获得在世界坐标下的法线
                float3 worldNormal = normalize(UnityObjectToWorldNormal(normal));
                //使用内置宏获取当前片元到光源的方向,里面已经处理了不同光源
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //世界坐标下的视角方向
                float3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //光线在当前片元对应的法线下的反射方向
                float3 worldLightReflectDir = normalize(reflect(-worldLightDir, worldNormal));


                //环境光分量，直接用宏定义获取 此值是在unity编辑器内的光照窗口设定
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color;
                //漫反射分量，使用表面法线点乘光源方向
                float3 diffuse = max(0, dot(worldNormal, worldLightDir)) * _Color;
                //高光分量，使用视角方向点乘光的反射方向
                float3 speclur = pow(max(0, dot(worldLightReflectDir, worldViewDir)), _Speclur) * _Color;
                //自发光分量，直接使用设定值
                float3 emissive = _EmissiveColor.xyz;


                return fixed4((ambient + diffuse + speclur + emissive) * texColor, 1);
            }
            ENDCG
        }
    }
}