using UnityEngine;

public class GaussianBlur : MonoBehaviour
{
    public Shader shader;
    public int iterationTime;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        var buffer=RenderTexture.GetTemporary(src.width, src.height);
        Graphics.Blit(src, buffer);
        for (int i = 0; i < iterationTime; i++)
        {
            var buffer2=RenderTexture.GetTemporary(src.width, src.height);
            Graphics.Blit(buffer, buffer2, material,0);
            RenderTexture.ReleaseTemporary(buffer);
            buffer = buffer2;
           
            
            buffer2=RenderTexture.GetTemporary(src.width, src.height);
            Graphics.Blit(buffer, buffer2, material,1);
            RenderTexture.ReleaseTemporary(buffer);
            buffer = buffer2;
        }
      
        Graphics.Blit(buffer, dest);
        RenderTexture.ReleaseTemporary(buffer);
    }
}
