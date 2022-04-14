Shader "Unlit/FirstShader"
{
	Properties {
		_Tint ("Tint",Color) = (1,1,1,1)
		_MainTex ("Texture",2D) = "White"{}
	}

	SubShader{

		Pass {
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 position  : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

			v2f vert(a2v v) {
				v2f o;
				o.position = UnityObjectToClipPos(v.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			void help(inout v2f i){
				i.uv = float2(0, 1);
			}

			float4 frag(v2f i) : SV_TARGET {
				// help(i);
				return tex2D(_MainTex, i.uv);
			}

			ENDCG
		}
	}
}
