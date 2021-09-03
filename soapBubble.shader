Shader "LX/soapBubble"
{
    Properties
    {
        _ColorTex ("ColorTex", 2D) = "white" {}
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Alpha ("Alpha", float) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent"
        }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vertexDataFunc keepalpha
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _ColorTex;
        float _Alpha;

        void vertexDataFunc(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float3 value = (cos(5.0 * v.vertex.y + _Time.y) * 0.015 + sin(5.0 * v.vertex.y + _Time.y) * 0.005).xxx;
            v.vertex.xyz += value;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed2 newUV = tex2D(_MainTex, IN.uv_MainTex + _Time.x * fixed2(1, 1) * 0.5).rr;
            fixed4 c = tex2D(_ColorTex, newUV);
            o.Albedo = c.rgb;
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}