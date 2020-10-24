// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Chapter6/DiffuseVertexLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
       Pass {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            }

            struct v2f{
                float pos : SV_POSITION;
                fixed3 color : COLOR;
            }

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 转换法线 从对象空间到时间空间
                fixed3 worldNormal = normalize(mul(v.mormal,(float3x3)unity_WorldToObject));
                // 得到光线在世界空间的方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                // 计算 漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

                o.color = ambient + diffuse;

                return o;
            }



            ENDCG
       }
    }
    FallBack "Diffuse"
}
