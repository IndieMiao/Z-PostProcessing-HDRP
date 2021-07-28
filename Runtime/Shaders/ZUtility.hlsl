#ifndef Z_UTILITY_LIBRARY
#define Z_UTILITY_LIBRARY

float SoftThreshHold(float x, float threshold, float size)
{   
return saturate((x-threshold) / max(size,Eps_float()));
}

#endif //  Z_UTILITY_LIBRARY
