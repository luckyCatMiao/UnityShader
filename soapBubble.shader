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

        void vertexDataFunc(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float3 value = (cos(5.0 * v.vertex.y + _Time.y) * 0.015 + sin(5.0 * v.vertex.y + _Time.y) * 0.005).xxx;
            v.vertex.xyz += value;
        }

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            float3 worldViewDir = normalize(UnityWorldSpaceViewDir(IN.worldPos));
            float rimValue = 1 - pow(dot(worldViewDir, IN.worldNormal), 2);
            fixed2 newUV = tex2D(_MainTex, IN.uv_MainTex + _SinTime.x * fixed2(1, 1) * 0.5).rr + abs(
                IN.uv_MainTex.x * 2.0 + -1.0) * 0.5;
            fixed4 c = tex2D(_ColorTex, newUV*4);

            //法线
            fixed3 bump = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex.xy)).rgb;
            bump.xy *= _NormalScale;
            bump = normalize(bump);
            IN.screenPos.xyz /= IN.screenPos.w;
            float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
            fixed3 refrCol = tex2D(_RefractionTex, IN.screenPos.xy + offset).rgb;

            o.Albedo = c.rgb * refrCol * _Alpha;
            o.Emission = rimValue * _RimColor * _Alpha;
            o.Smoothness = _Smoothness;
            o.Specular=_Specular;
           
        }
        ENDCG
    }
    FallBack "Diffuse"
}