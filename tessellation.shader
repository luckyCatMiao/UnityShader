Shader "LX/tessellation"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DispTex ("DispTex", 2D) = "white" {}
        _Displacement ("Displacement", float) = 1
        _Tess ("Tess", float) =1
        _Power ("Power", range(1,8)) =1
        _Phong ("Phong Strengh", Range(0,1)) = 0.5
        _EdgeLength ("Edge length", Range(2,50)) = 5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:disp tessellate:tessEdge tessphong:_Phong
        #pragma target 3.0
        #include "Tessellation.cginc"

        sampler2D _MainTex;
        sampler2D _DispTex;

        float _Phong;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Displacement;


        float _Tess;
        float _Power;
        float _EdgeLength;

        // float4 tessFixed()
        // {
        //     return _Tess;
        // }

        float4 tessEdge(appdata_base v0, appdata_base v1, appdata_base v2)
        {
            return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
        }

        void disp(inout appdata_base v)
        {
            float d = pow(Luminance(tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0))), _Power) * _Displacement;
            v.vertex.xyz += v.normal * d;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}