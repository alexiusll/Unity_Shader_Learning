Shader "Custom/Chapter6/BlinnPhong"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1) // 高光反射颜色
        _Gloss ("Gloss", Range(8.0,256)) = 20 // 高光区域大小
    }
    SubShader
    {
         Pass {
            // 指定 光照模式
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos  : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v){
                // 定义返回值
                v2f o;
                // 顶点位置 从 模型空间 转换到 剪裁空间
                o.pos = UnityObjectToClipPos(v.vertex);

                // 转换 法线 从对象空间到世界空间
                // 法线的变换 是乘以对应变换矩阵 逆的转置
                // o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                o.worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                // 本节假设场景中只有一个类型的光源 -》 平行光
                // ------计算漫反射光照部分------
                // 计算环境光 内置变量UNITY_LIGHTMODEL_AMBIENT得到环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
      
                // 得到 光线 在世界空间的方向
                // fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 worldNormal = normalize(i.worldNormal);

                // 计算 漫反射
                // _LightColor0 光源的颜色和强度信息
                // dot() 是点集
                // saturate() 函数的作用是把参数截取到[0,1]的范围内
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

                // ------计算镜面反射光照部分------
                // 获得反射的光线方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir , worldNormal));
                // 获得 世界空间下 视点的方向
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal , halfDir)) , _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color , 1.0);
            }

            ENDCG
         }
    }
    FallBack "Diffuse"
}
