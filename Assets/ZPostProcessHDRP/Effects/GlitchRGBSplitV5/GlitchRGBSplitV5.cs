using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{
[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchRGBSplitV5")]
public sealed class GlitchRGBSplitV5 : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter Amplitude= new ClampedFloatParameter(3f,0f,5f);
    public ClampedFloatParameter Speed= new ClampedFloatParameter(0.1f,0f,1f);

    Material m_Material;
    private Texture2D NoiseTex;

    static class ShaderIDs
    {
        internal static readonly int NoiseTex = Shader.PropertyToID("_NoiseTex");
        internal static readonly int Params = Shader.PropertyToID("_Params");
    }

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchRGBSplitV5";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
        {
            m_Material = new Material(Shader.Find(kShaderName));
            NoiseTex = Resources.Load("X-Noise256") as Texture2D;
        }
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchRGBSplit is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);

        m_Material.SetVector(ShaderIDs.Params, new Vector2(Amplitude.value, Speed.value));

        if (NoiseTex != null)
        {
            m_Material.SetTexture(ShaderIDs.NoiseTex, NoiseTex);
        }
        HDUtils.DrawFullScreen(cmd, m_Material, destination,null, 0);
   }
    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
}