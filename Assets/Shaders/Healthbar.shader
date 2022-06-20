Shader "Unlit/Healthbar"
{
    Properties
    {
        _HealthValue("Health Value", Range(0,1)) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            Zwrite Off

            // src * srcAlpha + dst * (1-srcAlpha)
            ///Blend SrcAlpha OneMinusSrcAlpha //Alpha Blending. Biar Transparent

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _HealthValue;
            float4 _LowColor;
            float4 _MaxColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float inverseLerp(float a, float b, float v) {
                return (v - a) / (b - a);
            }

            float4 frag(v2f i) : SV_Target
            {
                //Mask warna
                //float healthMaskChunked = _HealthValue > floor(i.uv.x * 8) / 8;
                float healthMask = _HealthValue > i.uv.x;

                //Bikin batas bawah dan atas. Batas bawah (0.2), batas atas (0.7).
                float tHealthColor = saturate (inverseLerp(0.2, 0.7, _HealthValue));
                
                //Lerp 2 warna. Warna bawah dan Warna atas
                float3 healthBarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);

                //clip(healthMask - 0.5); --> Hanya 2 state, Render it or not Render it

                //float3 bgColor = float3(0, 0, 0);
                //float3 healthBarOutput = lerp (bgColor, healthBarColor.xyz, healthMask);
                
                //return float4 (healthBarColor, healthMask * 0.5); --> Transparent
                return float4 (healthBarColor * healthMask, 0);
            }
            ENDCG
        }
    }
}
