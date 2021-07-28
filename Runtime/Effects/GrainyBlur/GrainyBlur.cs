using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{


[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Blur/GrainyBlur")]
public sealed class GrainyBlur : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter BlurRadius = new ClampedFloatParameter(5f, 0f, 50f);
    public ClampedIntParameter Iteration = new ClampedIntParameter(4, 1, 8);
    public ClampedFloatParameter RTDownScaling = new ClampedFloatParameter(1f, 1f, 10f);
    Material m_Material;
    RTHandle rt ;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GrainyBlur";

    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
        internal static readonly int BufferRT = Shader.PropertyToID("_BufferRT");
    }

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GrainyBlur is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        rt = RTHandles.Alloc(scaleFactor: Vector2.one * (1/RTDownScaling.value), filterMode: FilterMode.Point, wrapMode: TextureWrapMode.Clamp, dimension: TextureDimension.Tex2D);
        m_Material.SetVector(ShaderIDs.Params, new Vector2(BlurRadius.value / camera.screenSize.x, Iteration.value));
        m_Material.SetFloat("_Intensity", intensity.value);
        // m_Material.SetTexture("_BlitTexture", source);


        if(RTDownScaling.value >1f)
        {
            var screenSizeRT = camera.screenSize / RTDownScaling.value;
            HDUtils.BlitCameraTexture(cmd, source, rt, m_Material, 0);
            m_Material.SetTexture(ShaderIDs.BufferRT, rt);
            cmd.Blit(rt, destination, 0, 0);
            // HDUtils.DrawFullScreen(cmd, m_Material, destination);
        }
        else
        {
            // HDUtils.DrawFullScreen(cmd, m_Material, (RTHandle)ShaderIDs.BufferRT);
            m_Material.SetTexture(ShaderIDs.BufferRT, source);
            HDUtils.DrawFullScreen(cmd, m_Material, destination);
        }
    }

    public override void Cleanup()
    {
        rt.Release();
        CoreUtils.Destroy(m_Material);
    }
}

}