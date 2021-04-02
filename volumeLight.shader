Shader "LX/VolumeLight" {
Properties {
	FracTex("Fractral Tex for shaft",2D)="white"{}
	BaseC("Base Color",color)=(1,1,1,1)
	exL ("Extrusion", float) = 5.0
	kP("Factor of Power",float)=1
}
SubShader {
	Tags { "Queue" = "Transparent+10" }
	
	ZWrite Off
	Offset 1,1
	
	pass{
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 3.0
		#include "UnityCG.cginc"

		struct v2f{
			float4 pos:SV_POSITION;
			float3 oP:TEXCOORD0;
			float exDist:TEXCOORD1;
			float4 oLitP:TEXCOORD2;
			float2 uv:TEXCOORD3;
		};
		float exL;
		float kP;
		float4 litPos;
		float4x4 toW;
		float4x4 toObj;
		v2f vert( appdata_base v ) : POSITION {
			v2f o;
			float3 toLight =ObjSpaceLightDir(v.vertex);
			float backFactor = dot( toLight, v.normal );
	
			float extrude = (backFactor < 0.0) ? 1.0 : 0.0;
			v.vertex.xyz+=v.normal*0.05;
			v.vertex.xyz -= toLight * (extrude * exL);
			o.pos= UnityObjectToClipPos( v.vertex );

			o.exDist=extrude*exL;
			o.oP=v.vertex.xyz;
			o.uv=v.texcoord.xy;
			return o;
		}
		sampler2D FracTex;
		float4 BaseC;
		float4 frag(v2f i):COLOR
		{
			float alp=tex2D(FracTex,i.uv).r;
			float toL=distance(i.oLitP.xyz,i.oP);//像素点到光源的距离

			float dist=toL-exL;//像素点挤出的距离
			float att=dist/exL;//
			att=1-att;

			float4 c=BaseC*att;
			c.a=pow(att,kP)*BaseC.a*alp;
			return c;
		}
		ENDCG
		}//end pass
} //sub

FallBack Off
}
