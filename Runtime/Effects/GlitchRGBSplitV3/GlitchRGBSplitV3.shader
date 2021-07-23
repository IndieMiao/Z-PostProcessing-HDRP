Shader "Hidden/Shader/GlitchRGBSplitV3"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	
	#pragma shader_feature USING_Frequency_INFINITE

	half3 _Params;
	#define _Frequency _Params.x
	#define _Amount _Params.y
	#define _Speed _Params.z

	
	float4 RGBSplit_Horizontal(float2 uv, float Amount, float time)
	{
		Amount *= 0.001;
		float3 splitAmountX = float3(uv.x, uv.x, uv.x);
		splitAmountX.r += sin(time * 0.2) * Amount;
		splitAmountX.g += sin(time * 0.1) * Amount;
		half4 splitColor = half4(0.0, 0.0, 0.0, 0.0);
		splitColor.r = (LOAD_TEXTURE2D_X(_InputTexture,  float2(splitAmountX.r, uv.y) * _ScreenSize.xy).rgb).x;
		splitColor.g = (LOAD_TEXTURE2D_X(_InputTexture,  float2(splitAmountX.g, uv.y) * _ScreenSize.xy).rgb).y;
		splitColor.b = (LOAD_TEXTURE2D_X(_InputTexture,  float2(splitAmountX.b, uv.y) * _ScreenSize.xy).rgb).z;
		splitColor.a = 1;
		return splitColor;
	}
	
	float4 RGBSplit_Vertical(float2 uv, float Amount, float time)
	{
		Amount *= 0.001;
		float3 splitAmountY = float3(uv.y, uv.y, uv.y);
		splitAmountY.r += sin(time * 0.2) * Amount;
		splitAmountY.g += sin(time * 0.1) * Amount;
		half4 splitColor = half4(0.0, 0.0, 0.0, 0.0);
		splitColor.r = (LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x, splitAmountY.r) * _ScreenSize.xy).rgb).x;
		splitColor.g = (LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x, splitAmountY.g) * _ScreenSize.xy).rgb).y;
		splitColor.b = (LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x, splitAmountY.b) * _ScreenSize.xy).rgb).z;
		splitColor.a = 1;
		return splitColor;
	}

	float4 RGBSplit_Horizontal_Vertical(float2 uv, float Amount, float time)
	{
		Amount *= 0.001;
		//float3 splitAmount = float3(uv.y, uv.y, uv.y);
		float splitAmountR= sin(time * 0.2) * Amount;
		float splitAmountG= sin(time * 0.1) * Amount;
		half4 splitColor = half4(0.0, 0.0, 0.0, 0.0);
		splitColor.r = (LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x + splitAmountR,uv.y +splitAmountR) * _ScreenSize.xy).rgb).x;
		splitColor.g = (LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x , uv.y) * _ScreenSize.xy).rgb).y;
		splitColor.b = (LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x + splitAmountG, uv.y + splitAmountG) * _ScreenSize.xy).rgb).z;
		splitColor.a = 1;
		return splitColor;
	}
	
	
	float4 Frag_Horizontal(Varyings i): SV_Target
	{
		half strength = 0;
		#if USING_Frequency_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 *cos(_Time.y * _Frequency);
		#endif
		half3 color = RGBSplit_Horizontal(i.texcoord.xy, _Amount * strength, _Time.y * _Speed).rgb;

		return half4(color, 1);
	}
	
	float4 Frag_Vertical(Varyings i): SV_Target
	{

		half strength = 0;
		#if USING_Frequency_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 *cos(_Time.y * _Frequency);
		#endif
		half3 color = RGBSplit_Vertical(i.texcoord.xy, _Amount * strength, _Time.y * _Speed).rgb;

		return half4(color, 1);

	}

	float4 Frag_Horizontal_Vertical(Varyings i) : SV_Target
	{

		half strength = 0;
		#if USING_Frequency_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 *cos(_Time.y * _Frequency);
		#endif
		half3 color = RGBSplit_Horizontal_Vertical(i.texcoord.xy, _Amount * strength, _Time.y * _Speed).rgb;

		return half4(color, 1);

	}

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchRGBSplitv3_Horizontal"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplitv3_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplitv3_Horizontal_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal_Vertical 
                #pragma vertex Vert
            ENDHLSL
        }

    }
    Fallback Off
}
