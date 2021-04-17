namespace Colorful
{
    using UnityEngine;


    [ExecuteInEditMode]
    public class OilPaint : MonoBehaviour
    {
        public int Radius = 3;

        public Shader shader;

        protected void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material material = new Material(shader);
            material.SetInt("_Radius", Radius);
            material.SetVector("_PSize", new Vector2(1f / (float) source.width, 1f / (float) source.height));

            Graphics.Blit(source, destination, material);
        }
    }
}