Shader "LX/dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("NoiseTex",2D)="white"{}
        _Threshold("Threshold",float)=0.5
        _BurnColor("BurnColor",color)=(1,1,1,1)
        _BurnColorExpand("BurnColorExpand",float)=1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Cull Off
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
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uvMain : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed worldLightDir:TEXCOORD1;
                fixed worldNormal:TEXCOORD2;
                float2 uvNoise : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _Threshold;
            float3 _BurnColor;

            float _BurnColorExpand;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uv, _NoiseTex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldLightDir = UnityWorldSpaceLightDir(worldPos);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed burnAmount = abs(tex2D(_NoiseTex, i.uvNoise));
                clip(burnAmount - _Threshold);

                fixed3 worldLightDir = i.worldLightDir;
                fixed3 worldNormal = i.worldNormal;

                fixed4 col = tex2D(_MainTex, i.uvMain);
                fixed3 diffuse = dot(worldLightDir, worldNormal) * col;

                float burnEdge = burnAmount - _Threshold;
                diffuse = lerp(_BurnColor, diffuse, min(1, burnEdge * _BurnColorExpand));

                return fixed4(diffuse, 0);
            }
            ENDCG
        }
    }
}