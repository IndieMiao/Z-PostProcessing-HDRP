using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{
[Serializable]
public sealed class DirectionParameter : VolumeParameter<Direction> { }
[Serializable]
public sealed class IntervalTypeParameter : VolumeParameter<IntervalType> { }

[Serializable, VolumeComponentMenu("ZFullscreenPost/Glitch/GlitchLineBlock")]
public sealed class GlitchLineBlock : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public DirectionParameter blockDirection = new DirectionParameter { value = Direction.Horizontal };

    public IntervalTypeParameter intervalType = new IntervalTypeParameter { value = IntervalType.Random };

    public ClampedFloatParameter frequency = new ClampedFloatParameter (1f, 0f, 25f);

    public ClampedFloatParameter Amount = new ClampedFloatParameter (  0.5f,0f,1f );

    public ClampedFloatParameter LinesWidth = new ClampedFloatParameter ( 1f, 0.1f, 10f );

    public ClampedFloatParameter Speed = new ClampedFloatParameter (0.8f,0f,1f );

    public ClampedFloatParameter Offset = new ClampedFloatParameter (1f,0f,13f) ;

    public ClampedFloatParameter Alpha = new ClampedFloatParameter (1f,0f,1f) ;
    private float TimeX = 1.0f;
    private float randomFrequency;
    private int frameCount = 0;
    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchLineBlock";
    static class ShaderIDs
    {

        internal static readonly int Params = Shader.PropertyToID("_Params");
        internal static readonly int Params2 = Shader.PropertyToID("_Params2");
    }
    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchLineBlock is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        TimeX += Time.deltaTime;
        if (TimeX > 100)
        {
            TimeX = 0;
        }
        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetVector(ShaderIDs.Params, new Vector3(
            intervalType.value == IntervalType.Random ? randomFrequency : frequency.value,
            TimeX * Speed.value* 0.2f , Amount.value));

       m_Material.SetVector(ShaderIDs.Params2, new Vector3(Offset.value, 1 / LinesWidth.value, Alpha.value));

        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }
    void UpdateFrequency(Material mat)
    {
        if (intervalType.value == IntervalType.Random)
        {
            if (frameCount > frequency.value)
            {

                frameCount = 0;
                randomFrequency = UnityEngine.Random.Range(0, frequency.value);
            }
            frameCount++;
        }

        if (intervalType.value == IntervalType.Infinite)
        {
            mat.EnableKeyword("USING_FREQUENCY_INFINITE");
        }
        else
        {
            mat.DisableKeyword("USING_FREQUENCY_INFINITE");
        }
    } 

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
}