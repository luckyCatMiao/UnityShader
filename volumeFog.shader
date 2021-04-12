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
            "Queue"="Geometry"
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
                float4 center:TEXCOORD0;
                float4 vertex:TEXCOORD1;
            };

            sampler2D MainTex;
            float Intensity;

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float4 center = UnityObjectToClipPos(float4(0, 0, 0, 1));
                float4 vertex = UnityObjectToClipPos(v.vertex);
                o.vertex = vertex;
                o.center = center;

                return o;
            }


            float4 frag(v2f i) : COLOR
            {
                float2 center = i.center.xy / i.center.w;
                float2 vertex = i.vertex.xy / i.vertex.w;
                float c = 1 - length(vertex - center);
                c = pow(c, 4);
                c = lerp(0, Intensity, c);
                return fixed4(c, c, c, 0);
            }
            ENDCG
        }
    }
    FallBack Off
}