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

            float _OffsetHeight;
            float _OffsetSpeed;
            float _LiquidHeight;
            float _OffsetScale;

            float4 _Color;

            v2f vert(appdata v)
            {
                v.vertex.y = v.vertex.y + step(0, v.vertex.y) * (_LiquidHeight + sin(
                    _Time.x * _OffsetSpeed + v.vertex.x * _OffsetScale) * _OffsetHeight);
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}