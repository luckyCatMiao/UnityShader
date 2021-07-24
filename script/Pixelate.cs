namespace Colorful
{
    using UnityEngine;

    [ExecuteInEditMode]
    public class Pixelate : MonoBehaviour
    {
        public Shader shader;
        public int    PixelSize = 8;
        public bool   AddStrip;

        protected void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material material = new Material(shader);
            material.SetInt("_PixelSize", PixelSize);
            material.SetInt("_AddStrip", AddStrip ? 1 : 0);
            Graphics.Blit(source, destination, material);
        }
    }
}