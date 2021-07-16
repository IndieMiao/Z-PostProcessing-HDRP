Shader "Hidden/Shader/GlitchDigitalStripe"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }

	TEXTURE2D_X(_NoiseTex);

	uniform half _Indensity;
	uniform half4 _StripColorAdjustColor;
	uniform half _StripColorAdjustIndensity;

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	half4 Frag(Varyings i): SV_Target
	{
		// 基础数据准备
		 half4 stripNoise = LOAD_TEXTURE2D_X(_NoiseTex,  i.texcoord);
		 half threshold = 1.001 - _Indensity * 1.001;

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
        Pass
        {
            Name "GlitchDigitalStripe"

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
