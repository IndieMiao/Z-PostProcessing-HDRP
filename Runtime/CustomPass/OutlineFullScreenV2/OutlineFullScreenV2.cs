using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace ZPostHDRP.CustomPass
{
    class OutlineFullScreenV2 : UnityEngine.Rendering.HighDefinition.CustomPass
    {
        public LayerMask OutlineLayer = 0;
        public Color OutlineColor = Color.black;
        public float Threshold = 1;
        public int SamplePrecision = 0;
        [Range(1,50)]
        public float OutlineWidth = 1;
        [SerializeField, HideInInspector] private Shader outlineFullscreenShader;
        private Material outlineFullscreen;
        private RTHandle outlineBuffer;

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
        
        static class ShaderID
        {
            internal static readonly int OutlineColor = Shader.PropertyToID("_OutlineColor");
            internal static readonly int OutlineBuffer = Shader.PropertyToID("_OutlineBuffer");
            internal static readonly int Threshold = Shader.PropertyToID("_Threshold");
            internal static readonly int OutlineWidth = Shader.PropertyToID("_OutlineWidth");
            internal static readonly int SamplePrecision = Shader.PropertyToID("_SamplePrecision");
        }

        protected override void Execute(CustomPassContext ctx)
        {
            //设置需要渲染的物体
            CoreUtils.SetRenderTarget(ctx.cmd,outlineBuffer,ClearFlag.Color);
            //渲染 目标物体
            CustomPassUtils.DrawRenderers(ctx,OutlineLayer);

            //设置效果的参数
            ctx.propertyBlock.SetColor(ShaderID.OutlineColor, OutlineColor);
            ctx.propertyBlock.SetTexture(ShaderID.OutlineBuffer,outlineBuffer);
            ctx.propertyBlock.SetFloat(ShaderID.Threshold,Threshold);
            ctx.propertyBlock.SetFloat(ShaderID.OutlineWidth,OutlineWidth);
            ctx.propertyBlock.SetInt(ShaderID.SamplePrecision,SamplePrecision);

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
}