Shader "Hidden/Shader/GlitchLineJitter"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);

	#pragma shader_feature USING_FREQUENCY_INFINITE
	
	uniform half3 _Params;
	#define _Amount _Params.x
	#define _Threshold _Params.y
	#define _Frequency _Params.z
	
	
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

	
	float randomNoise(float x, float y)
	{
		return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
	}
	
	
	half4 Frag_Horizontal(Varyings i): SV_Target
	{
		half strength = 0;
		#if USING_FREQUENCY_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 * cos(_Time.y * _Frequency);
		#endif
		
		
		float jitter = randomNoise(i.texcoord.y, _Time.x) * 2 - 1;
		jitter *= step(_Threshold, abs(jitter)) * _Amount * strength;
		
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  frac(i.texcoord + float2(jitter, 0))*_ScreenSize.xy);
		
		return sceneColor;
	}
	
	half4 Frag_Vertical(Varyings i): SV_Target
	{
		half strength = 0;
		#if USING_FREQUENCY_INFINITE
			strength = 1;
		#else
			strength = 0.5 + 0.5 * cos(_Time.y * _Frequency);
		#endif
		
		float jitter = randomNoise(i.texcoord.x, _Time.x) * 2 - 1;
		jitter *= step(_Threshold, abs(jitter)) * _Amount * strength;
		
		half4 sceneColor = LOAD_TEXTURE2D_X(_InputTexture,  frac(i.texcoord + float2(0, jitter))*_ScreenSize.xy);
		
		return sceneColor;
	}


    ENDHLSL

	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		
		Pass
		{

            Name "GlitchLineJitter_H"
			HLSLPROGRAM
			
			#pragma vertex Vert
			#pragma fragment Frag_Horizontal
			
			ENDHLSL
			
		}
		
		Pass
		{
            Name "GlitchLineJitter_V"
			HLSLPROGRAM
			
			#pragma vertex Vert
			#pragma fragment Frag_Vertical
			
			ENDHLSL
			
		}
	}
    Fallback Off
}
