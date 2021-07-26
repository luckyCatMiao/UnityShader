Shader "LX/frameAnime"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColumnCount ("ColumnCount", int) = 1
        _RowCount ("RowCount", int) = 1

    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            int _ColumnCount;
            int _RowCount;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time=floor(_Time.y*5);
                float row=floor(time/_ColumnCount);
                float column=time-row*_RowCount;
                
                half2 uv = half2(i.uv.x /_RowCount+row/_RowCount,i.uv.y/_ColumnCount+column/_ColumnCount);

                fixed4 col = tex2D(_MainTex,uv);

                return col;
            }
            ENDCG
        }
    }
}