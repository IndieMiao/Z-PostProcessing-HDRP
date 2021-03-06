using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchScreenJump")]
public sealed class GlitchScreenJump : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public DirectionParameter direction = new DirectionParameter{value = Direction.Horizontal};
    public ClampedFloatParameter effectIntensity = new ClampedFloatParameter(0.35f, 0f, 1f);

    Material m_Material;
    float ScreenJumpTime;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchScreenJump";

    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
    }

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchScreenJump is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        ScreenJumpTime += Time.deltaTime * effectIntensity.value * 9.8f;

        Vector2 ScreenJumpVector = new Vector2(effectIntensity.value, ScreenJumpTime);


        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetVector(ShaderIDs.Params, ScreenJumpVector);

        if(direction.value == Direction.Horizontal)
        {
            HDUtils.DrawFullScreen(cmd, m_Material, destination, null, 0);
        }
        else{

            HDUtils.DrawFullScreen(cmd, m_Material, destination, null, 1);
        }
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}

}