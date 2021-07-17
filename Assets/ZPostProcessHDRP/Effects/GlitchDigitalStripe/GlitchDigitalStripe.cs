using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;
namespace ZPostHDRP
{

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Glitch/GlitchDigitalStripe")]
public sealed class GlitchDigitalStripe : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0.25f, 0f, 1f);

    public ClampedFloatParameter effectIntensity = new ClampedFloatParameter (0.25f,0,1);

    public ClampedIntParameter frequency = new ClampedIntParameter (3 , 1, 10);

    public ClampedFloatParameter stripeLength = new ClampedFloatParameter ( 0.89f, 0f, 0.99f);

    public ClampedIntParameter noiseTextureWidth = new ClampedIntParameter (20, 8, 256) ;

    public ClampedIntParameter noiseTextureHeight = new ClampedIntParameter(20, 8, 256);

    public BoolParameter needStripColorAdjust = new BoolParameter (  false );

    [ColorUsageAttribute(true, true)]
    public ColorParameter StripColorAdjustColor = new ColorParameter ( new  Color(0.1f, 0.1f, 0.1f) );

    public ClampedFloatParameter StripColorAdjustIndensity = new ClampedFloatParameter (2f, 0, 10);

    public BoolParameter DebugNoise = new BoolParameter (false);

    Texture2D _noiseTexture;
    RenderTexture _trashFrame1;
    RenderTexture _trashFrame2;
    Material m_Material;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/GlitchDigitalStripe";

    void UpdateNoiseTexture(int frame, int noiseTextureWidth, int noiseTextureHeight, float stripLength)
    {
        int frameCount = Time.frameCount;
        if (frameCount % frame != 0)
        {
            return;
        }

        _noiseTexture = new Texture2D(noiseTextureWidth, noiseTextureHeight, TextureFormat.ARGB32, false);
        _noiseTexture.wrapMode = TextureWrapMode.Clamp;
        _noiseTexture.filterMode = FilterMode.Point;

        _trashFrame1 = new RenderTexture(Screen.width, Screen.height, 0);
        _trashFrame2 = new RenderTexture(Screen.width, Screen.height, 0);
        _trashFrame1.hideFlags = HideFlags.DontSave;
        _trashFrame2.hideFlags = HideFlags.DontSave;

        Color32 color = ZPostProcessingUtility.RandomColor();

        for (int y = 0; y < _noiseTexture.height; y++)
        {
            for (int x = 0; x < _noiseTexture.width; x++)
            {
                //随机值若大于给定strip随机阈值，重新随机颜色
                if (UnityEngine.Random.value > stripLength)
                {
                    color = ZPostProcessingUtility.RandomColor();
                }
                //设置贴图像素值
                _noiseTexture.SetPixel(x, y, color);
            }
        }

        _noiseTexture.Apply();

        var bytes = _noiseTexture.EncodeToPNG();
    }
    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume GlitchDigitalStripe is unable to load.");
    }
    static class ShaderIDs
    {
        internal static readonly int indensity = Shader.PropertyToID("_Indensity");
        internal static readonly int effectIntensity = Shader.PropertyToID("_EffectsIntensity");
        internal static readonly int noiseTex = Shader.PropertyToID("_NoiseTex");
        internal static readonly int StripColorAdjustColor = Shader.PropertyToID("_StripColorAdjustColor");
        internal static readonly int StripColorAdjustIndensity = Shader.PropertyToID("_StripColorAdjustIndensity");
    }
    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        UpdateNoiseTexture(frequency.value, noiseTextureWidth.value,noiseTextureHeight.value, stripeLength.value);

        m_Material.SetFloat(ShaderIDs.effectIntensity, effectIntensity.value);

        if (_noiseTexture != null)
        {
            m_Material.SetTexture(ShaderIDs.noiseTex, _noiseTexture);
        }
        

        if (needStripColorAdjust.value == true)
        {
            m_Material.EnableKeyword("NEED_TRASH_FRAME");
            m_Material.SetColor(ShaderIDs.StripColorAdjustColor, StripColorAdjustColor.value);
            m_Material.SetFloat(ShaderIDs.StripColorAdjustIndensity, StripColorAdjustIndensity.value);
        }
        else
        {
            m_Material.DisableKeyword("NEED_TRASH_FRAME");
        }

        // m_Material.SetFloat("_Intensity", effectIntensity.value);
        m_Material.SetTexture("_InputTexture", source);

        if(DebugNoise.value)
        { HDUtils.DrawFullScreen(cmd, m_Material, destination, null, 1); }
        else
        { HDUtils.DrawFullScreen(cmd, m_Material, destination, null, 0); }
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
}
