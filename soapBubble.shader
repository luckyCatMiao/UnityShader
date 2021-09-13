Shader "LX/soapBubble"
{
    Properties
    {
        _ColorTex ("ColorTex", 2D) = "white" {}
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Alpha ("Alpha", float) = 0.5
        _RimColor ("RimColor", color) = (1,1,1,1)
        _NormalTex ("NormalTex", 2D) = "white"
        _NormalScale ("NormalScale", float) = 1
        _Distortion("Distortion",float) = 1
        _Smoothness("Smoothness", float) = 0.8
        _Specular("Specular", float) = 0.5
        _UVScale("UVScale", float) = 4
        _UVOffset("UVOffset", float) = 0
        _RimPow("RimPow", float) = 2
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent"
        }
        LOD 200

        GrabPass
        {
            "_RefractionTex"
        }

        Cull Back
        CGPROGRAM
        #pragma surface surf StandardSpecular fullforwardshadows vertex:vertexDataFunc keepalpha
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            INTERNAL_DATA
            float3 worldPos;
            float4 screenPos;
        };

        float _Specular;
        sampler2D _ColorTex;
        float _Alpha;
        fixed4 _RimColor;
        sampler2D _NormalTex;
        float _NormalScale;
        float _Distortion;

        sampler2D _RefractionTex;
        float4 _RefractionTex_TexelSize;
        float _Smoothness;

        float _UVScale;
        float _RimPow;
        float _UVOffset;

        void vertexDataFunc(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float3 value = (cos(5.0 * v.vertex.y + _Time.y) * 0.015 + sin(5.0 * v.vertex.y + _Time.y) * 0.005).xxx;
            v.vertex.xyz += value;
        }

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            //rim
            float3 worldViewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float rimValue = 1 - pow(dot(worldViewDir, IN.worldNormal), _RimPow);

            //重新映射uv
            fixed2 newUV = tex2D(_MainTex, (IN.uv_MainTex + _SinTime.x * fixed2(1, 1)) * _UVScale).rr;
            fixed4 c = tex2D(_ColorTex, saturate(newUV + fixed2(_UVOffset, _UVOffset)));

            //折射
            fixed3 bump = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex.xy)).rgb;
            bump.xy *= _NormalScale;
            bump = normalize(bump);
            IN.screenPos.xyz /= IN.screenPos.w;
            float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
            fixed3 refrCol = tex2D(_RefractionTex, IN.screenPos.xy + offset).rgb;

            o.Albedo = (c.rgb * rimValue + refrCol * (1 - rimValue)) * _Alpha;
            o.Emission = rimValue * _RimColor * _Alpha;
            o.Smoothness = _Smoothness;
            o.Specular = _Specular;
        }
        ENDCG
    }
    FallBack "Diffuse"
}