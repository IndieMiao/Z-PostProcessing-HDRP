using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchTileJitter")]
public sealed class GlitchTileJitter : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

    public DirectionParameter direction = new DirectionParameter { value = Direction.Vertical };
    public IntervalTypeParameter intervalType = new IntervalTypeParameter { value = IntervalType.Random };
    public DirectionParameter jitterDirection = new DirectionParameter{value = Direction.Horizontal};
    public ClampedFloatParameter frequency = new ClampedFloatParameter(1f,0f,25f) ;

    public ClampedFloatParameter splittingNumber = new ClampedFloatParameter (5f,0f,50f);

    public ClampedFloatParameter amount = new ClampedFloatParameter (10f,0f,100f);

    public ClampedFloatParameter speed = new ClampedFloatParameter (0.35f, 0f,1f);

    Material m_Material;
    private float randomFrequency;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchTileJitter";

    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
    }

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchTileJitter is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        FrequencyUtility.UpdateFrequency(m_Material,intervalType,frequency,out randomFrequency);

        if (jitterDirection.value == Direction.Horizontal)
        {
            m_Material.EnableKeyword("JITTER_DIRECTION_HORIZONTAL");
        }
        else
        {
            m_Material.DisableKeyword("JITTER_DIRECTION_HORIZONTAL");
        }

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetVector(ShaderIDs.Params, new Vector4(splittingNumber.value, amount.value, speed.value* 100f, intervalType.value == IntervalType.Random ? randomFrequency : frequency.value));
        HDUtils.DrawFullScreen(cmd, m_Material, destination,null, (int)direction.value);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}

}