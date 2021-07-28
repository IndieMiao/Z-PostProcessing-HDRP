Shader "Hidden/Shader/GlitchRGBSplitV2"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	
uniform half3 _Params;

#define _TimeX _Params.x
#define _Amount _Params.y
#define _Amplitude _Params.z


half4 Frag_Horizontal(Varyings i): SV_Target
{
	float splitAmout = (1.0 + sin(_TimeX * 6.0)) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 16.0) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 19.0) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 27.0) * 0.5;
	splitAmout = pow(splitAmout, _Amplitude);
	splitAmout *= (0.05 * _Amount);
	// splitAmout *= (0.05 * _Amount) * _ScreenSize.xy;
	
	half3 finalColor;
	finalColor.r = LOAD_TEXTURE2D_X(_InputTexture,  fixed2(i.texcoord.x + splitAmout, i.texcoord.y) * _ScreenSize.xy).r;
	finalColor.g = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy).g;
	finalColor.b = LOAD_TEXTURE2D_X(_InputTexture,  fixed2(i.texcoord.x - splitAmout, i.texcoord.y) * _ScreenSize.xy).b;
	
	finalColor *= (1.0 - splitAmout * 0.5);
	
	return half4(finalColor, 1.0);
}

half4 Frag_Vertical(Varyings i): SV_Target
{
	float splitAmout = (1.0 + sin(_TimeX * 6.0)) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 16.0) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 19.0) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 27.0) * 0.5;
	splitAmout = pow(splitAmout, _Amplitude);
	splitAmout *= (0.05 * _Amount);
	
	half3 finalColor;
	finalColor.r = LOAD_TEXTURE2D_X(_InputTexture,  fixed2(i.texcoord.x , i.texcoord.y +splitAmout) * _ScreenSize.xy).r;
	finalColor.g = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy).g;
	finalColor.b = LOAD_TEXTURE2D_X(_InputTexture,  fixed2(i.texcoord.x, i.texcoord.y - splitAmout) * _ScreenSize.xy).b;
	
	finalColor *= (1.0 - splitAmout * 0.5);
	
	return half4(finalColor, 1.0);
}

half4 Frag_Horizontal_Vertical(Varyings i) : SV_Target
{
	float splitAmout = (1.0 + sin(_TimeX * 6.0)) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 16.0) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 19.0) * 0.5;
	splitAmout *= 1.0 + sin(_TimeX * 27.0) * 0.5;
	splitAmout = pow(splitAmout, _Amplitude);
	splitAmout *= (0.05 * _Amount);

	half3 finalColor;
	finalColor.r = LOAD_TEXTURE2D_X(_InputTexture,  fixed2(i.texcoord.x+splitAmout, i.texcoord.y + splitAmout) * _ScreenSize.xy).r;
	finalColor.g = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy).g;
	finalColor.b = LOAD_TEXTURE2D_X(_InputTexture,  fixed2(i.texcoord.x - splitAmout, i.texcoord.y + splitAmout) * _ScreenSize.xy).b;

	finalColor *= (1.0 - splitAmout * 0.5);

	return half4(finalColor, 1.0);
}

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchRGBSplitv2_Horizontal"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplitv2_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplitv2_Horizontal_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal_Vertical 
                #pragma vertex Vert
            ENDHLSL
        }

    }
    Fallback Off
}
