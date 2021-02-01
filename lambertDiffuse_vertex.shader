// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LX/lambertDiffuse_perVert"
{
    Properties
    {
        _Color("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;
            struct a2v
            {
                float4 vertex : POSITION;
                float2 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color:COLOR;
            };

         
            v2f vert (a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                //获取在unity编辑器中定义的环境光
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                //把顶点法线变换到世界坐标系下
                fixed3 worldNormal=normalize(mul((float3x3)unity_ObjectToWorld,v.normal));
                //获取光照方向
                fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse=unity_LightColor0.rgb*_Color.rgb*saturate(dot(worldNormal,worldLight));
                
                o.color=diffuse+ambient;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}
