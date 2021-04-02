Shader "LX/VolumeFog"
{
    Properties
    {
        Intensity("Intensity",range(0,30))=1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Geometry+600"
        }
        pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            Blend One OneMinusSrcColor
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : POSITION;
                float4 scr:TEXCOORD1;
                float4 center:TEXCOORD2;
                float4 vp:TEXCOORD3;
            };

            sampler2D MainTex;
            float Intensity;

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scr = o.pos;
                float4 center = UnityObjectToClipPos(float4(0, 0, 0, 1)); //
                float4 vp = UnityObjectToClipPos(v.vertex);
                o.center = center;
                o.vp = vp;
                return o;
            }


            float4 frag(v2f i) : COLOR
            {
                float3 center = i.center.xyz / i.center.w;
                float3 vp = i.vp.xyz / i.vp.w;
                center = vp - center;
                float dc = max(0,1 - length(center));
                dc = pow(dc, 6);
                dc = dc * Intensity;
                dc = dc / (1 + dc);
                return fixed4(dc, dc, dc, dc);
            }
            ENDCG
        }
    }
    FallBack Off
}