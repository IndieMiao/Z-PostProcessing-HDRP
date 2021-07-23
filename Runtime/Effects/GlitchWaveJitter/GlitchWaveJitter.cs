using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchWaveJitter")]
public sealed class GlitchWaveJitter : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public DirectionParameter direction = new DirectionParameter { value = Direction.Vertical };
    public IntervalTypeParameter intervalType = new IntervalTypeParameter { value = IntervalType.Random };
    public ClampedFloatParameter frequency = new ClampedFloatParameter(1f,0f,25f) ;
    public ClampedFloatParameter RGBSplit= new ClampedFloatParameter(20f,0f,50f) ;
    public ClampedFloatParameter amount = new ClampedFloatParameter (1f,0f,2f);
    public ClampedFloatParameter speed = new ClampedFloatParameter (0.35f, 0f,1f);
    public BoolParameter customResolution = new BoolParameter(false);
    public Vector2Parameter resolution = new Vector2Parameter(new Vector2(640f, 480f));

    Material m_Material;
    private float randomFrequency;
    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchWaveJitter";
    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
        internal static readonly int Resolution = Shader.PropertyToID("_Resolution");
    }

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchWaveJitter is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        FrequencyUtility.UpdateFrequency(m_Material,intervalType,frequency,out randomFrequency);
        m_Material.SetVector(ShaderIDs.Params, new Vector4(intervalType.value == IntervalType.Random ? randomFrequency : frequency.value , RGBSplit.value, speed.value, amount.value));
        m_Material.SetVector(ShaderIDs.Resolution, customResolution.value ? resolution.value : new Vector2(Screen.width, Screen.height));

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        HDUtils.DrawFullScreen(cmd, m_Material, destination, null , (int)direction.value);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}

}