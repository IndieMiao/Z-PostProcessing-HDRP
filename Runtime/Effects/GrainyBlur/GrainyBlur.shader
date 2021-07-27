Shader "Hidden/Shader/GrainyBlur"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_BlitTexture);
    TEXTURE2D_X(_InputTexture);
    TEXTURE2D_X(_BufferRT);
	half2 _Params;

	#define _BlurRadius _Params.x
	#define _Iteration _Params.y
	
	float Rand(float2 n)
	{
		return sin(dot(n, half2(1233.224, 1743.335)));
	}

	half4 GrainyBlur(Varyings i)
	{
		half2 randomOffset = float2(0.0, 0.0);
		half4 finalColor = half4(0.0, 0.0, 0.0, 0.0);
		float random = Rand(i.texcoord);
		
		for (int k = 0; k < int(_Iteration); k ++)
		{
			random = frac(43758.5453 * random + 0.61432);;
			randomOffset.x = (random - 0.5) * 2.0;
			random = frac(43758.5453 * random + 0.61432);
			randomOffset.y = (random - 0.5) * 2.0;
			
			// finalColor += LOAD_TEXTURE2D_X(_BlitTexture,  half2(i.texcoord + randomOffset * _BlurRadius) * _ScreenSize.xy);
			finalColor += LOAD_TEXTURE2D_X(_BufferRT,  half2(i.texcoord + randomOffset * _BlurRadius) * _ScreenSize.xy);
		}
		return finalColor / _Iteration;
	}

	half4 Frag(Varyings i): SV_Target
	{
		return GrainyBlur(i);
	}

    // float4 CustomPostProcess(Varyings input) : SV_Target
    // {
    //     UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    //     uint2 positionSS = input.texcoord * _ScreenSize.xy;
    //     float3 outColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz;

    //     return float4(outColor, 1);
    // }

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GrainyBlur"
            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
