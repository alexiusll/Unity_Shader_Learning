#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

float4 _Tint;
sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _HeightMap;
float4 _HeightMap_TexelSize; // exp: (0.00390625, 0.0078125, 256, 128)

sampler2D _NormalMap;

float _Metallic;
float _Smoothness;

float _BumpScale;

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

	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD3;
	#endif
};

void ComputeVertexLightColor (inout v2f i) {
	#if defined(VERTEXLIGHT_ON)
		//float3 lightPos = float3(
		//	unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x
		//);
		//float3 lightVec = lightPos - i.worldPos;
		//float3 lightDir = normalize(lightVec);

		//float ndotl = DotClamped(i.normal, lightDir);
		//float attenuation = 1 / (1 + dot(lightVec, lightVec) * unity_4LightAtten0.x );

		//i.vertexLightColor = unity_LightColor[0].rgb * ndotl * attenuation;

		// i.vertexLightColor = unity_LightColor[0].rgb;

		i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		);
	#endif
}

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
	ComputeVertexLightColor(o);
	return o;
}

UnityLight CreateLight (v2f i) {
	UnityLight light;

	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif

	// float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos; // 距离
	// float attenuation = 1 / (1 + dot(lightVec, lightVec)); // 1/d^2 距离的平方成反比

	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);

	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

UnityIndirect CreateIndirectLight (v2f i) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif

	#if defined(FORWARD_BASE_PASS)
		indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
	#endif
	
	return indirectLight;
}

// height map
void InitializeFragmentNormal(inout v2f i) {
	float2 du = float2(_HeightMap_TexelSize.x * 0.5, 0);
	float u1 = tex2D(_HeightMap, i.uv - du);
	float u2 = tex2D(_HeightMap, i.uv + du);
	// i.normal = float3(1, (h2 - h1) / delta.x, 0); 反正我们是会做实例化的
	// i.normal = float3(delta.x, h2 - h1, 0);
	// float3 tu = float3(1, u2 - u1, 0);

	float2 dv = float2(0, _HeightMap_TexelSize.y * 0.5);
	float v1 = tex2D(_HeightMap, i.uv - dv);
	float v2 = tex2D(_HeightMap, i.uv + dv);
	//float3 tv = float3(0, v2 - v1, 1);

	// i.normal = cross(tv, tu);
	i.normal = float3(u1 - u2, 1, v1 - v2);
	i.normal = normalize(i.normal);
}

void InitializeFragmentNormal_NormalMap(inout v2f i) {
	//i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
	//i.normal.xy *= _BumpScale;
	//i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));

	i.normal = UnpackScaleNormal(tex2D(_NormalMap, i.uv), _BumpScale);
	i.normal = i.normal.xzy;
	i.normal = normalize(i.normal);
}

float4 frag(v2f i) : SV_TARGET {
	InitializeFragmentNormal_NormalMap(i);

	// float3 lightDir = _WorldSpaceLightPos0.xyz;
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
	// float3 lightColor = _LightColor0.rgb; //  UnityLightingCommon
	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
				
	//float3 specularTint = albedo * _Metallic;
	//float oneMinusReflectivity = 1 - _Metallic;
	//albedo *= oneMinusReflectivity;

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);

	//UnityLight light;
	//light.color = lightColor;
	//light.dir = lightDir;
	//light.ndotl = DotClamped(i.normal, lightDir);

	//UnityIndirect indirectLight;
	//indirectLight.diffuse = 0;
	//indirectLight.specular = 0;
		
	// 使用球谐函数
	// float3 shColor = ShadeSH9(float4(i.normal, 1));
	// return float4(shColor, 1);

	return UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, _Smoothness, i.normal, viewDir, CreateLight(i), CreateIndirectLight(i));
}

#endif