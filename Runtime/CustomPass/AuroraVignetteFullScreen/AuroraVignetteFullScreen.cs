using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;

namespace ZPostHDRP.CustomPass
{
    class AuroraVignetteFullScreen : UnityEngine.Rendering.HighDefinition.CustomPass
    {
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in an performance manner.
        public ClampedFloatParameter vignetteArea = new ClampedFloatParameter(0.8f,0,1);

        public ClampedFloatParameter vignetteSmothness = new ClampedFloatParameter(0.5f, 0, 1);

        public ClampedFloatParameter vignetteFading = new ClampedFloatParameter(1, 0, 1);

        public ClampedFloatParameter colorChange = new ClampedFloatParameter(0.1f,0.1f,1) ;

        public ClampedFloatParameter colorFactorR = new ClampedFloatParameter(1, 0, 2);

        public ClampedFloatParameter colorFactorG = new ClampedFloatParameter(1, 0, 2);

        public ClampedFloatParameter colorFactorB = new ClampedFloatParameter(1, 0, 2);

        public ClampedFloatParameter flowSpeed = new ClampedFloatParameter(1, -2, 2);
        [SerializeField, HideInInspector] private Shader auroraVignetteShader;
        
        private Material auroraVignetteFullscreen;
        private RTHandle auroraVignetteBuffer;

        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            auroraVignetteShader = Shader.Find("Hidden/AuroraVignetteFullScreen");
            auroraVignetteFullscreen= CoreUtils.CreateEngineMaterial(auroraVignetteShader);
            auroraVignetteBuffer = RTHandles.Alloc(Vector2.one,
                TextureXR.slices,
                dimension: TextureXR.dimension,
                colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
                useDynamicScale: true,
                name: "Outline Buffer");
        }

        protected override void Execute(CustomPassContext ctx)
        {
            // Executed every frame for all the camera inside the pass volume.
            // The context contains the command buffer to use to enqueue graphics commands.
        }

        protected override void Cleanup()
        {
            // Cleanup code
        }
    }
}
