Shader "LX/SequenceFull"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR]_TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _Angle ("Angle", Range(0, 360)) = 0
        _UVcount ("UVcount", Vector) = (4,4,0,0)
        _UVTile ("UVTile", Range(0, 64)) = 0
        _AutoTileSpeed ("AutoTileSpeed", Range(1, 20)) = 1
        [MaterialToggle] _Auto ("Auto", Float ) = 0
        [MaterialToggle] _Mask ("Mask", Float ) = 1

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
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
            ZWrite Off

            CGPROGRAM
         

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform float _Angle;
            uniform float4 _UVcount; //横竖各有几个序列图
            uniform float _UVTile; //非自动播放时，当前显示第几个序列图
            uniform float _AutoTileSpeed;
            uniform fixed _Auto;
            uniform fixed _Mask;

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
                float curTileIndex = trunc(lerp(_UVTile, _AutoTileSpeed * _Time.z, _Auto)); //当前为第几个序列图
                float2 oneTileUV = float2(1.0, 1.0) / float2(_UVcount.x, -1 * _UVcount.y); //单个序列图占用的UV偏移
                float cur_V = floor(curTileIndex * oneTileUV.x); //当前第几个序列图，y
                float cur_U = curTileIndex - _UVcount.x * cur_V; //当前第几个序列图，x
                float angle = _Angle * 0.005555556 * 3.141592654;
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                float2 uvCenter = float2(0.5, 0.5);
                float2 rotatedUV = mul(i.uv - uvCenter, float2x2(cosAngle, -sinAngle, sinAngle, cosAngle)) + uvCenter;
                //旋转UV
                float2 uvInTile = float2(rotatedUV.x, 1.0 - rotatedUV.y); //单个序列图中的uv
                float2 finalUV = (uvInTile + float2(cur_U, cur_V)) * oneTileUV; //旋转后的uv加上当前是第几个序列图算出最后在整个图集中的uv
                float4 texColor = tex2D(_MainTex,TRANSFORM_TEX(finalUV, _MainTex));
                float3 finalColor = texColor.rgb * i.vertexColor.rgb * _TintColor.rgb * 2.0;
                float maskValue = lerp(1.0, saturate((1.0 - distance(float2(0.5, 0.5), uvInTile)) * 4.0 + -2.0),
                                       _Mask); //圆形边缘透明化
                float finalAlpha = texColor.a * i.vertexColor.a * _TintColor.a * maskValue;

                return fixed4(finalColor,finalAlpha);
            }
            ENDCG
        }
    }

}