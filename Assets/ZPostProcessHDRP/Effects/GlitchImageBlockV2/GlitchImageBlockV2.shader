Shader "Hidden/Shader/GlitchImageBlockV2"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    // List of properties to control your post process effect
    float _Intensity;

	uniform half3 _Params;
	uniform half4 _Params2;
    TEXTURE2D_X(_InputTexture);

    //split parameters
	#define _TimeX _Params.x
	#define _Offset _Params.y
	#define _Fade _Params.z
	#define _BlockLayer1_U _Params2.x
	#define _BlockLayer1_V _Params2.y
	#define _BlockLayer1_Indensity _Params2.z
	#define _RGBSplit_Indensity _Params2.w

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

	float randomNoise(float2 seed)
	{
		return frac(sin(dot(seed * floor(_TimeX * 30.0), float2(127.1, 311.7))) * 43758.5453123);
	}
	
	float randomNoise(float seed)
	{
		return randomNoise(float2(seed, 1.0));
	}
	
	float4 Frag(Varyings input): SV_Target
	{

        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
		float2 uv = input.texcoord.xy ;
		
		float2 blockLayer1 = floor(uv * float2(_BlockLayer1_U, _BlockLayer1_V));
		
		float lineNoise = pow(randomNoise(blockLayer1), _BlockLayer1_Indensity) * _Offset - pow(randomNoise(5.1379), 7.1) * _RGBSplit_Indensity;
		
		float4 colorR = LOAD_TEXTURE2D_X(_InputTexture,  uv*_ScreenSize.xy);

		float4 colorG = LOAD_TEXTURE2D_X(_InputTexture,  (uv + float2(lineNoise * 0.05 * randomNoise(5.0), 0))*_ScreenSize.xy);
		float4 colorB = LOAD_TEXTURE2D_X(_InputTexture,  (uv - float2(lineNoise * 0.05 * randomNoise(31.0), 0))*_ScreenSize.xy);
		
		float4 result = float4(float3(colorR.r, colorG.g, colorB.b), colorR.a + colorG.a + colorB.a);
		result = lerp(colorR, result, _Fade);
        return result;
    }
		
	float4 Frag_Debug(Varyings i): SV_Target
	{
		float2 uv = i.texcoord.xy;
		
		float2 blockLayer1 = floor(uv * float2(_BlockLayer1_U, _BlockLayer1_V));
		
		float lineNoise = pow(randomNoise(blockLayer1), _BlockLayer1_Indensity) * _Offset;
		
		return float4(lineNoise, lineNoise, lineNoise, 1);
	}	

    ENDHLSL

    SubShader
    {
        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            Name "GlitchImageBlockV2"
            HLSLPROGRAM
                #pragma fragment Frag
                #pragma vertex Vert
            ENDHLSL
        }

        Pass
        {
            ZWrite Off ZTest Always Blend Off Cull Off
            Name "GlitchImageBlockV2Debug"
            HLSLPROGRAM
                #pragma fragment Frag_Debug
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
