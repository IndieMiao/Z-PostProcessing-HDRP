Shader "Hidden/Shader/GlitchTileJitter"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
 

	#pragma shader_feature JITTER_DIRECTION_HORIZONTAL
	#pragma shader_feature USING_FREQUENCY_INFINITE
	uniform half4 _Params;

	#define _SplittingNumber _Params.x
	#define _JitterAmount _Params.y
	#define _JitterSpeed _Params.z
	#define _Frequency _Params.w

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	
	float randomNoise(float2 c)
	{
		return frac(sin(dot(c.xy, float2(12.9898, 78.233))) * 43758.5453);
	}

	float4 Frag_Vertical(Varyings i): SV_Target
	{
		float2 uv = i.texcoord.xy;
		half strength = 1.0;
		half pixelSizeX = 1.0 / _ScreenParams.x;
		
		// --------------------------------Prepare Jitter UV--------------------------------
		#if USING_FREQUENCY_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 *cos(_Time.y * _Frequency);
		#endif

		if (fmod(uv.x * _SplittingNumber, 2) < 1.0)
		{
			#if JITTER_DIRECTION_HORIZONTAL
				uv.x += pixelSizeX * cos(_Time.y * _JitterSpeed) * _JitterAmount * strength;
			#else
				uv.y += pixelSizeX * cos(_Time.y * _JitterSpeed) * _JitterAmount * strength;
			#endif
		}

		// -------------------------------Final Sample------------------------------
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  uv*_ScreenSize.xy);
		return sceneColor;
	}
	
	float4 Frag_Horizontal(Varyings i): SV_Target
	{
		float2 uv = i.texcoord.xy;
		half strength = 1.0;
		half pixelSizeX = 1.0 / _ScreenParams.x;

		// --------------------------------Prepare Jitter UV--------------------------------
		#if USING_FREQUENCY_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 * cos(_Time.y * _Frequency);
		#endif
		if(fmod(uv.y * _SplittingNumber, 2) < 1.0)
		{
			#if JITTER_DIRECTION_HORIZONTAL
				uv.x += pixelSizeX * cos(_Time.y * _JitterSpeed) * _JitterAmount * strength;
			#else
				uv.y += pixelSizeX * cos(_Time.y * _JitterSpeed) * _JitterAmount * strength;
			#endif
		}

		// -------------------------------Final Sample------------------------------
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  uv*_ScreenSize.xy);
		return sceneColor;
	}

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchTileJitter_H"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchTileJitter_V"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
