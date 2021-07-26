Shader "Hidden/Shader/RtTest"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "../../Shaders/ZCommon.hlsl"

    // List of properties to control your post process effect
    float _Intensity;
    float _ColorWeight;
    float _BlendWeight;
    TEXTURE2D_X(_InputTexture);
    TEXTURE2D_X(_BlitTexture);

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        uint2 positionSS = input.texcoord * _ScreenSize.xy;
        float3 outBlit= LOAD_TEXTURE2D_X(_BlitTexture, positionSS).xyz * _ColorWeight;
        float3 outRender= LOAD_TEXTURE2D_X(_InputTexture, positionSS).xyz * _ColorWeight;
        float3 outColor= lerp(outBlit, outRender, _BlendWeight);

        return float4(outColor, 1);
    }

    ENDHLSL

    SubShader
    {
        ZWrite Off ZTest Always Blend Off Cull Off
        Pass
        {
            Name "RtTest"
            HLSLPROGRAM
                #pragma fragment CustomPostProcess
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
