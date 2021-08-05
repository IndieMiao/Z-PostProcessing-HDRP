using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

class OutlineFullScreenV2 : CustomPass
{
    public LayerMask outlineLayer = 0;
    // [ColorUsage(false, true)]
    public Color outlineColor = Color.black;
    public float threshold = 1;
    [Range(1,10)]
    public float outlineWidth = 1;
    [SerializeField, HideInInspector]
    Shader outlineFullscreenShader;
    Material outlineFullscreen;
    RTHandle outlineBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        outlineFullscreenShader = Shader.Find("Hidden/OutlineFullScreenV2");
        outlineFullscreen = CoreUtils.CreateEngineMaterial(outlineFullscreenShader);

        outlineBuffer = RTHandles.Alloc(Vector2.one,
					TextureXR.slices,
					dimension: TextureXR.dimension,
					colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
					useDynamicScale: true,
					name: "Outline Buffer");
    }

    protected override void Execute(CustomPassContext ctx)
    {
        //设置需要渲染的物体
        CoreUtils.SetRenderTarget(ctx.cmd,outlineBuffer,ClearFlag.Color);
        //渲染 目标物体
        CustomPassUtils.DrawRenderers(ctx,outlineLayer);

        //设置效果的参数
        ctx.propertyBlock.SetColor("_OutlineColor", outlineColor);
        ctx.propertyBlock.SetTexture("_OutlineBuffer",outlineBuffer);
        ctx.propertyBlock.SetFloat("_Threshold",threshold);
        ctx.propertyBlock.SetFloat("_OutlineWidth",outlineWidth);

        //进行渲染
        CoreUtils.SetRenderTarget(ctx.cmd, ctx.cameraColorBuffer,ClearFlag.None);
        CoreUtils.DrawFullScreen(ctx.cmd,outlineFullscreen,ctx.propertyBlock,shaderPassId:0);
    }

    protected override void Cleanup()
    {
        //清理buffer 
        CoreUtils.Destroy(outlineFullscreen);
        outlineBuffer.Release();
    }
}