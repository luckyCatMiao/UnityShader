using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class SphereBlur:MonoBehaviour
    {
        private Material mat;
        public float radius=1;
        private static readonly int Radius = Shader.PropertyToID("_Radius");

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/SphereBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Radius,radius);
            Graphics.Blit(src,dest,mat);
        }
    }
}