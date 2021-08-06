using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace ZPostHDRP.CustomPass
{
    class OutlineFullScreen : UnityEngine.Rendering.HighDefinition.CustomPass
    {
        public LayerMask OutlineLayer = 0;
        [ColorUsage(false, true)]
        public Color OutlineColor = Color.red;
        public float Threshold = 0.1f;
        [SerializeField, HideInInspector] private Shader outlineFullscreenShader;
        private Material outlineFullscreen;

        private RTHandle outlineBuffer;

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

        private class ShaderID
        {
            public static readonly int OutlineColor1 = Shader.PropertyToID("_OutlineColor");
            public static readonly int OutlineBuffer = Shader.PropertyToID("_OutlineBuffer");
            public static readonly int Threshold1 = Shader.PropertyToID("_Threshold");
        }

        protected override void Execute(CustomPassContext ctx)
        {
            //设置需要渲染的物体
            CoreUtils.SetRenderTarget(ctx.cmd,outlineBuffer,ClearFlag.Color);
            //渲染 目标物体
            CustomPassUtils.DrawRenderers(ctx,OutlineLayer);

            //设置效果的参数
            ctx.propertyBlock.SetColor(ShaderID.OutlineColor1, OutlineColor);
            ctx.propertyBlock.SetTexture(ShaderID.OutlineBuffer,outlineBuffer);
            ctx.propertyBlock.SetFloat(ShaderID.Threshold1,Threshold);

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