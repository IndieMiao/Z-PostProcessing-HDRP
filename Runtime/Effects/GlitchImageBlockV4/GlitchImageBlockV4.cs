using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{
[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchImageBlockV4")]
public sealed class GlitchImageBlockV4 : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter Speed = new ClampedFloatParameter (10f,0f,50f);
    public ClampedFloatParameter BlockSize = new ClampedFloatParameter (8f,0f,50f);
    public ClampedFloatParameter MaxRGBSplitX = new ClampedFloatParameter( 1f ,0f, 25f );
    public ClampedFloatParameter MaxRGBSplitY = new ClampedFloatParameter( 1f ,0f, 25f );
    private float TimeX = 1.0f;

    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchImageBlockV4";
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
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchImageBlockV2 is unable to load.");
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

        m_Material.SetVector(ShaderIDs.Params, new Vector4(Speed.value, BlockSize.value, MaxRGBSplitX.value, MaxRGBSplitY.value));

        HDUtils.DrawFullScreen(cmd, m_Material, destination);
        
    }

	public override void Cleanup() => CoreUtils.Destroy(m_Material);
}
}