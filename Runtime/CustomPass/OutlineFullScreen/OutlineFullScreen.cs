using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

class OutlineFullScreen : CustomPass
{
    public LayerMask outlineLayer = 0;
    [ColorUsage(false, true)]
    public Color outlineColor = Color.black;
    public float threshold = 1;
    [SerializeField, HideInInspector]
    Shader outlineFullscreenShader;
    Material outlineFullscreen;
    RTHandle outlineBuffer;
    // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
    // When empty this render pass will render to the active camera render target.
    // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
    // The render pipeline will ensure target setup and clearing happens in an performance manner.
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        outlineFullscreenShader = Shader.Find("Hidden/OutlineFullScreen");
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