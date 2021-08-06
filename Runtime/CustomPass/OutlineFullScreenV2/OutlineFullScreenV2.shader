Shader "Hidden/OutlineFullScreenV2"
{
   HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    TEXTURE2D_X(_OutlineBuffer);
    float4 _OutlineColor;
    float _Threshold;
    float _OutlineWidth;
    int _SamplePrecision;

    #define v2 1.41421
    #define c45 0.707107
    #define c225 0.9238795
    #define s225 0.3826834

    #define MAXSAMPLES 16
    static float2 samplingPositions[MAXSAMPLES] = {
        float2( 1, 0 ),
        float2( -1, 0 ),
        float2( 0, 1 ),
        float2( 0, -1 ),
        
        float2( c45, c45 ),
        float2( c45, -c45 ),
        float2( -c45, c45 ),
        float2( -c45, -c45 ),
        
        float2( c225, s225 ),
        float2( c225, -s225 ),
        float2( -c225, s225 ),
        float2( -c225, -s225 ),
        float2( s225, c225 ),
        float2( s225, -c225 ),
        float2( -s225, c225 ),
        float2( -s225, -c225 )
    };

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        const float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);

        float4 color = float4(0.0, 0.0, 0.0, 0.0); // 初始化Color
        const float luminanceThreshold = max(0.000001, _Threshold * 0.01); //灰度阈值

        // 给color 赋值
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1);

        float2 uv = posInput.positionNDC.xy * _RTHandleScale.xy;


        float4 outline = SAMPLE_TEXTURE2D_X_LOD(_OutlineBuffer, s_linear_clamp_sampler, uv, 0);
        outline.a = 0;
        const float2 uv_offset_per_pixel = 1.0/_ScreenSize .xy;

        const int sample_count = min( 2 * pow(2, _SamplePrecision ), MAXSAMPLES ) ;

        //如果outline 小于阈值 则进行outline 的计算
        if(Luminance(outline.rgb)< luminanceThreshold)
        {
            //对周围像素进行 比较
            for(int i=0; i<sample_count; i++)
            {
                float2 uvN = (posInput.positionNDC.xy +  uv_offset_per_pixel* samplingPositions[i] *_OutlineWidth ) *_RTHandleScale.xy;
                // float2 uvN = uv + _ScreenSize.zw * _RTHandleScale.xy * samplingPositions[i] *_OutlineWidth ;
                float4 neighbour = SAMPLE_TEXTURE2D_X_LOD(_OutlineBuffer, s_trilinear_repeat_sampler, uvN, 0);

                if (Luminance(neighbour) > luminanceThreshold)
                {
                    outline.rgb = _OutlineColor.rgb;
                    outline.a = 1;
                    break;
                }
            }
        }

        return outline;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "OutlineFullscreenV2 0"
            ZWrite Off ZTest Always Blend SrcAlpha OneMinusSrcAlpha Cull Off
            HLSLPROGRAM
            #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}