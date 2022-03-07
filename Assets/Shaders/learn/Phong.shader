// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Phong"
{
    Properties
    {
		_Diffuse("Diffuse", Color) = (1,1,1,1) // 物体的颜色
    }
    SubShader
    {
	   Pass {
			// 指定 光照模式
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#pragma vertex vert // 使用 "vert" 函数作为顶点着色器
			#pragma fragment frag // 使用 "frag" 函数作为像素（片元）着色器

			// #include "Lighting.cginc" // 引入光照的一些方法
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			// 从 Properties 中获取
			fixed4 _Diffuse;

			// 顶点着色器输入
			struct a2v
			{
				float4 vertex : POSITION; // 顶点位置
				float3 normal : NORMAL;
			};

			// 顶点着色器输出（"顶点到片元"）
			struct v2f
			{
				float4 vertex : SV_POSITION; // 裁剪空间位置
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
			};

			// 顶点着色器
			v2f vert(a2v v)
			{
				v2f o;
				// 将位置转换为裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex); //（乘以模型*视图*投影矩阵）
				// 转换 法线 从对象空间到世界空间
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			// 像素着色器；返回低精度（"fixed4" 类型）
			fixed4 frag(v2f i) : SV_Target // 颜色（"SV_Target" 语义）
			{
				// ------计算漫反射光照部分------
				// 计算环境光 内置变量UNITY_LIGHTMODEL_AMBIENT得到环境光
				fixed3 ambient = unity_AmbientSky.xyz;

				// 计算 漫反射
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 color = ambient + diffuse;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
