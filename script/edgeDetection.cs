using UnityEngine;


[RequireComponent(typeof(Camera))]
public class edgeDetection : MonoBehaviour
{
    public Shader shader;
    public Color edgeColor;
    public float threshold;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        material.SetColor("edgeColor", edgeColor);
        material.SetFloat("threshold", threshold);

        Graphics.Blit(src, dest, material);
    }
}