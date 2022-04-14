Shader "Custom/defered"
{
    Properties
    {
        _Tint("Tint", Color) = (1, 1, 1, 1)
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass {
            // 设置渲染模式 为 deferred
            Tags {
                "LightMode" = "Deferred"
            }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            float4 _Tint;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            struct FragmentOutput {
                #if defined(DEFERRED_PASS)
                    float4 gBuffer0 : SV_Target0;
                    float4 gBuffer1 : SV_Target1;
                    float4 gBuffer2 : SV_Target2;
                    float4 gBuffer3 : SV_Target3;
                #else
                    float4 color : SV_Target;
                #endif
            };

            v2f vert(a2v v) {
                v2f o;
                // 转换到裁剪坐标系
                o.position = UnityObjectToClipPos(v.position);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET{
                return tex2D(_MainTex, i.uv) * _Tint;
            }

            ENDCG

        }
    }
    FallBack "Diffuse"
}
