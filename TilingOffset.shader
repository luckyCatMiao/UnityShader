Shader "LX/TilingOffset"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Y ("Y", float) = 0
        _X ("X", float) = 0
        [HDR]_Color ("Color", Color) = (0.5,0.5,0.5,1)
        _Mask ("Mask", 2D) = "white" {}
        _Brightness ("Brightness", Float ) = 2

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1

        [KeywordEnum(SrcAlpha,OneOne)] _AlphaBlendMode ("AlphaBlendMode", Float) = 0

        [KeywordEnum(None,Add)] _FresnelMode ("FresnelMode", Float) = 0
        _Fresnel ("Fresnel", Float ) = 1
        [HDR]_FresnelColor ("FresnelColor", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _StencilOpFail ("Stencil Fail Operation", Float) = 0
        _StencilOpZFail ("Stencil Z-Fail Operation", Float) = 0

    }
    SubShader
    {
        Tags
        {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            Cull Off
            ZWrite Off

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Fail [_StencilOpFail]
                ZFail [_StencilOpZFail]
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "LXShader.cginc"
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal
            #pragma multi_compile _ALPHABLENDMODE_SRCALPHA _ALPHABLENDMODE_ONEONE
            #pragma multi_compile _FRESNELMODE_NONE _FRESNELMODE_ADD
            #pragma target 3.0
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Y;
            uniform float _X;
            uniform float4 _Color;
            uniform sampler2D _Mask;
            uniform float4 _Mask_ST;
            uniform float _Brightness;
            uniform float _Fresnel;
            uniform float4 _FresnelColor;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;

                #if _FRESNELMODE_ADD
                 float3 normal : NORMAL;
                #endif
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 vertexColor : COLOR;

                #if _FRESNELMODE_ADD
                 float4 posWorld : TEXCOORD1;
                 float3 normalDir : TEXCOORD2;
                #endif
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                o.uv = v.uv;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex);

                #if _FRESNELMODE_ADD
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                #endif

                return o;
            }

            float4 frag(VertexOutput i) : COLOR
            {
                #if _FRESNELMODE_ADD
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                #endif

                float2 finalUV = moveUV(i.uv, _X, _Y);
                float4 texColor = tex2D(_MainTex,TRANSFORM_TEX(finalUV, _MainTex));
                float3 finalColor = texColor.rgb * _Color.rgb  * _Brightness;
                float4 texMask = tex2D(_Mask,TRANSFORM_TEX(i.uv, _Mask));
                float finalAlpha = texColor.a * _Color.a * texMask.a;

                #if _FRESNELMODE_ADD
                    return fixed4(finalColor+fresnel, finalAlpha);
                #else
                    return fixed4(finalColor, finalAlpha);
                #endif
            }
            ENDCG
        }
    }
}