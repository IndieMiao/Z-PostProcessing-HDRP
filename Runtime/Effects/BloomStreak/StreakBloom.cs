using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using GraphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat;
using System;
using System.Collections.Generic;

namespace  ZPostHDRP
{
    sealed class RTPyramid
    {
        public const int MaxMipLevel = 16;
        int _baseWidth, _baseHeight;
        readonly(RTHandle down, RTHandle up)[] _mips = new (RTHandle, RTHandle)[MaxMipLevel];

        public(RTHandle down, RTHandle up) this[int index]
        {
            get{ return _mips[index];}
        }
        public RTPyramid(HDCamera camera)
        {
            InitRT(camera);
        }
        public bool IsSizeChanged(HDCamera camera)
        {
            return _baseWidth == camera.actualWidth && _baseHeight == camera.actualHeight;
        }
        public void ResetRT(HDCamera camera)
        {
            ReleaseRT();
            InitRT(camera);
        }

        public void InitRT(HDCamera camera)
        {
            _baseHeight = camera.actualHeight;
            _baseHeight = camera.actualHeight;

            var width = _baseHeight;
            var height = _baseHeight / 2;

            const GraphicsFormat RTFormat = GraphicsFormat.R16G16B16A16_SFloat;
            _mips[0] = (RTHandles.Alloc(width,height,colorFormat:RTFormat),null);

            for(var i = 1; i<MaxMipLevel; i++)
            {
                width /=2;
                _mips[i] = width < 4 ? (null,null) :
                (
                    RTHandles.Alloc(width, height, colorFormat:RTFormat),
                    RTHandles.Alloc(width, height, colorFormat:RTFormat)
                );
            }

        }

        public void ReleaseRT()
        {
            foreach(var mip in _mips)
            {
                if(mip.down != null) RTHandles.Release(mip.down);
                if(mip.up!= null) RTHandles.Release(mip.up);
            }
        }

        public void ResetAT(HDCamera camera)
        {
            ReleaseRT();
            InitRT(camera);
        }
    }

[Serializable, VolumeComponentMenu("ZPostProcessHDRP/Blur/StreakBloom")]
public sealed class BloomStreak : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);
    public ClampedFloatParameter stretch = new ClampedFloatParameter(0.75f, 0f, 1);
    public ClampedFloatParameter threshold= new ClampedFloatParameter(1,0,5);
    public ColorParameter tint = new ColorParameter(new Color(0.55f, 0.55f,1),false,false,false);
    public ClampedFloatParameter hueShift = new ClampedFloatParameter(0,-1,1);

    Material m_Material;

    static class ShaderIDs
    {
        internal static readonly int ColorId = Shader.PropertyToID("_Color");
        internal static readonly int HighTextureId= Shader.PropertyToID("_HighTexture");
        internal static readonly int InputTexture= Shader.PropertyToID("_InputTexture");
        internal static readonly int Intensity= Shader.PropertyToID("_Intensity");
        internal static readonly int SourceTexture= Shader.PropertyToID("_SourceTexture");
        internal static readonly int Stretch= Shader.PropertyToID("_Stretch");
        internal static readonly int HueShift= Shader.PropertyToID("_HueShift");
        internal static readonly int Threshold= Shader.PropertyToID("_Threshold");
    }
    MaterialPropertyBlock _matPropertyBlock;

    Dictionary<int, RTPyramid> _pyramids;

    public bool IsActive() => m_Material != null && intensity.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/StreakBloom";

    RTPyramid GetRTPyramid(HDCamera camera)
    {
        RTPyramid rtpyramid;
        var cameraID = camera.camera.GetInstanceID();

        if(_pyramids.TryGetValue(cameraID, out rtpyramid))
        {
            if(!rtpyramid.IsSizeChanged(camera)) rtpyramid.ResetRT(camera);
        }
        else
        {
            _pyramids[cameraID] = rtpyramid = new RTPyramid(camera);
        }
        return rtpyramid;
    }

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume BloomStreak is unable to load.");
        if(_matPropertyBlock ==null) _matPropertyBlock = new MaterialPropertyBlock();

        _pyramids = new Dictionary<int, RTPyramid>();
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle sourceRT, RTHandle destinationRT)
    {
        if (m_Material == null)
            return;
        RTPyramid rtPyramid = GetRTPyramid(camera);

        m_Material.SetFloat(ShaderIDs.Threshold, threshold.value);
        m_Material.SetFloat(ShaderIDs.Stretch, stretch.value);
        m_Material.SetFloat(ShaderIDs.Intensity, intensity.value);
        m_Material.SetColor(ShaderIDs.ColorId, tint.value);
        m_Material.SetFloat(ShaderIDs.HueShift, hueShift.value);
        m_Material.SetTexture(ShaderIDs.SourceTexture, sourceRT);

        // sorucert - > prefilter -> mip 0 得到初始图像
        HDUtils.DrawFullScreen(cmd, m_Material, rtPyramid[0].down, _matPropertyBlock, 0);

        //向下采样
        int level = 1;
        for(; level < RTPyramid.MaxMipLevel && rtPyramid[level].down != null; level++)
        {
            _matPropertyBlock.SetTexture(ShaderIDs.InputTexture, rtPyramid[level - 1].down);
            HDUtils.DrawFullScreen(cmd, m_Material, rtPyramid[level].down, _matPropertyBlock, 1);
        }
        //向上采样 合并
        var lastRT = rtPyramid[--level].down;
        for(level--; level>=1; level--)
        {
            var mip = rtPyramid[level];
            _matPropertyBlock.SetTexture(ShaderIDs.InputTexture, lastRT);
            _matPropertyBlock.SetTexture(ShaderIDs.HighTextureId, mip.down);
            HDUtils.DrawFullScreen(cmd, m_Material, mip.up, _matPropertyBlock,2);
            lastRT = mip.up;
        }
        //最终合成
        _matPropertyBlock.SetTexture(ShaderIDs.InputTexture, lastRT);
        HDUtils.DrawFullScreen(cmd, m_Material, destinationRT, _matPropertyBlock, 3);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
        foreach(var rtpyramid in _pyramids.Values) rtpyramid.ReleaseRT();
    }
}
}