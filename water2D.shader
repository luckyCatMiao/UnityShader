Shader "LX/water2D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", float) = 1
        _Frequency ("Frequency", float) = 1
        _Amplitude ("Amplitude", float) = 1
        _Color ("Color", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "DisableBatching"="True"
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

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
            float _Speed;
            float _Frequency;
            float _Amplitude;
            fixed4 _Color;
          

            v2f vert(appdata v)
            {
                v2f o;

                float4 vertex=v.vertex;
                vertex.z = vertex.z + _SinTime.y*sin(vertex.x*_Frequency)*_Amplitude;
                o.vertex = UnityObjectToClipPos(vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex)+_Time.x;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv)*_Color;
                return col;
            }
            ENDCG
        }
    }
}