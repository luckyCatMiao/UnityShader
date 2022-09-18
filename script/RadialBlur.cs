using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class RadialBlur:MonoBehaviour
    {
        private Material mat;
        private static readonly int Iteration = Shader.PropertyToID("_Iteration");
        public int iteration=10;
        [Range(0,5)]
        public float radius=1;
        private static readonly int Radius = Shader.PropertyToID("_Radius");
        public Vector4 center=Vector4.one;
        private static readonly int Center = Shader.PropertyToID("_Center");

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/RadialBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Iteration,iteration);
            mat.SetFloat(Radius,radius);
            mat.SetVector(Center,center);

            Graphics.Blit(src,dest,mat);
        }
    }
}