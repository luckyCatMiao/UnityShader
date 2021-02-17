Shader "LX/Blinn-Phong"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _EmissiveColor("EmissiveColor",Color)=(0,0,0,0)
        _Speclur("Speclur",int)=10

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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //使用内置宏获取当前片元到光源的方向,里面已经处理了不同光源
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                //世界坐标下的法线
                float3 worldNormal = normalize(i.worldNormal);
                //世界坐标下的视角方向
                float3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //blinn-phong模型下的新变量 光照方向加上视角方向之后归一化
                float3 halfDir = normalize(worldLightDir+worldViewDir);


                //环境光分量，直接用宏定义获取 此值是在unity编辑器内的光照窗口设定
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Color;
                //漫反射分量，使用表面法线点乘光源方向
                float3 diffuse = max(0, dot(worldNormal, worldLightDir)) * _Color;
                //高光分量，使用视角方向点乘光的反射方向
                float3 speclur = pow(max(0, dot(halfDir, worldNormal)),_Speclur) * _Color;
                //自发光分量，直接使用设定值
                float3 emissive = _EmissiveColor.xyz;


                return fixed4(ambient + diffuse + speclur+emissive, 1);
            }
            ENDCG
        }
    }
}