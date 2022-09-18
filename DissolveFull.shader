Shader "LX/DissolveFull"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DissolveTex ("DissolveTex", 2D) = "white" {}
		_Threshold ("Threshold", float) = 0
		_EdgeColor ("EdgeColor", Color) = (1,0,0,0)
		_EdgeWidth ("EdgeWidth", float) = 0
		_NormalTex ("NormalTex", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
		}
		LOD 100

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 tangentLightDir : TEXCOORD2;
				float4 vertex : SV_POSITION;
				SHADOW_COORDS(3)
				float4 worldPos : TEXCOORD4;
			};

			sampler2D _MainTex;
			sampler2D _DissolveTex;
			sampler2D _NormalTex;
			float4 _MainTex_ST;
			float _Threshold;
			float4 _EdgeColor;
			float _EdgeWidth;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				TANGENT_SPACE_ROTATION;
				o.tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);

				UNITY_TRANSFER_FOG(o, o.vertex);
				TRANSFER_SHADOW(v)

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				fixed dissolve = tex2D(_DissolveTex, i.uv).r;
				clip(dissolve - _Threshold);
				fixed lerpVal = saturate(1 - (dissolve - _Threshold) / _EdgeWidth);
				float3 tangentNormal = UnpackNormal(tex2D(_NormalTex, i.uv));
				float3 tangentLightDir = normalize(i.tangentLightDir);
				fixed diffuseVal = saturate(dot(tangentNormal, tangentLightDir));

				fixed4 finalColor = lerp(col, _EdgeColor, lerpVal);
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos)

				UNITY_APPLY_FOG(i.fogCoord, col);
				return finalColor * diffuseVal*atten;
			}
			ENDCG
		}
		
		//阴影处理
        pass{
            Tags{"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
            			
			float _Threshold;
			sampler2D _DissolveTex;

            struct v2f{
                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD0;
            };

            v2f vert(appdata_base v){
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uvBurnMap = v.texcoord;
                return o;
            }
            fixed4 frag(v2f i):SV_TARGET{
                fixed3 burn = tex2D(_DissolveTex,i.uvBurnMap).rgb;
                clip(burn.r - _Threshold);
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
	}
}