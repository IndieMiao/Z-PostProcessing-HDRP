Shader "Hidden/Shader/GlitchRGBSplitV5"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	
	sampler2D _NoiseTex;

	uniform half2 _Params;
	#define _Amplitude _Params.x
	#define _Speed _Params.y
	

	inline float4 Pow4(float4 v, float p)
	{
		return float4(pow(v.x, p), pow(v.y, p), pow(v.z, p), v.w);
	}

	inline float4 Noise(float2 p)
	{
		return tex2D(_NoiseTex, p);
	}

	half4 Frag(Varyings i): SV_Target
	{
		float4 splitAmount = Pow4(Noise(float2(_Speed * _Time.y, 2.0 * _Speed * _Time.y / 25.0)), 8.0) * float4(_Amplitude, _Amplitude, _Amplitude, 1.0);

		splitAmount *= 2.0 * splitAmount.w - 1.0;

		half colorR = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord.xy + float2(splitAmount.x, -splitAmount.y)) * _ScreenSize.xy).r;
		half colorG = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord.xy + float2(splitAmount.y, -splitAmount.z)) * _ScreenSize.xy).g;
		half colorB = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord.xy + float2(splitAmount.z, -splitAmount.x)) * _ScreenSize.xy).b;

		half3 finalColor = half3(colorR, colorG, colorB);
		return half4(finalColor,1);

	}
    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchRGBSplitv5"
            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
