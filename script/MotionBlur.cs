using UnityEngine;

public class MotionBlur : MonoBehaviour
{
    public Shader shader;

    private RenderTexture motionBlurTex;
    
    public float blurAmount;

    private void OnDisable()
    {
        DestroyImmediate(motionBlurTex);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        material.SetFloat("blurAmount",blurAmount);
        if (motionBlurTex == null)
        {
            motionBlurTex = new RenderTexture(src.width, src.height, 0);
            motionBlurTex.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(src, motionBlurTex);
        }
        
        motionBlurTex.MarkRestoreExpected();

        Graphics.Blit(src, motionBlurTex, material);
        Graphics.Blit(motionBlurTex, dest);
    }
}