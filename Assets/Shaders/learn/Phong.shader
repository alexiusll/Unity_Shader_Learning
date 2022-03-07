// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Phong"
{
    Properties
    {
		_Diffuse("Diffuse", Color) = (1,1,1,1) // �������ɫ
    }
    SubShader
    {
	   Pass {
			// ָ�� ����ģʽ
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			
			#pragma vertex vert // ʹ�� "vert" ������Ϊ������ɫ��
			#pragma fragment frag // ʹ�� "frag" ������Ϊ���أ�ƬԪ����ɫ��

			// #include "Lighting.cginc" // ������յ�һЩ����
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			// �� Properties �л�ȡ
			fixed4 _Diffuse;

			// ������ɫ������
			struct a2v
			{
				float4 vertex : POSITION; // ����λ��
				float3 normal : NORMAL;
			};

			// ������ɫ�������"���㵽ƬԪ"��
			struct v2f
			{
				float4 vertex : SV_POSITION; // �ü��ռ�λ��
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
			};

			// ������ɫ��
			v2f vert(a2v v)
			{
				v2f o;
				// ��λ��ת��Ϊ�ü��ռ�
				o.vertex = UnityObjectToClipPos(v.vertex); //������ģ��*��ͼ*ͶӰ����
				// ת�� ���� �Ӷ���ռ䵽����ռ�
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			// ������ɫ�������ص;��ȣ�"fixed4" ���ͣ�
			fixed4 frag(v2f i) : SV_Target // ��ɫ��"SV_Target" ���壩
			{
				// ------������������ղ���------
				// ���㻷���� ���ñ���UNITY_LIGHTMODEL_AMBIENT�õ�������
				fixed3 ambient = unity_AmbientSky.xyz;

				// ���� ������
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
