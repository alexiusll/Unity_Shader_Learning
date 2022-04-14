Shader "Custom/PBS_light"
{
	Properties {
		_Tint ("Tint",Color) = (1,1,1,1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0 // ½øÐÐ gamma ½ÃÕý
		[NoScaleOffset] _HeightMap ("Heights", 2D) = "white" {}
		[NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1
	}

	SubShader{

		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}
			// ZWrite Off

			CGPROGRAM

			#pragma target 3.0 // https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html

			#pragma multi_compile _ VERTEXLIGHT_ON

			#pragma vertex vert
			#pragma fragment frag

			#define FORWARD_BASE_PASS

			#include "My Lighting.cginc"

			ENDCG
		}

		Pass {
			Tags {
				"LightMode" = "ForwardAdd"
			}
			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0

			// #define POINT
			#pragma multi_compile_fwdadd
			// #pragma multi_compile DIRECTIONAL DIRECTIONAL_COOKIE POINT SPOT

			#pragma vertex vert
			#pragma fragment frag 

			#include "My Lighting.cginc"

			ENDCG
		}
	}
}
