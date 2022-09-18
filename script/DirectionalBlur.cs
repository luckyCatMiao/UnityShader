using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class DirectionalBlur:MonoBehaviour
    {
        private Material mat;
        private static readonly int Direction = Shader.PropertyToID("_Direction");
        private static readonly int Iteration = Shader.PropertyToID("_Iteration");
        public Vector4 direction;
        public int iteration=1;


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/DirectionalBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetVector(Direction,direction);
            mat.SetInt(Iteration,iteration);

            Graphics.Blit(src,dest,mat);
        }
    }
}