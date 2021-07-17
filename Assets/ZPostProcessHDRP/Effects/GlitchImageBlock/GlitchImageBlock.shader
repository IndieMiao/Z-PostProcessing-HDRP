Shader "Hidden/Shader/GlitchImageBlock"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	uniform half3 _Params;
	uniform half4 _Params2;
	uniform half3 _Params3;

	#define _TimeX _Params.x
	#define _Offset _Params.y
	#define _Fade _Params.z

	#define _BlockLayer1_U _Params2.w
	#define _BlockLayer1_V _Params2.x
	#define _BlockLayer2_U _Params2.y
	#define _BlockLayer2_V _Params2.z

	#define _RGBSplit_Indensity _Params3.x
	#define _BlockLayer1_Indensity _Params3.y
	#define _BlockLayer2_Indensity _Params3.z
	

	float randomNoise(float2 seed)
	{
		return frac(sin(dot(seed * floor(_TimeX * 30.0), float2(127.1, 311.7))) * 43758.5453123);
	}
	
	float randomNoise(float seed)
	{
		return randomNoise(float2(seed, 1.0));
	}
	
	float4 Frag(Varyings i): SV_Target
	{
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		float2 uv = i.texcoord.xy;
		
		//求解第一层blockLayer
		float2 blockLayer1 = floor(uv * float2(_BlockLayer1_U, _BlockLayer1_V));
		float2 blockLayer2 = floor(uv * float2(_BlockLayer2_U, _BlockLayer2_V));

		//return float4(blockLayer1, blockLayer2);
		
		float lineNoise1 = pow(randomNoise(blockLayer1), _BlockLayer1_Indensity);
		float lineNoise2 = pow(randomNoise(blockLayer2), _BlockLayer2_Indensity);
		float RGBSplitNoise = pow(randomNoise(5.1379), 7.1) * _RGBSplit_Indensity;
		float lineNoise = lineNoise1 * lineNoise2 * _Offset  - RGBSplitNoise;
		
		float4 colorR = LOAD_TEXTURE2D_X(_InputTexture,  uv* _ScreenSize.xy);
		float4 colorG = LOAD_TEXTURE2D_X(_InputTexture,  uv + float2(lineNoise * 0.05 * randomNoise(7.0), 0)* _ScreenSize.xy);
		float4 colorB = LOAD_TEXTURE2D_X(_InputTexture,  uv - float2(lineNoise * 0.05 * randomNoise(23.0), 0)* _ScreenSize.xy);
		
		float4 result = float4(float3(colorR.x, colorG.y, colorB.z), colorR.a + colorG.a + colorB.a);
		result = lerp(colorR, result, _Fade);
		
		return result;
	}
	
	
	float4 Frag_Debug(Varyings i): SV_Target
	{
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		float2 uv = i.texcoord.xy;
		
		float2 blockLayer1 = floor(uv * float2(_BlockLayer1_U, _BlockLayer1_V));
		float2 blockLayer2 = floor(uv * float2(_BlockLayer2_U, _BlockLayer2_V));
		
		float lineNoise1 = pow(randomNoise(blockLayer1), _BlockLayer1_Indensity);
		float lineNoise2 = pow(randomNoise(blockLayer2), _BlockLayer2_Indensity);
		float RGBSplitNoise = pow(randomNoise(5.1379), 7.1) * _RGBSplit_Indensity;
		float lineNoise = lineNoise1 * lineNoise2 * _Offset - RGBSplitNoise;
		
		return float4(lineNoise, lineNoise, lineNoise, 1);
	}
	

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        uint2 positionSS = input.texcoord * _ScreenSize.xy;
        float3 outColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz;

        return float4(outColor, 1);
    }

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchImageBlock"

            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchImageBlockDebug"

            HLSLPROGRAM
                #pragma fragment Frag_Debug
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
