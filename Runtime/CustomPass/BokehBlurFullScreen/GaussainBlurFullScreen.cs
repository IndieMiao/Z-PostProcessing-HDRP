using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

class GaussainBlurFullScreen : CustomPass
{
    [Range(0, 20)] public float BlurRadius = 1f;

    [Range(3, 128)] public int Iteration = 32;
    public bool DownScaleSample = true;
    [SerializeField, HideInInspector] private Shader fullscreenShader;
    private Material fullscreenMaterial;
    private RTHandle blurBuffer;

    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        if(fullscreenShader == null)
            fullscreenShader = Shader.Find("Hidden/GaussianBlurFullScreen");
        fullscreenMaterial= CoreUtils.CreateEngineMaterial(fullscreenShader);

        blurBuffer = RTHandles.Alloc(
            Vector2.one*0.5f , TextureXR.slices, dimension: TextureXR.dimension,
            colorFormat: GraphicsFormat.B10G11R11_UFloatPack32, // We don't need alpha in the blur
            useDynamicScale: true, name: "BlurBuffer"
        ); 
    }

    protected override void Execute(CustomPassContext ctx)
    {
        if (fullscreenMaterial != null && BlurRadius > 0)
        {
            GenerateGaussianMaps(ctx);
        }
    }

    private void GenerateGaussianMaps(CustomPassContext ctx)
    {
        RTHandle source = (targetColorBuffer == TargetBuffer.Camera) ? ctx.cameraColorBuffer : ctx.customColorBuffer.Value;
        var targetBuffer = source;
        CustomPassUtils.GaussianBlur(ctx, source,targetBuffer,blurBuffer,sampleCount:Iteration, radius: BlurRadius, downSample:DownScaleSample);

    }

    protected override void Cleanup()
    {
        CoreUtils.Destroy(fullscreenMaterial);
        blurBuffer.Release();
    }
}