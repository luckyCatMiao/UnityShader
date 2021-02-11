using UnityEngine;

public class Bloom : MonoBehaviour
{
    public Shader shader;
    public int downSample = 2;
    public int iteration = 5;
    public float threshold = 0;
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        int width = src.width/downSample;
        int height = src.height/downSample ;

        var brightArea = RenderTexture.GetTemporary(width, height, 0);
        brightArea.filterMode = FilterMode.Bilinear;
        Graphics.Blit(src, brightArea, material, 0);

        for (int i = 0; i < iteration; i++)
        {
            var temp = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(brightArea, temp, material, 2);
            RenderTexture.ReleaseTemporary(brightArea);
            brightArea = temp;
            
            temp = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(brightArea, temp, material, 3);
            RenderTexture.ReleaseTemporary(brightArea);
            brightArea = temp;
        }

        material.SetTexture("_Bloom", brightArea);
        material.SetFloat("threshold",threshold);
        Graphics.Blit(src, dest, material, 1);
    }
}