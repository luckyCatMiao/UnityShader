Shader "LX/SaoGuang"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Pow ("Pow", Range(1, 10)) = 1
        [HDR]_color ("color", Color) = (0.5,0.5,0.5,1)
        _speed ("speed", Range(-10, 10)) = 5.130055
        _angle ("angle", Range(0, 1)) = 0.4879469

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
        [Enum(ColorMaskFull)] _ColorMask ("ColorMask", Float) = 15

    }
    SubShader
    {
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ColorMask [_ColorMask]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _width;
            uniform float4 _color;
            uniform float _speed;
            uniform float _angle;
            uniform float _Pow;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv = v.uv;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR
            {
                fixed moveSpeed = _Time.y * _speed;
                float4 texColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv, _MainTex));
                fixed angleVal = lerp(i.uv.x, i.uv.y, _angle); //同一_angle对应斜率的uv得出的值相同
                float3 saoguangColor = saturate(pow(saturate(sin(angleVal * 3.14 + moveSpeed)), _Pow)) * _color.rgb;

                float3 finalColor = texColor.rgb + saoguangColor;
                fixed finalAlpha = texColor.a * _color.a;
                return fixed4(finalColor, finalAlpha);
            }
            ENDCG
        }
    }
}