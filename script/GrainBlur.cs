using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class GrainBlur : MonoBehaviour
    {
        private Material mat;
        public float radius = 1;
        public int iteration = 1;
        private static readonly int Radius = Shader.PropertyToID("_Radius");
        private static readonly int Iteration = Shader.PropertyToID("_Iteration");

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/GrainBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Radius, radius);
            mat.SetFloat(Iteration, iteration);
            Graphics.Blit(src, dest, mat);
        }
    }
}