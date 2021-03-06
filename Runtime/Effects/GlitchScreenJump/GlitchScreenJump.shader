Shader "Hidden/Shader/GlitchScreenJump"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
	
	uniform half2 _Params; // x: indensity , y : time
	#define _JumpIndensity _Params.x
	#define _JumpTime _Params.y
	
    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	half4 Frag_Horizontal(Varyings i): SV_Target
	{		
		float jump = lerp(i.texcoord.x, frac(i.texcoord.x + _JumpTime), _JumpIndensity);	
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  frac(float2(jump, i.texcoord.y)) * _ScreenSize.xy);		
		return sceneColor;
	}
	
	half4 Frag_Vertical(Varyings i): SV_Target
	{		
		float jump = lerp(i.texcoord.y, frac(i.texcoord.y + _JumpTime), _JumpIndensity);		
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture ,  frac(float2(i.texcoord.x, jump))* _ScreenSize.xy);	
		return sceneColor;
	}


    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off

        Pass
        {
            Name "GlitchScreenJump_H"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal 
                #pragma vertex Vert
            ENDHLSL
        }

        Pass
        {
            Name "GlitchScreenJump_V"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical 
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
