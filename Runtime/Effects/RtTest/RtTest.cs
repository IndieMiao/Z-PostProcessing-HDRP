using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{


[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/RtTest")]
public sealed class RtTest : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter colorWeight= new ClampedFloatParameter(0.5f, 0f, 1f);
    public ClampedFloatParameter blendWeight= new ClampedFloatParameter(0.5f, 0f, 1f);
    public ClampedFloatParameter scaleRate= new ClampedFloatParameter(0.5f, 0f, 1f);

    Material m_Material;
    RTHandle rt;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/RtTest";
    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
        internal static readonly int ColorWeight = Shader.PropertyToID("_ColorWeight");
        internal static readonly int BlendWeight= Shader.PropertyToID("_BlendWeight");
    }
    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume RtTest is unable to load.");
    }
    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        rt = RTHandles.Alloc(scaleFactor: Vector2.one * scaleRate.value, filterMode: FilterMode.Point, wrapMode: TextureWrapMode.Clamp, dimension: TextureDimension.Tex2D);
        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);
        m_Material.SetFloat(ShaderIDs.ColorWeight, colorWeight.value);
        m_Material.SetFloat(ShaderIDs.BlendWeight, blendWeight.value);
        HDUtils.BlitCameraTexture(cmd, source, rt, m_Material, 0);
        // HDUtils.DrawFullScreen(cmd, m_Material, destination);
        cmd.Blit(rt, destination, 0, 0);
    }
    public override void Cleanup()
    {
        rt.Release();
        CoreUtils.Destroy(m_Material);
    }
}

}