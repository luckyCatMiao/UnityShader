using UnityEngine;

namespace Glitch
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class ScanLineJitterGlitch : MonoBehaviour
    {
        private Material mat;
        public float intensity = 1;
        public float threshold;
        private static readonly int Intensity = Shader.PropertyToID("_Intensity");
        private static readonly int Threshold = Shader.PropertyToID("_Threshold");

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/ScanLineJitterGlitch"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Intensity, intensity);
            mat.SetFloat(Threshold,threshold);
            Graphics.Blit(src, dest, mat);
        }
    }
}