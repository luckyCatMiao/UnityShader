Shader "LX/Liquid"
{
    Properties
    {
        _Color ("Color", color) = (0,0,1,1)
        _OffsetHeight ("OffsetHeight", float) = 0.5
        _OffsetSpeed ("OffsetSpeed", float) = 1
        _LiquidHeight("LiquidHeight", float) = 0
         _OffsetScale ("OffsetScale", float) = 1
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD2;
                float3 worldCenterPos:TEXCOORD3;
            };

            float _OffsetHeight;
            float _OffsetSpeed;
            float _LiquidHeight;
            float _OffsetScale;

            float4 _Color;

            v2f vert(appdata v)
            {
                v.vertex.y = v.vertex.y + step(0,v.vertex.y)*(_LiquidHeight + sin(_Time.x * _OffsetSpeed + v.vertex.x*_OffsetScale) * _OffsetHeight);
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldCenterPos = mul(unity_ObjectToWorld,fixed3(0, 0, 0));
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //计算该点的世界y值和模型空间原点的y值的差值，超过阈值后丢弃
                float difference = i.worldPos.y - i.worldCenterPos.y;

                // sample the texture
                fixed4 col = _Color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}