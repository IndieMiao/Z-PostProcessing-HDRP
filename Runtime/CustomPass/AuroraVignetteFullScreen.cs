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
        public ClampedFloatParameter VignetteArea = new ClampedFloatParameter(0.8f,0,1);

        public ClampedFloatParameter VignetteSmoothness = new ClampedFloatParameter(0.5f, 0, 1);

        public ClampedFloatParameter VignetteFading = new ClampedFloatParameter(1, 0, 1);

        public ClampedFloatParameter ColorChange = new ClampedFloatParameter(0.1f,0.1f,1) ;

        public ClampedFloatParameter ColorFactorR = new ClampedFloatParameter(1, 0, 2);

        public ClampedFloatParameter ColorFactorG = new ClampedFloatParameter(1, 0, 2);

        public ClampedFloatParameter ColorFactorB = new ClampedFloatParameter(1, 0, 2);

        public ClampedFloatParameter FlowSpeed = new ClampedFloatParameter(1, -2, 2);
        
        [SerializeField, HideInInspector] private Shader fullscreenShader;
        
        private Material fullscreenMaterial;
        private RTHandle fullscreenBuffer;
        private float timeX = 1.0f;

        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            fullscreenShader = Shader.Find("Hidden/AuroraVignetteFullScreen");
            fullscreenMaterial= CoreUtils.CreateEngineMaterial(fullscreenShader);
            fullscreenBuffer = RTHandles.Alloc(Vector2.one,
                TextureXR.slices,
                dimension: TextureXR.dimension,
                colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
                useDynamicScale: true,
                name: "Outline Buffer");
        }

        static class ShaderIDs
        {
            internal static readonly int VignetteArea = Shader.PropertyToID("_VignetteArea");
            internal static readonly int VignetteSmoothness = Shader.PropertyToID("_VignetteSmoothness");
            internal static readonly int ColorChange = Shader.PropertyToID("_ColorChange");
            internal static readonly int ColorFactor = Shader.PropertyToID("_ColorFactor");
            internal static readonly int TimeX = Shader.PropertyToID("_TimeX");
            internal static readonly int VignetteFading = Shader.PropertyToID("_Fading");
        }


        protected override void Execute(CustomPassContext ctx)
        {
            timeX = Time.deltaTime;
            if (timeX > 100)
            {
                timeX = 0;
            }
            ctx.propertyBlock.SetFloat(ShaderIDs.VignetteArea, VignetteArea.value);
            ctx.propertyBlock.SetFloat(ShaderIDs.VignetteSmoothness, VignetteSmoothness.value);
            ctx.propertyBlock.SetFloat(ShaderIDs.ColorChange, ColorChange.value * 10f);
            ctx.propertyBlock.SetVector(ShaderIDs.ColorFactor, new Vector3(ColorFactorR.value, ColorFactorG.value, ColorFactorB.value));
            ctx.propertyBlock.SetFloat(ShaderIDs.TimeX, timeX * FlowSpeed.value);
            ctx.propertyBlock.SetFloat(ShaderIDs.VignetteFading, VignetteFading.value); 
        }

        protected override void Cleanup()
        {
            CoreUtils.Destroy(fullscreenMaterial);
            fullscreenBuffer.Release();
        }
    }
}
