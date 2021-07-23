using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace ZPostHDRP
{
    public class FrequencyUtility  
    {
        public static void UpdateFrequency(Material mat, IntervalTypeParameter iInternalType, ClampedFloatParameter iFrequency, out float randomFrequency)
        {
            randomFrequency = 0f ; 
            if (iInternalType.value == IntervalType.Random)
            {
                randomFrequency = UnityEngine.Random.Range(0, iFrequency.value);
            }

            if (iInternalType.value == IntervalType.Infinite)
            {
                mat.EnableKeyword("USING_FREQUENCY_INFINITE");
            }
            else
            {
                mat.DisableKeyword("USING_FREQUENCY_INFINITE");
            }
        }
        public static void UpdateFrequency(Material mat, IntervalTypeParameter iInternalType, int iFramecount, ClampedFloatParameter iFrequency, out float randomFrequency )
        {
            randomFrequency = 0f ;
            if (iInternalType.value == IntervalType.Random)
            {
                if (iFramecount > iFrequency.value)
                {

                    iFramecount = 0;
                    randomFrequency = UnityEngine.Random.Range(0, iFrequency.value);
                }
                iFramecount++;
            }

            if (iInternalType.value == IntervalType.Infinite)
            {
                mat.EnableKeyword("USING_FREQUENCY_INFINITE");
            }
            else
            {
                mat.DisableKeyword("USING_FREQUENCY_INFINITE");
            }
        } 
    }
}