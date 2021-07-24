using UnityEngine;

[ExecuteInEditMode]
public class SimpleNoise : MonoBehaviour
{
    public Shader shader;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        Graphics.Blit(src, dest, material);
    }
}