Shader "Custom/CustomSaber"
{
    Properties
    {
        /*
        These are fed in by Vivify per saber.
        In fact, Vivify will attempt to feed these values into every child of a saber prefab.
        */
        _Color ("Saber Color", Color) = (1,1,1)
        _Color2 ("Other Color", Color) = (1,1,1)
        _Cutoff ("Cut Off", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing // Insert for GPU instancing
            // Ensure to check "Enable GPU Instancing" on the material

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID // Insert for GPU instancing
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // Register GPU instanced properties (apply per-saber)
            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float3, _Color)
            UNITY_DEFINE_INSTANCED_PROP(float3, _Color2)
            UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o); // Insert for GPU instancing
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i); // Insert for GPU instancing

                // The color of the saber
                float3 Color = UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
                float3 Color2 = UNITY_ACCESS_INSTANCED_PROP(Props, _Color2);
                float Cutoff = UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff);

                if (i.uv.x < Cutoff)
                    return float4(Color, 0);
                else
                    return float4(Color2, 0);
            }
            ENDCG
        }
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On ZTest LEqual
            // add all fragment modifications here with the final v2f output being SHADOW_CASTER_FRAGMENT(i)
        }
    }
}
