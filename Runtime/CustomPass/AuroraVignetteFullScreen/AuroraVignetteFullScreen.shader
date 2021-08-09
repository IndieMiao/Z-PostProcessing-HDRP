Shader "Hidden/AuroraVignetteFullScreen"
{
    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    // The PositionInputs struct allow you to retrieve a lot of useful information for your fullScreenShader:
    // struct PositionInputs
    // {
    //     float3 positionWS;  // World space position (could be camera-relative)
    //     float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
    //     uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
    //     uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
    //     float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
    //     float  linearDepth; // View space Z coordinate                              : [Near, Far]
    // };

    // To sample custom buffers, you have access to these functions:
    // But be careful, on most platforms you can't sample to the bound color buffer. It means that you
    // can't use the SampleCustomColor when the pass color buffer is set to custom (and same for camera the buffer).
    // float4 SampleCustomColor(float2 uv);
    // float4 LoadCustomColor(uint2 pixelCoords);
    // float LoadCustomDepth(uint2 pixelCoords);
    // float SampleCustomDepth(float2 uv);

    // There are also a lot of utility function you can use inside Common.hlsl and Color.hlsl,
    // you can check them out in the source code of the core SRP package.

    uniform half _VignetteArea;
	uniform half _VignetteSmoothness;
	uniform half _ColorChange;
	uniform half4 _Color;
	uniform half _TimeX;
	uniform half3 _ColorFactor;
	uniform half _Fading;

        float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        const float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        // float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);
    
        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1);
    	
    	float2 uv = varyings.positionCS.xy / _ScreenSize.xy;
        float2 uv0 = uv - float2(0.5 + 0.5 * sin(1.4 * 6.28 * uv.x + 2.8 * _TimeX), 0.5);
        float3 wave = float3(0.5 * (cos(sqrt(dot(uv0, uv0)) * 5.6) + 1.0), cos(4.62 * dot(uv, uv) + _TimeX), cos(distance(uv, float2(1.6 * cos(_TimeX * 2.0), 1.0 * sin(_TimeX * 1.7))) * 1.3));
        half waveFactor = dot(wave, _ColorFactor) / _ColorChange;
        half vignetteIndensity = 1.0 - smoothstep(_VignetteArea, _VignetteArea - 0.05 - _VignetteSmoothness, length(float2(0.5, 0.5) - uv));
        half3 AuroraColor = half3
		(
			_ColorFactor.r * 0.5 * (sin(1.28 * waveFactor + _TimeX * 3.45) + 1.0),
			_ColorFactor.g * 0.5 * (sin(1.28 * waveFactor + _TimeX * 3.15) + 1.0),
			_ColorFactor.b * 0.4 * (sin(1.28 * waveFactor + _TimeX * 1.26) + 1.0)
		);
        half3 finalColor = lerp(color.rgb, AuroraColor, vignetteIndensity * _Fading);
		return half4(finalColor, 1.0);
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Custom Pass 0"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}
