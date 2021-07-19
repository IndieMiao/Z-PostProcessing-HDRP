Shader "Hidden/Shader/GlitchImageBlockV3"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	half3 _Params;

	#define _Speed _Params.x
	#define _BlockSize _Params.y

	inline float randomNoise(float2 seed)
	{
		return frac(sin(dot(seed * floor(_Time.y * _Speed), float2(17.13, 3.71))) * 43758.5453123);
	}

	inline float randomNoise(float seed)
	{
		return rand(float2(seed, 1.0));
	}

	half4 Frag(Varyings i) : SV_Target
	{

		float2 block = randomNoise(floor(i.texcoord * _BlockSize));
		float displaceNoise = pow(block.x, 8.0) * pow(block.x, 3.0);

		half ColorR = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy).r;
		half ColorG = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord + float2(displaceNoise * 0.05 * randomNoise(7.0), 0.0))* _ScreenSize.xy).g;
		half ColorB = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord - float2(displaceNoise * 0.05 * randomNoise(13.0), 0.0))* _ScreenSize.xy).b;

		return half4(ColorR, ColorG, ColorB, 1.0);

	}

    ENDHLSL

    SubShader
    {
        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            Name "GlitchImageBlockV3"
            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
