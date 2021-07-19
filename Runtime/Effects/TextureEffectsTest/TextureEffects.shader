Shader "Hidden/Shader/TextureEffects"
{
    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch


    #include "../../Shaders/ZCommon.hlsl"


    // List of properties to control your post process effect
    float _Intensity;
    TEXTURE2D_X(_InputTexture);
    // TEXTURE2D(_TestImage);
    sampler2D _TestImage;

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        uint2 positionSS = input.texcoord * _ScreenSize.xy;
        // float3 outColor = LOAD_TEXTURE2D(_TestImage, positionSS).xyz;
        float3 outColor = tex2D(_TestImage, input.texcoord).xyz;

        return float4(outColor, 1);
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "TextureEffecs"
            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment CustomPostProcess
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
