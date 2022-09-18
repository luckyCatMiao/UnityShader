using UnityEngine;

namespace PostEffect
{
    //bloom中使用的blur类型
    public enum BloomBlurMode
    {
        KawaseBlur=1,
        BoxBlur=2,
        GaussianBlur=3
    }
    

    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class BloomFull : MonoBehaviour
    {
        private Material mat;
        public int iteration; //迭代次数
        public int downSample = 2; //降采样比例
        public bool iterationDownSample; //是否每次迭代都进行降采样
        public float threshold; //光亮阈值
        public bool needUpSample = true; //是否需要升采样
        public BloomBlurMode blurMode = BloomBlurMode.GaussianBlur;
        public float blurDistance;
        private float _blurDistance;
        public float intensity;
        public float lerp;
        public Color bloomTint;
        
        private static readonly int Threshold = Shader.PropertyToID("_Threshold");
        private static readonly int BlurDistance = Shader.PropertyToID("_BlurDistance");
        private static readonly int BrightTex = Shader.PropertyToID("_BrightTex");
        private static readonly int Intensity = Shader.PropertyToID("_Intensity");
        private static readonly int Lerp = Shader.PropertyToID("_Lerp");
        private static readonly int BloomTint = Shader.PropertyToID("_BloomTint");



        private const int PassExtractBright = 0;
        private const int PassKawaseBlur = 1;
        private const int PassBoxBlur = 2;
        private const int PassGaussianBlurV = 3;
        private const int PassGaussianBlurH = 4;
        private const int PassCombine = 5;

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/BloomFull"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            //提取光亮部分
            var brightTex = ExtractBright(src, src.width, src.height);

            //模糊
            brightTex = BlurImage(src.width, src.height, brightTex);

            //混合
            Combine(brightTex, src, dest);
        }


        private void Combine(RenderTexture brightTex, RenderTexture src, RenderTexture dest)
        {
            mat.SetTexture(BrightTex, brightTex);
            mat.SetFloat(Intensity, intensity);
            mat.SetFloat(Lerp, lerp);

            //混合
            Graphics.Blit(src, dest, mat, PassCombine);
            RenderTexture.ReleaseTemporary(brightTex);
        }


        private RenderTexture BlurImage(int srcWidth, int srcHeight, RenderTexture brightTex)
        {
            _blurDistance = blurDistance;
            for (int i = 0; i < iteration; i++)
            {
                brightTex=BlurImageOnce(srcWidth,srcHeight,i,brightTex);
            }

            if (needUpSample)
            {
                _blurDistance = blurDistance;
                for (int i = iteration; i >= 1; i--)
                {
                    brightTex=BlurImageOnce(srcWidth,srcHeight,i,brightTex);
                }
            }

            return brightTex;
        }

        private RenderTexture BlurImageOnce(int srcWidth,int srcHeight,int index,RenderTexture brightTex)
        {
            mat.SetFloat(BlurDistance, _blurDistance);
                
            //kawaseBlur的模糊距离随循环变化
            if(blurMode==BloomBlurMode.KawaseBlur)
                _blurDistance *= 2;

            var tempTex = GetTexture(srcWidth, srcHeight, index);
            Graphics.Blit(brightTex, tempTex, mat, (int)blurMode);
            RenderTexture.ReleaseTemporary(brightTex);
            brightTex = tempTex;
                
            //gaussianBlur每个循环多一个pass
            if (blurMode == BloomBlurMode.GaussianBlur)
            {
                tempTex = GetTexture(srcWidth, srcHeight, index);
                Graphics.Blit(brightTex, tempTex, mat, (int)blurMode+1);
                RenderTexture.ReleaseTemporary(brightTex);
                brightTex = tempTex;
            }

            return brightTex;
        }

        private RenderTexture ExtractBright(RenderTexture src, int width, int height)
        {
            var brightTex = RenderTexture.GetTemporary(width, height);
            mat.SetFloat(Threshold, threshold);
            mat.SetColor(BloomTint, bloomTint);
            Graphics.Blit(src, brightTex, mat, PassExtractBright);

            return brightTex;
        }

        private RenderTexture GetTexture(int rawWidth, int rawHeight, int index)
        {
            var width = rawWidth;
            var height = rawHeight;
            if (iterationDownSample)
            {
                width = rawWidth >> index;
                height = rawHeight >> index;
            }
            else
            {
                width = rawWidth >> downSample;
                height = rawHeight >> downSample;
            }

            var tex = RenderTexture.GetTemporary(width, height);
            tex.filterMode = FilterMode.Bilinear;

            return tex;
        }
    }
}