Shader "Custom/Textured With Detail"
{
	Properties {
		_Tint ("Tint",Color) = (1,1,1,1)
		_MainTex ("Texture",2D) = "White"{}
		_DetailTex ("Detail Texture", 2D) = "gray" {}
	}

	SubShader{

		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST, _DetailTex_ST;

			struct a2v {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
            };

            struct v2f {
                float4 position  : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvDetail : TEXCOORD1;
            };

			v2f vert(a2v v) {
				v2f o;
				o.position = UnityObjectToClipPos(v.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
				return o;
			}

			float4 frag(v2f i) : SV_TARGET {
				float4 color = tex2D(_MainTex, i.uv) * _Tint;
				color *= tex2D(_DetailTex, i.uvDetail) * unity_ColorSpaceDouble;
				return color;
			}

			ENDCG
		}
	}
}
