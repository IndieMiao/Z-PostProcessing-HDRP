using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;
namespace ZPostHDRP
{
[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchScreenShake")]
public sealed class GlitchScreenShake : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public DirectionParameter direction = new DirectionParameter{value = Direction.Horizontal};
    public ClampedFloatParameter effectIntensity = new ClampedFloatParameter(0.35f, 0f, 1f);

    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchScreenShake";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchScreenShake is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetFloat("_ScreenShake", effectIntensity.value);
        HDUtils.DrawFullScreen(cmd, m_Material, destination, null, (int)direction.value);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
}