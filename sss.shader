Shader "LX/SSS"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BaseColor("Base Color of Object",color)=(1,1,1,1)
        _DistAdjust("Distance Adjust",float)=0
        _Atten("Control the Density of Object",float)=1
        _sssDensity("SSSDensity",float)=0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldLightDir:TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldLightDir = UnityWorldSpaceLightDir(worldPos);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                fixed3 col = tex2D(_MainTex, i.uv);
                fixed3 diffuse = dot(normalize(i.worldLightDir), normalize(i.worldNormal)) * col;
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                return fixed4(0,0,0, 1);
            }
            ENDCG
        }
        pass
        {
            Blend One One
            Tags
            {
                "LightMode"="ForwardAdd"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 lightDir:TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.lightDir = ObjSpaceLightDir(v.vertex);
                return o;
            }

            float4 _BaseColor;
            float _DistAdjust;
            float _Atten;
            float _sssDensity;

            float4 frag(v2f i):COLOR
            {
                float3 lightDir = i.lightDir; //光源方向
                float distance = length(lightDir); //到光源的原始距离
                distance = max(0, distance - _DistAdjust); //对原始距离进行一个偏移
                float att = 1 / (1 + distance * distance);
                att = pow(att, _Atten); //计算光的衰减速度
                return  _BaseColor * att * _sssDensity;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}