#ifndef ZPOST_COMMON_INCLUDED
#define ZPOST_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

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

//------------------------------------------------------------------------------------------------------
// Generic functions
//------------------------------------------------------------------------------------------------------

// float rand(float n)
// {
// 	return frac(sin(n) * 13758.5453123 * 0.01);
// }

// float rand(float2 n)
// {
// 	return frac(sin(dot(n, float2(12.9898, 78.233))) * 43758.5453);
// }

// float2 RotateUV(float2 uv, float rotation)
// {
// 	float cosine = cos(rotation);
// 	float sine = sin(rotation);
// 	float2 pivot = float2(0.5, 0.5);
// 	float2 rotator = (mul(uv - pivot, float2x2(cosine, -sine, sine, cosine)) + pivot);
// 	return saturate(rotator);
// }

    
#endif // ZPOST_COMMON_INCLUDED

