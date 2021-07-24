Shader "LX/water"
{
    Properties
    {
        _Color("Main Color",Color) = (0,0.15,0.115,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _WaveMap ("Wave Map", 2D) = "bump" {} // 噪声纹理生成的法线纹理
        _Cubemap ("Environment Cubemap",Cube) = "_Skybox" {}
        _WaveXSpeed("Wave Horizontal Speed",Range(-0.1,0.1)) = 0.01
        _WaveYSpeed("Wave Vertical Speed",Range(-0.1,0.1)) = 0.01
        _Distortion("Distortion",Range(0,100)) = 10
    }
    SubShader
    {
        //"Queue" = "TransParent" 要保证所有不透明的物体都已经渲染过了
        Tags { "Queue" = "TransParent"  "RenderType"="Opaque" }
        //传入一个名字，以告诉Unity抓取的屏幕像素存放在什么变量中
        GrabPass{"_RefractionTex"}
        pass{
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _WaveMap;
            float4 _WaveMap_ST;
            samplerCUBE _Cubemap;
            fixed _WaveXSpeed;
            fixed _WaveYSpeed;
            float _Distortion;	

            // 这个变量对应GrabPass传入的参数
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; 
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;  
                float4 TtoW1 : TEXCOORD3;  
                float4 TtoW2 : TEXCOORD4; 
            };
            
            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //抓取屏幕图像的采样坐标，ComputeGrabScreenPos帮我们做好了不同平台的差异性处理
                o.scrPos = ComputeGrabScreenPos(o.pos);
                //自动根据面板中的uv设置，取出对应顶点的纹理坐标
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_WaveMap);
                //在世界空间下计算后续的表现，所以要生成一个切线空间到世界空间的变换矩阵
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
                //通过xyz三轴纵排列的方式，组装矩阵。并合理利用寄存器空间，把世界坐标放到最后一位
                o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                float2 speed = _Time.y * float2(_WaveXSpeed,_WaveYSpeed);
                //bump是什么来着? tex2D从法线贴图中取出法线向量，UnpackNormal是对rgb存向量的一个逆转换，一般情况下是2*v-1
                fixed3 bump1 = UnpackNormal(tex2D(_WaveMap,i.uv.zw + speed)).rgb;
                fixed3 bump2 = UnpackNormal(tex2D(_WaveMap,i.uv.zw - speed)).rgb;
                fixed3 bump = normalize(bump1 + bump2);

                // 这里做出的折射效果与前面Refraction的不同，这里是直接通过对屏幕颜色采样，然后扭曲，得到的一个近似折射的效果
                // Refraction则是使用折射率，折射角，观察角度等一系列参数模拟出的物理折射
                // 需要提醒注意的是，这里bump是切线空间下法线
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;//通过纹理的坐标的采样偏移，来模拟折射
                //书上说i.scrPos.xy/i.scrPos.w这里使用了透视除法来获得真正的屏幕坐标? 4.9.3节，妈的，学着后面忘着前面，难顶啊
                //回顾一下，透视除法，也就是4.6.8中的齐次除法，即用xy分量除以w分量以达到将xy分布到[-1,1]的范围内的目的
                fixed3 refrCol = tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;

                bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                
                fixed3 reflDir = reflect(-worldViewDir,bump);
                fixed4 texColor = tex2D(_MainTex,i.uv.xy);
                fixed3 reflCol = texCUBE(_Cubemap,reflDir).rgb*texColor.rgb;
                //这里使用的是fresnel折射，即角度小反射，角度大折射（观察方向与水面的角度）
                fixed3 fresnel = pow(1-dot(worldViewDir,bump),4);
                fixed3 finalColor = reflCol * fresnel + refrCol * (1-fresnel);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
}
