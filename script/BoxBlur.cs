using UnityEngine;

public class BoxBlur : MonoBehaviour
{
    public Shader shader;
    public int sampleCount=3;
    public float blurSize=1;
    public int downSample=2;
    private Material material;
    private static readonly int SampleCount = Shader.PropertyToID("_SampleCount");
    private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");
    private static readonly int StartIndex = Shader.PropertyToID("_StartIndex");
    private static readonly int EndIndex = Shader.PropertyToID("_EndIndex");
    private static readonly int SamplePercent = Shader.PropertyToID("_SamplePercent");

    private void Start()
    {
        material = new Material(shader);
        material.hideFlags=HideFlags.HideAndDontSave;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //降采样
        int renderWidth = src.width>>downSample;
        int renderHeight = src.height>>downSample;
        var tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0);
        tempBuffer.filterMode = FilterMode.Bilinear;
        Graphics.Blit(src,tempBuffer);
        
        material.SetFloat(SampleCount,sampleCount);
        material.SetFloat(BlurSize,blurSize);
        
        //在单帧中不会变的参数从shader片元着色器提取出来在应用阶段设置
        int startIndex = -(sampleCount / 2);
        int endIndex = startIndex + sampleCount - 1;
        float samplePercent = sampleCount * sampleCount;
        material.SetFloat(StartIndex,startIndex);
        material.SetFloat(EndIndex,endIndex);
        material.SetFloat(SamplePercent,samplePercent);
        
        Graphics.Blit(tempBuffer,dest,material);
        RenderTexture.ReleaseTemporary(tempBuffer);
    }
}