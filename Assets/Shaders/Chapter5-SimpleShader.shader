// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5-SimpleShader"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// 使用一个结构体来定义顶点着色器的输入
			struct a2v {
				float4 vertex : POSITION; // POSITION 语义告诉Unity , 用模型空间的顶点坐标填充vertex 变量
				float3 normal : NORMAL; //	NORMAL 语义告诉unity,用模型空间的法线方向填充normal变量
				float4 texcoord : TEXCOORD0; // TEXCOORD0 语义告诉unity,用模型的第一套纹理坐标填充texcoord变量
			};

			float4 vert(a2v v) :SV_POSITION{
				return UnityObjectToClipPos(v.vertex); // 把顶点坐标从模型空间转换到剪裁空间中
			}

			fixed4 frag() : SV_Target{
				return fixed4(1.0,0.0,0.0,1.0);
			}

			ENDCG
		}
	}
}
