#ifndef Z_UTILITY_LIBRARY
#define Z_UTILITY_LIBRARY

float SoftThreshHold(float x, float threshold, float size)
{   
return saturate((x-threshold) / max(size,Eps_float()));
}

float remap(float inputValue, float oldmin, float oldmax, float outmin, float outmax )
{
	float clampValue = clamp(inputValue,oldmin, oldmax);
	return (outmax - outmin)*(clampValue - oldmin) + outmin;
}


#endif //  Z_UTILITY_LIBRARY
