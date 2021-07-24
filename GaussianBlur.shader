Shader "LX/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZTest Always
        Cull Off
        Zwrite Off

        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            half2 uv[5]:TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;


        v2f vertV(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            const half2 uv = v.uv;
            o.uv[0] = uv;
            o.uv[1] = uv + float2(0, _MainTex_TexelSize.y * 1);
            o.uv[2] = uv + float2(0, _MainTex_TexelSize.y * 2);
            o.uv[3] = uv + float2(0, _MainTex_TexelSize.y * -1);
            o.uv[4] = uv + float2(0, _MainTex_TexelSize.y * -2);
            return o;
        }

        v2f vertH(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            const half2 uv = v.uv;
            o.uv[0] = uv;
            o.uv[1] = uv + float2(0, _MainTex_TexelSize.x * 1);
            o.uv[2] = uv + float2(0, _MainTex_TexelSize.x * 2);
            o.uv[3] = uv + float2(0, _MainTex_TexelSize.x * -1);
            o.uv[4] = uv + float2(0, _MainTex_TexelSize.x * -2);
            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
            for (int index = 1; index < 3; index++)
            {
                sum += tex2D(_MainTex, i.uv[index]).rgb * weight[index];
                sum += tex2D(_MainTex, i.uv[index+2]).rgb * weight[index];
            }

            return fixed4(sum, 1);
        }
        ENDCG
        Pass
        {
            NAME "G_V"
            CGPROGRAM
            #pragma vertex vertV
            #pragma fragment frag
            ENDCG
        }
        Pass
        {
            NAME "G_H"
            CGPROGRAM
            #pragma vertex vertH
            #pragma fragment frag
            ENDCG
        }


    }
}