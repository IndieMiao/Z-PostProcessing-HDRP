using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{
[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchImageBlockV2")]
public sealed class GlitchImageBlockV2 : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter Fade= new ClampedFloatParameter(1f,0f,1f);
    public ClampedFloatParameter Speed= new ClampedFloatParameter(0.5f,0f,1f);
    public ClampedFloatParameter Amount= new ClampedFloatParameter(1f,0f,10f);
    public ClampedFloatParameter BlockLayer1_U= new ClampedFloatParameter(2f,0f,50f);
    public ClampedFloatParameter BlockLayer1_V= new ClampedFloatParameter(16f,0f,50f);
    public ClampedFloatParameter BlockLayer1_Indensity= new ClampedFloatParameter(8f,0f,50f);
    public ClampedFloatParameter RGBSplitIndensity= new ClampedFloatParameter(2f,0f,50f);
    public BoolParameter BlockVisualizeDebug = new BoolParameter(false);

    private float TimeX = 1.0f;

    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchImageBlockV2";

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
        //using _Parmas and _Parmas2 to combine Parameters
        m_Material.SetVector("_Params", new Vector3(TimeX * Speed.value, Amount.value, Fade.value));
        m_Material.SetVector("_Params2", new Vector4(BlockLayer1_U.value, BlockLayer1_V.value, BlockLayer1_Indensity.value, RGBSplitIndensity.value));

        if(BlockVisualizeDebug.value)
        {
            //debug
            HDUtils.DrawFullScreen(cmd, m_Material, destination,null, 1);
        }
        else
        {
            HDUtils.DrawFullScreen(cmd, m_Material, destination,null, 0);
        }
    }

	public override void Cleanup() => CoreUtils.Destroy(m_Material);
}
}