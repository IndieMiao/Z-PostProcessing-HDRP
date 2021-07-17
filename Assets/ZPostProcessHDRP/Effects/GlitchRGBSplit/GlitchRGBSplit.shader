Shader "Hidden/Shader/GlitchRGBSplit"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZPostProcessing.hlsl"

    float _Intensity;
    TEXTURE2D_X(_InputTexture);
	
	uniform half4 _Params;
	uniform half3 _Params2;

	#define _Fading _Params.x
	#define _Amount _Params.y
	#define _Speed _Params.z
	#define _CenterFading _Params.w
	#define _TimeX _Params2.x
	#define _AmountR _Params2.y
	#define _AmountB _Params2.z

	half4 Frag_Horizontal(Varyings i): SV_Target
	{
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		float2 uv = i.texcoord.xy;
		half time = _TimeX * 6 * _Speed;
		half splitAmount = (1.0 + sin(time)) * 0.5;
		splitAmount *= 1.0 + sin(time * 2) * 0.5;
		splitAmount = pow(splitAmount, 3.0);
		splitAmount *= 0.05;
		float distance = length(uv - float2(0.5, 0.5));
		splitAmount *=  _Fading * _Amount;
		splitAmount *= lerp(1, distance, _CenterFading);

		half3 colorR = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x + splitAmount * _AmountR, uv.y) * _ScreenSize.xy).rgb;
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  uv * _ScreenSize.xy);
		half3 colorB = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x - splitAmount * _AmountB, uv.y) * _ScreenSize.xy).rgb;

		half3 splitColor = half3(colorR.r, sceneColor.g, colorB.b);
		half3 finalColor = lerp(sceneColor.rgb, splitColor, _Fading);

		return half4(finalColor, 1.0);

	}

	half4 Frag_Vertical(Varyings i) : SV_Target
	{
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		float2 uv = i.texcoord.xy;
		half time = _TimeX * 6 * _Speed;
		half splitAmount = (1.0 + sin(time)) * 0.5;
		splitAmount *= 1.0 + sin(time * 2) * 0.5;
		splitAmount = pow(splitAmount, 3.0);
		splitAmount *= 0.05;
		float distance = length(uv - float2(0.5, 0.5));
		splitAmount *= _Fading * _Amount;
		splitAmount *= _Fading * _Amount;

		half3 colorR = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x , uv.y + splitAmount * _AmountR) * _ScreenSize.xy).rgb;
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  uv * _ScreenSize.xy);
		half3 colorB = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x, uv.y - splitAmount * _AmountB) * _ScreenSize.xy).rgb;

		half3 splitColor = half3(colorR.r, sceneColor.g, colorB.b);
		half3 finalColor = lerp(sceneColor.rgb, splitColor, _Fading);

		return half4(finalColor, 1.0);

	}
	
	half4 Frag_Horizontal_Vertical(Varyings i) : SV_Target
	{

        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		float2 uv = i.texcoord.xy;
		half time = _TimeX * 6 * _Speed;
		half splitAmount = (1.0 + sin(time)) * 0.5;
		splitAmount *= 1.0 + sin(time * 2) * 0.5;
		splitAmount = pow(splitAmount, 3.0);
		splitAmount *= 0.05;
		float distance = length(uv - float2(0.5, 0.5));
		splitAmount *= _Fading * _Amount;
		splitAmount *= _Fading * _Amount;

		float splitAmountR = splitAmount * _AmountR;
		float splitAmountB = splitAmount * _AmountB;

		half3 colorR = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x + splitAmountR, uv.y + splitAmountR) * _ScreenSize.xy).rgb;
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  uv * _ScreenSize.xy);
		half3 colorB = LOAD_TEXTURE2D_X(_InputTexture,  float2(uv.x - splitAmountB, uv.y - splitAmountB) * _ScreenSize.xy).rgb;

		half3 splitColor = half3(colorR.r, sceneColor.g, colorB.b);
		half3 finalColor = lerp(sceneColor.rgb, splitColor, _Fading);

		return half4(finalColor, 1.0);

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
            Name "GlitchRGBSplit_Horizontal"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplit_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Vertical
                #pragma vertex Vert
            ENDHLSL
        }
        Pass
        {
            Name "GlitchRGBSplit_Horizontal_Vertical"
            HLSLPROGRAM
                #pragma fragment Frag_Horizontal_Vertical 
                #pragma vertex Vert
            ENDHLSL
        }

    }
    Fallback Off
}
