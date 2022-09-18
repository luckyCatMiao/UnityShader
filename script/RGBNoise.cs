using UnityEngine;

namespace Glitch
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class RGBNoise : MonoBehaviour
    {
        private Material mat;
        public float noiseIntensity;
        public float noiseLerp;
        private static readonly int NoiseIntensity = Shader.PropertyToID("_NoiseIntensity");
        private static readonly int NoiseLerp = Shader.PropertyToID("_NoiseLerp");


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/RGBNoise"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(NoiseIntensity,noiseIntensity);
            mat.SetFloat(NoiseLerp,noiseLerp);
            Graphics.Blit(src, dest, mat);
        }
    }
}