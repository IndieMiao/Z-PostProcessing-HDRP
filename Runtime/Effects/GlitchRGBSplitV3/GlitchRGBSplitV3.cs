using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{
[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchRGBSplitV3")]
public sealed class GlitchRGBSplitV3 : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public GlitchRGBSplitDirectionParameter SplitDirection = new GlitchRGBSplitDirectionParameter{ value =  DirectionEX.Horizontal};
    public IntervalTypeParameter intervalType = new IntervalTypeParameter { value = IntervalType.Random };
    public ClampedFloatParameter frequency= new ClampedFloatParameter( 3f, 0.1f, 25f );
    public ClampedFloatParameter Amount = new ClampedFloatParameter( 30f, 0f, 200f );
    public ClampedFloatParameter Speed = new ClampedFloatParameter( 15f, 0f, 200f );

    Material m_Material;
    private float randomFrequency;
    private int frameCount = 0;
    // private float TimeX = 1.0f;

    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
    }

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchRGBSplitV3";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchRGBSplit is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);

        FrequencyUtility.UpdateFrequency(m_Material, intervalType,frameCount, frequency, out randomFrequency);

        m_Material.SetVector(ShaderIDs.Params, new Vector3(intervalType.value == IntervalType.Random ? randomFrequency : frequency
             .value, Amount.value, Speed.value));

        HDUtils.DrawFullScreen(cmd, m_Material, destination,null, (int)SplitDirection.value);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
}