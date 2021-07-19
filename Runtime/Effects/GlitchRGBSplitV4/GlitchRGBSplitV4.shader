Shader "Hidden/Shader/GlitchRGBSplitV4"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	

	uniform half2 _Params;

	#define _Indensity _Params.x
	#define _TimeX _Params.y

	float randomNoise(float x, float y)
	{
		return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
	}

	half4 Frag_Horizontal(Varyings i) : SV_Target
	{
		float splitAmount = _Indensity * randomNoise(_TimeX, 2);

		half4 ColorR = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x + splitAmount, i.texcoord.y) * _ScreenSize.xy);
		half4 ColorG = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy);
		half4 ColorB = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x - splitAmount, i.texcoord.y) * _ScreenSize.xy);

		return half4(ColorR.r, ColorG.g, ColorB.b, 1);
	}

	half4 Frag_Vertical(Varyings i) : SV_Target
	{

		float splitAmount =  _Indensity * randomNoise(_TimeX, 2);

		half4 ColorR = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy);
		half4 ColorG = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x, i.texcoord.y + splitAmount) * _ScreenSize.xy);
		half4 ColorB = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x, i.texcoord.y - splitAmount) * _ScreenSize.xy);

		return half4(ColorR.r, ColorG.g, ColorB.b, 1);
	}

	half4 Frag_Horizontal_Vertical(Varyings i) : SV_Target
	{

		float splitAmount = _Indensity * randomNoise(_TimeX, 2);

		half4 ColorR = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy);
		half4 ColorG = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x + splitAmount, i.texcoord.y + splitAmount) * _ScreenSize.xy);
		half4 ColorB = LOAD_TEXTURE2D_X(_InputTexture,  float2(i.texcoord.x - splitAmount, i.texcoord.y - splitAmount) * _ScreenSize.xy);

		return half4(ColorR.r, ColorG.g, ColorB.b, 1);
	}


    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchRGBSplitv4_Horizontal"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplitv4_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplitv4_Horizontal_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal_Vertical 
                #pragma vertex Vert
            ENDHLSL
        }

    }
    Fallback Off
}
