using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

namespace ZPostHDRP
{
[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchRGBSplitV2")]
public sealed class GlitchRGBSplitV2 : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public GlitchRGBSplitDirectionParameter SplitDirection = new GlitchRGBSplitDirectionParameter{ value =  DirectionEX.Horizontal};
    public ClampedFloatParameter Amount = new ClampedFloatParameter( 0.5f, 0f, 1f );
    public ClampedFloatParameter Amplitude= new ClampedFloatParameter( 3f, 1f,6f);
    public ClampedFloatParameter Speed = new ClampedFloatParameter( 1f, 0f, 2f );
    Material m_Material;
    private float TimeX = 1.0f;

    static class ShaderIDs
    {
        internal static readonly int Params = Shader.PropertyToID("_Params");
    }

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchRGBSplitV2";

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

        TimeX += Time.deltaTime;
        if (TimeX > 100)
        {
            TimeX = 0;
        }

        m_Material.SetFloat("_Intensity", intensity.value);
        m_Material.SetTexture("_InputTexture", source);


        m_Material.SetVector(ShaderIDs.Params, new Vector3(TimeX * Speed.value, Amount.value, Amplitude.value));

        switch(SplitDirection.value)
        {
            case DirectionEX.Horizontal: 
                HDUtils.DrawFullScreen(cmd, m_Material, destination,null, 0);
                break;
            case DirectionEX.Vertical:
                HDUtils.DrawFullScreen(cmd, m_Material, destination,null, 1);
                break;
            case DirectionEX.Horizontal_Vertical:
                HDUtils.DrawFullScreen(cmd, m_Material, destination,null, 2);
                break;
        }
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
}