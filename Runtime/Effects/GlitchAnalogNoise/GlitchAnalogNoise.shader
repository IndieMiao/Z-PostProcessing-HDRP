Shader "Hidden/Shader/GlitchAnalogNoise"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"

    uniform half4 _Params;
	#define _Speed _Params.x
	#define _Fading _Params.y
	#define _LuminanceJitterThreshold _Params.z
    #define _TimeX _Params.w


    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	float randomNoise(float2 c)
	{
		return frac(sin(dot(c.xy, float2(12.9898, 78.233))) * 43758.5453);
	}

	half4 Frag(Varyings i): SV_Target
	{

		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  i.texcoord * _ScreenSize.xy);
		half4 noiseColor = sceneColor;

		half luminance = dot(noiseColor.rgb, float3(0.22, 0.707, 0.071));

		if (randomNoise(float2(_TimeX * _Speed, _TimeX * _Speed)) > _LuminanceJitterThreshold)
		{
			noiseColor = float4(luminance, luminance, luminance, luminance);
		}

		float noiseX = randomNoise(_TimeX * _Speed + i.texcoord / float2(-213, 5.53));
		float noiseY = randomNoise(_TimeX * _Speed - i.texcoord / float2(213, -5.53));
		float noiseZ = randomNoise(_TimeX * _Speed + i.texcoord / float2(213, 5.53));

		noiseColor.rgb += 0.25 * float3(noiseX,noiseY,noiseZ) - 0.125;

		noiseColor = lerp(sceneColor, noiseColor, _Fading);
		
		return noiseColor;
	}    

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "GlitchAnalogNoise"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
