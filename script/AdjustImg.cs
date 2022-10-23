using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class AdjustImg : MonoBehaviour
{
    [Range(0, 3)] public float brightness;
    [Range(0, 3)] public float saturation;
    [Range(0, 3)] public float contrast;
    public Shader shader;


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        material.SetFloat("brightness", brightness);
        material.SetFloat("saturation", saturation);
        material.SetFloat("contrast", contrast);
        Graphics.Blit(src, dest, material);
    }
}