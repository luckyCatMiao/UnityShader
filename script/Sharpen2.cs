using UnityEngine;

namespace PostEffect
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class Sharpen2 : MonoBehaviour
    {
        private static readonly int Intensity = Shader.PropertyToID("_Intensity");
        public float intensity;

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            Material material = new Material(Shader.Find("LX/Sharpen2"));
            material.SetFloat(Intensity, intensity);
            Graphics.Blit(src, dest, material);
        }
    }
}