using UnityEngine;

public enum GaussianKernel
{
    Kernel5,//5*5卷积核
    Kernel9,//9*9卷积核
}

public class GaussianBlur2:MonoBehaviour
{
    public float blurSpreadSize=1;
    public int downSampleNum = 2;
    public int blurIterations = 3;

    private RenderTexture m_rt;
    
    private int currentCount = 0;
    private static readonly int BlurSpreadSize = Shader.PropertyToID("_BlurSpreadSize");
    
    public GaussianKernel kernel;
    private GaussianKernel lastKernel;
    private Material material;

    private void OnEnable()
    {
        material = new Material(Shader.Find("LX/GaussianBlur"));
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetFloat(BlurSpreadSize,blurSpreadSize);
            
        if (kernel != lastKernel)
        {
            material.DisableKeyword(lastKernel.ToString());
            material.EnableKeyword(kernel.ToString());
            lastKernel = kernel;
        }
                
        //降采样
        int rtW = src.width >> downSampleNum;
        int rtH = src.height >> downSampleNum;

        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.RGB111110Float);
        buffer0.filterMode = FilterMode.Bilinear;

        //pass2 降采样
        Graphics.Blit(src, buffer0);

        for (int i = 0; i < blurIterations; i++)
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.RGB111110Float);

            // pass0 竖直方向的模糊
            Graphics.Blit(buffer0, buffer1, material, 0);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
            buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.RGB111110Float);

            // pass1 水平方向的模糊
            Graphics.Blit(buffer0, buffer1, material, 1);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }
        
        Graphics.Blit(buffer0, dest);
    }
}