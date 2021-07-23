using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchScanLineJitter")]
public sealed class GlitchScanLineJitter : CustomPostProcessVolumeComponent, IPostProcessComponent 
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public DirectionParameter JitterDirection  = new DirectionParameter { value = Direction.Horizontal };

    public IntervalTypeParameter intervalType = new IntervalTypeParameter { value = IntervalType.Random };

    public ClampedFloatParameter frequency = new ClampedFloatParameter(1f,0f,25f);
    public ClampedFloatParameter JitterIndensity= new ClampedFloatParameter(0.1f,0f,25f);
    private float randomFrequency;


    Material m_Material;


    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchScanLineJitter";
    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
        internal static readonly int JitterIndensity = Shader.PropertyToID("_ScanLineJitter");
    }

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchScanLineJitter is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;
        
        FrequencyUtility.UpdateFrequency(m_Material ,intervalType, frequency,out  randomFrequency);

        float displacement = 0.005f + Mathf.Pow(JitterIndensity.value, 3) * 0.1f;
        float threshold = Mathf.Clamp01(1.0f - JitterIndensity.value * 1.2f);


        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetVector(ShaderIDs.Params, new Vector3(displacement, threshold, intervalType.value == IntervalType.Random ? randomFrequency : frequency.value));
        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }
    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}

}