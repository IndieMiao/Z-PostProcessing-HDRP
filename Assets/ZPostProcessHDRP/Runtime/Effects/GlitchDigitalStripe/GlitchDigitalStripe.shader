Shader "Hidden/Shader/GlitchDigitalStripe"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"

    // List of properties to control your post process effect
    // Parameters
    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	sampler2D _NoiseTex;

	uniform half _EffectsIntensity;
	uniform half4 _StripColorAdjustColor;
	uniform half _StripColorAdjustIndensity;

	half4 Frag(Varyings i): SV_Target
	{
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i)
		// 基础数据准备
        half4 stripNoise = tex2D(_NoiseTex,  i.texcoord.xy);
        half threshold = 1.001 - _EffectsIntensity * 1.001;

		// uv偏移
		half uvShift = step(threshold, pow(abs(stripNoise.x), 3));
		float2 uv = frac(i.texcoord + stripNoise.yz * uvShift);

		half4 source = LOAD_TEXTURE2D_X(_InputTexture,  uv * _ScreenSize.xy);

#ifndef NEED_TRASH_FRAME
    return source;
#endif 	

		// 基于废弃帧插值
		half stripIndensity = step(threshold, pow(abs(stripNoise.w), 3)) * _StripColorAdjustIndensity;
		half3 color = lerp(source, _StripColorAdjustColor, stripIndensity).rgb;
		return float4(color, source.a);
	}

	half4 Frag_Debug(Varyings i): SV_Target
	{
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
		// 基础数据准备
		 half4 stripNoise = tex2D(_NoiseTex,  i.texcoord.xy);
		return float4(stripNoise.xyz, 1);
	}
	
    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "GlitchDigitalStripe"
            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchDigitalStripeDebug"
            HLSLPROGRAM
                #pragma fragment Frag_Debug
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
