using UnityEngine;

namespace PostEffect
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class Sharpen : MonoBehaviour
    {
        private static readonly int Intensity = Shader.PropertyToID("_Intensity");
        public float intensity;

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            Material material = new Material(Shader.Find("LX/Sharpen"));
            material.SetFloat(Intensity, intensity);
            Graphics.Blit(src, dest, material);
        }
    }
}