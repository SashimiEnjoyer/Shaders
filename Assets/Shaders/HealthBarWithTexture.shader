Shader "Unlit/HealthBarWithTexture"
{
    Properties
    {
        [NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
        _HealthValue("Health Value", Range(0,1)) = 1
        _BorderSize("Border Size", Range(0, 0.5)) = 0.5

    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

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
                float _BorderSize;

                v2f vert(appdata v)
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

                    // Rounded Mask
                    float2 coords = i.uv;
                    coords.x *= 8;

                    float2 pointOnLineSegment = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                    float sdf = distance(coords, pointOnLineSegment) * 2 - 1;

                    clip(-sdf);
                    // End of Rounded Mask

                    float borderSdf = sdf +_BorderSize;
                    
                    float pd = fwidth(borderSdf); //--> Partial derivative
                    // length(float2 (ddx(borderSdf), ddy(borderSdf))); ///--> Lebih akurat dri fwidth

                    float borderMask = 1 - saturate(borderSdf / pd); //--> with Anti aliasing
                    //float borderMask = step(0, -borderSdf);
                    
                    //Mask texture
                    float healthMask = _HealthValue > i.uv.x;
 
                    //Lerp 2 warna. Warna bawah dan Warna atas
                    float3 healthBarColor = tex2D(_MainTex, float2 (_HealthValue, i.uv.y));

                    if (_HealthValue < 0.2) 
                    {
                        float flash = cos(_Time.y * 4) * 0.25 + 1;
                        healthBarColor *= flash;
                    }

                    return float4 (healthBarColor * healthMask * borderMask, 1);
            }
                ENDCG
            }

        }
}   