Shader "Hidden/Shader/GlitchScreenShake"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	uniform half _ScreenShake;
	
	float randomNoise(float x, float y)
	{
		return frac(sin(dot(float2(x, y), float2(127.1, 311.7))) * 43758.5453);
	}
	
	
	half4 Frag_Horizontal(Varyings i): SV_Target
	{
		float shake = (randomNoise(_Time.x, 2) - 0.5) * _ScreenShake;
		
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  frac(float2(i.texcoord.x + shake, i.texcoord.y)) * _ScreenSize.xy);
		
		return sceneColor;
	}
	
	half4 Frag_Vertical(Varyings i): SV_Target
	{
		
		float shake = (randomNoise(_Time.x, 2) - 0.5) * _ScreenShake;
		
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  frac(float2(i.texcoord.x, i.texcoord.y + shake))* _ScreenSize.xy);
		
		return sceneColor;
	}


    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchScreenShake_H"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchScreenShake_V"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
