Shader "LX/billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _VerticalScale ("_VercitalScale", float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "DisableBatching"="True"
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _VerticalScale;

            v2f vert(appdata v)
            {
                v2f o;

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //在模型空间做计算
                float3 center = float3(0, 0, 0);
                float3 cameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

                //计算出模型空间的朝向摄像机的向量
                float3 normalDir = cameraPos - center;
                normalDir.y = normalDir.y * _VerticalScale;
                normalDir = normalize(normalDir);
                //向上向量
                float3 upDir = float3(0, 1, 0);
                //叉积得到向右向量
                float3 rightDir = normalize(cross(upDir, normalDir));
                //重新得到正交的向上向量
                upDir = normalize(cross(normalDir, rightDir));

                //根据新的正交基得到顶点的新位置
                float3 newPos = rightDir * v.vertex.x + upDir * v.vertex.y + normalDir * v.vertex.z;
                o.vertex = UnityObjectToClipPos(newPos);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}