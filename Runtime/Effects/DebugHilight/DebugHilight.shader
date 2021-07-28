Shader "Hidden/Shader/DebugHilight"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"
    #include "../../Shaders/ZUtility.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    float _ThreshHold;
    float _Size;
    float _MinWeight;
    TEXTURE2D_X(_InputTexture);

    float3 OverLayColor(float3 lowColor)
    {       
        return lowColor * 0.3;
    }
    float4 Frag(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        uint2 positionSS = input.texcoord * _ScreenSize.xy;
        float3 sourceColor = LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz;
        float3 hsv = RgbToHsv(sourceColor);
        float weight = (SoftThreshHold(hsv.z, _ThreshHold, _Size) +_MinWeight )/2 ;
        sourceColor *= weight;
        return float4(sourceColor, 1);
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "DebugHilight"

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
