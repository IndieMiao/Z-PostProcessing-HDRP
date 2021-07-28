using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Debug/DebugHilight")]
public sealed class DebugHilight : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter threshHold= new ClampedFloatParameter(1f, 0f, 10f);
    public ClampedFloatParameter size= new ClampedFloatParameter(0f, 0f, 0.5f);
    public ClampedFloatParameter minWeight= new ClampedFloatParameter(0.1f, 0f, 0.9f);

    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.BeforePostProcess;

    const string kShaderName = "Hidden/Shader/DebugHilight";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume DebugHilight is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetFloat("_ThreshHold", threshHold.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetFloat("_Size", size.value);
        m_Material.SetFloat("_MinWeight", minWeight.value);
        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}

}