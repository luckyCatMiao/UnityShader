using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class EmptyBoxBlur:MonoBehaviour
    {
        private Material mat;
        public float size=1;
        private static readonly int Size = Shader.PropertyToID("_Size");

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/EmptyBoxBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Size,size);
            Graphics.Blit(src,dest,mat);
        }
    }
}