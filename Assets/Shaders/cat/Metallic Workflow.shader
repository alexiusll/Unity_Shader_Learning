Shader "Custom/Metallic Workflow"
{
	Properties {
		_Tint ("Tint",Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0 // ½øÐÐ gamma ½ÃÕý
	}

	SubShader{

		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// #include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "UnityStandardUtils.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Metallic;
			float _Smoothness;

			struct a2v {
                float4 position : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 position  : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

			v2f vert(a2v v) {
				v2f o;
				o.position = UnityObjectToClipPos(v.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.normal = mul(
				//	transpose((float3x3)unity_WorldToObject),
				//	v.normal
				//);
				//o.normal = normalize(o.normal);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.position);
				return o;
			}

			float4 frag(v2f i) : SV_TARGET {
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				float3 lightColor = _LightColor0.rgb; //  UnityLightingCommon
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
				
				//float3 specularTint = albedo * _Metallic;
				//float oneMinusReflectivity = 1 - _Metallic;
				//albedo *= oneMinusReflectivity;

				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);

				float3 halfVector = normalize(lightDir + viewDir);

				float3 specular = specularTint * lightColor * pow(
					DotClamped(halfVector, i.normal),
					_Smoothness * 100
				);
				float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);


				return float4(diffuse + specular, 1);
			}

			ENDCG
		}
	}
}
