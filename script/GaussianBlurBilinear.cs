using UnityEngine;

public class GaussianBlurBilinear : MonoBehaviour
{
    public Shader shader;
    public int DownSampleNum = 2;
    public int BlurIterations = 3;

    private RenderTexture m_rt;
    private Material m_mat;

    public int targetCount = 3;
    private int currentCount = 0;
    private RenderTexture preBlurImg;

    Material material
    {
        get
        {
            if (m_mat == null)
            {
                m_mat = new Material(shader);
            }
            return m_mat;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        currentCount++;
        if (currentCount > targetCount)
        {
            if (preBlurImg) RenderTexture.ReleaseTemporary(preBlurImg);

            //降采样
            int rtW = src.width >> DownSampleNum;
            int rtH = src.height >> DownSampleNum;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0, RenderTextureFormat.RGB111110Float);
            buffer0.filterMode = FilterMode.Bilinear;

            //pass2 降采样
            Graphics.Blit(src, buffer0, material);

            for (int i = 0; i < BlurIterations; i++)
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
            preBlurImg = buffer0;

            currentCount = 0;
        }
        else
        {
            Graphics.Blit(preBlurImg, dest);
        }
    }
}