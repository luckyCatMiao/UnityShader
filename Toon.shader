Shader "LX/Toon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RampTex ("RampTex", 2D) = "white" {}
		_OutlineColor ("OutlineColor", Color) = (1,1,1,1)
		_OutlineWidth ("OutlineWidth", float) = 1
		_Ambient ("Ambient", Color) = (1,1,1,1)
		_SpecPow ("SpecPow", int) = 5
		_SpecColor ("SpecColor", Color) = (1,1,1,1)
		_SpecularThreshold ("SpecularThreshold", float) = 1
	}
	SubShader
	{
		Pass
		{
			NAME "OUTLINE"
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			half4 _OutlineColor;
			float _OutlineWidth;

			v2f_img vert(appdata_base v)
			{
				v2f_img o;
				v.vertex = mul(unity_MatrixMV, v.vertex);
				v.normal = mul(UNITY_MATRIX_IT_MV, v.normal);
				v.normal.z = -0.5;
				v.vertex.xyz += normalize(v.normal) * _OutlineWidth;
				o.pos = mul(UNITY_MATRIX_P,v.vertex);
				return o;
			}

			fixed4 frag(v2f_img i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode"="ForwardBase"
			}
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal:TEXCOORD01;
				float3 worldPos:TEXCOORD02;
				SHADOW_COORDS(3)
			};

			sampler2D _MainTex;
			sampler2D _RampTex;
			float4 _MainTex_ST;
			float4 _Ambient;
			float4 _SpecColor;
			float _SpecularThreshold;
			int _SpecPow;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);
				TRANSFER_SHADOW(o)
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float3 normal = UnityObjectToWorldNormal(i.normal);
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed diffuse = (dot(normal, lightDir) + 1) / 2;
				fixed rampValue = tex2D(_RampTex,fixed2(diffuse, 0));

				half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half3 halfDir = normalize(viewDir + lightDir);
				float spec = saturate(pow(saturate(dot(halfDir, i.normal)), _SpecPow));
				spec=step(_SpecularThreshold,spec);

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos)

				return _Ambient +( rampValue * col + spec * _SpecColor)*atten;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}