// #ifndef ZPOST_PROCESS_INCLUDED
// #define ZPOST_PROCESS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
//------------------------------------------------------------------------------------------------------
// Generic functions
//------------------------------------------------------------------------------------------------------

float rand(float n)
{
	return frac(sin(n) * 13758.5453123 * 0.01);
}

float rand(float2 n)
{
	return frac(sin(dot(n, float2(12.9898, 78.233))) * 43758.5453);
}

float2 RotateUV(float2 uv, float rotation)
{
	float cosine = cos(rotation);
	float sine = sin(rotation);
	float2 pivot = float2(0.5, 0.5);
	float2 rotator = (mul(uv - pivot, float2x2(cosine, -sine, sine, cosine)) + pivot);
	return saturate(rotator);
}
// #endif