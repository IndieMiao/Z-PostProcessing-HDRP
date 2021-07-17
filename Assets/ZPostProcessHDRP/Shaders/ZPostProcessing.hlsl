// #ifndef ZPOST_PROCESS_INCLUDED
// #define ZPOST_PROCESS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

//------------------------------------------------------------------------------------------------------
// Base Define
//------------------------------------------------------------------------------------------------------

#define fixed half
#define fixed2 half2
#define fixed3 half3
#define fixed4 half4
#define fixed4x4 half4x4
#define fixed3x3 half3x3
#define fixed2x2 half2x2
#define sampler2D_half sampler2D
#define sampler2D_float sampler2D
#define samplerCUBE_half samplerCUBE
#define samplerCUBE_float samplerCUBE

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