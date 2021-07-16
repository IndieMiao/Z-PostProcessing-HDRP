using System;
using UnityEngine.Rendering;

namespace ZPostHDRP 
{
    [Serializable]
    public sealed class DirectionParameter : VolumeParameter<Direction> { }
    [Serializable]
    public sealed class IntervalTypeParameter : VolumeParameter<IntervalType> { }
}