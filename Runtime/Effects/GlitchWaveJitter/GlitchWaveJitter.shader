Shader "Hidden/Shader/GlitchWaveJitter"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZNoise.hlsl"

	#pragma shader_feature USING_FREQUENCY_INFINITE
    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	uniform half4 _Params;
	half2 _Resolution;

	#define _Frequency _Params.x
	#define _RGBSplit _Params.y
	#define _Speed _Params.z
	#define _Amount _Params.w

	
	float4 Frag_Horizontal(Varyings i): SV_Target
	{
		half strength = 0.0;
		#if USING_FREQUENCY_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 *cos(_Time.y * _Frequency);
		#endif
		
		// Prepare UV
		float uv_y = i.texcoord.y * _Resolution.y;
		float noise_wave_1 = snoise(float2(uv_y * 0.01, _Time.y * _Speed * 20)) * (strength * _Amount * 32.0);
		float noise_wave_2 = snoise(float2(uv_y * 0.02, _Time.y * _Speed * 10)) * (strength * _Amount * 4.0);
		float noise_wave_x = noise_wave_1 * noise_wave_2 / _Resolution.x;
		float uv_x = i.texcoord.x + noise_wave_x;

		float rgbSplit_uv_x = (_RGBSplit * 50 + (20.0 * strength + 1.0)) * noise_wave_x / _Resolution.x;

		// Sample RGB Color-
		half4 colorG = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv_x, i.texcoord.y) * _ScreenSize.xy);
		half4 colorRB = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv_x + rgbSplit_uv_x, i.texcoord.y) * _ScreenSize.xy);
		
		return  half4(colorRB.r, colorG.g, colorRB.b, colorRB.a + colorG.a);
	}

	float4 Frag_Vertical(Varyings i) : SV_Target
	{
		half strength = 0.0;
		#if USING_FREQUENCY_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 * cos(_Time.y * _Frequency);
		#endif

		// Prepare UV
		float uv_x = i.texcoord.x * _Resolution.x;
		float noise_wave_1 = snoise(float2(uv_x * 0.01, _Time.y * _Speed * 20)) * (strength * _Amount * 32.0);
		float noise_wave_2 = snoise(float2(uv_x * 0.02, _Time.y * _Speed * 10)) * (strength * _Amount * 4.0);
		float noise_wave_y = noise_wave_1 * noise_wave_2 / _Resolution.x;
		float uv_y = i.texcoord.y + noise_wave_y;

		float rgbSplit_uv_y = (_RGBSplit * 50 + (20.0 * strength + 1.0)) * noise_wave_y / _Resolution.y;

		// Sample RGB Color
		half4 colorG = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x, uv_y) * _ScreenSize.xy);
		half4 colorRB = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x, uv_y + rgbSplit_uv_y) * _ScreenSize.xy);

		return half4(colorRB.r, colorG.g, colorRB.b, colorRB.a + colorG.a);
	}

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchWaveJitter_h"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchWaveJitter_v"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
