Shader "LX/simpleWater"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,1,1)
        _EdgeColor ("EdgeColor", Color) = (0,1,1,1)
        _EdgeThreshold ("EdgeThreshold", float) =0.1
        _WaveHeight ("WaveHeight", float) = 1
        _WaveSpeed ("WaveSpeed", float) = 1
        _WaveGap ("WaveGap", float) = 1
        _FoamTex ("FoamTex", 2D) = "white"
        _FoamThreshold ("FoamThreshold", float) =0.1
        _FoamColorScale ("FoamColorScale", float) =0.2
        _FoamSpeed ("FoamSpeed", float) =0.1
        _NormalTex ("NormalTex", 2D) = "white"
        _NormalScale ("NormalScale", float) = 1
        _NormalSpeed ("NormalSpeed", float) = 1
        _Distortion("Distortion",float) = 1


    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"
        }
        LOD 200

        GrabPass
        {
            "_RefractionTex"
        }
        CGPROGRAM
        #pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_FoamTex;
            float4 screenPos;
        };

        sampler2D _CameraDepthTexture;
        fixed4 _Color;
        fixed4 _EdgeColor;
        float _WaveHeight;
        float _WaveSpeed;
        float _WaveGap;
        float _EdgeThreshold;
        float _FoamThreshold;
        sampler2D _FoamTex;
        float _FoamColorScale;
        sampler2D _NormalTex;
        float _NormalScale;
        float _NormalSpeed;
        float _FoamSpeed;
        float _Distortion;

        sampler2D _RefractionTex;
        float4 _RefractionTex_TexelSize;

        void vertexDataFunc(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            fixed height = sin(_Time.y * _WaveSpeed + v.vertex.z * _WaveGap + v.vertex.x) * _WaveHeight;
            v.vertex.xyz += v.normal * height;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            IN.screenPos.xyz /= IN.screenPos.w;
            //深度纹理中的深度
            float depth1 = LinearEyeDepth(tex2D(_CameraDepthTexture, IN.screenPos.xy).r);
            //当前顶点的深度
            float depth2 = LinearEyeDepth(IN.screenPos.z);
            float distance = abs(depth1 - depth2);
            //深度插值颜色
            fixed4 waterColor = lerp(_EdgeColor, _Color, saturate(distance * _EdgeThreshold));


            float4 foamColor = tex2D(_FoamTex, (IN.uv_FoamTex + fixed2(1, 1) * _Time.x * _FoamSpeed) * 20);
            fixed formDegree = clamp(distance, 0, _FoamThreshold);
            //把0~_FoamThreshold 缩放到0~1
            formDegree = formDegree / _FoamThreshold;
            fixed4 formColor = lerp(foamColor,fixed4(0, 0, 0, 0), formDegree) * _FoamColorScale;

            //法线
            float2 speed = _Time.x * float2(_WaveSpeed, _WaveSpeed) * _NormalSpeed;
            fixed3 bump1 = UnpackNormal(tex2D(_NormalTex, IN.uv_FoamTex.xy + speed)).rgb;
            fixed3 bump2 = UnpackNormal(tex2D(_NormalTex, IN.uv_FoamTex.xy - speed)).rgb;
            fixed3 bump = normalize(bump1 + bump2);
            bump.xy *= _NormalScale;
            bump = normalize(bump);
            o.Normal = bump;

            //折射
            float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
            fixed3 refrCol = tex2D(_RefractionTex, IN.screenPos.xy + offset).rgb;

            o.Albedo = waterColor.rgb * refrCol + formColor.rgb;
            o.Alpha = waterColor.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}