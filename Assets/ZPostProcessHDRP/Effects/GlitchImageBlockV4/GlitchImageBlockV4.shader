Shader "Hidden/Shader/GlitchImageBlockV4"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	uniform half4 _Params;
	#define _Speed _Params.x
	#define _BlockSize _Params.y
	#define _MaxRGBSplitX _Params.z
	#define _MaxRGBSplitY _Params.w


	inline float randomNoise(float2 seed)
	{
		return frac(sin(dot(seed * floor(_Time.y * _Speed), float2(17.13, 3.71))) * 43758.5453123);
	}

	inline float randomNoise(float seed)
	{
		return randomNoise(float2(seed, 1.0));
	}

	half4 Frag(Varyings i) : SV_Target
	{
		half2 block = randomNoise(floor(i.texcoord * _BlockSize));

		float displaceNoise = pow(block.x, 8.0) * pow(block.x, 3.0);
		float splitRGBNoise = pow(randomNoise(7.2341), 17.0);
		float offsetX = displaceNoise - splitRGBNoise * _MaxRGBSplitX;
		float offsetY = displaceNoise - splitRGBNoise * _MaxRGBSplitY;

		float noiseX = 0.05 * randomNoise(13.0);
		float noiseY = 0.05 * randomNoise(7.0);

		float2 offset = float2(offsetX * noiseX, offsetY* noiseY);

		half4 colorR = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord* _ScreenSize.xy);
		half4 colorG = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord + offset) * _ScreenSize.xy);
		half4 colorB = LOAD_TEXTURE2D_X(_InputTexture,  (i.texcoord - offset) * _ScreenSize.xy);

		return half4(colorR.r , colorG.g, colorB.z, (colorR.a + colorG.a + colorB.a));
	}

    ENDHLSL

    SubShader
    {
        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            Name "GlitchImageBlockV4"
            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
