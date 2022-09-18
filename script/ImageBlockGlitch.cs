using UnityEngine;

namespace Glitch
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class ImageBlockGlitch:MonoBehaviour
    {
        private Material mat;
        public int rowCount=10;
        public int columnCount=10;
        public int rowCount2=10;
        public int columnCount2=10;
        public float speed=100;
        public float intensity=1;
        public int pow=1;
        private static readonly int RowCount = Shader.PropertyToID("_RowCount");
        private static readonly int ColumnCount = Shader.PropertyToID("_ColumnCount");
        private static readonly int RowCount2 = Shader.PropertyToID("_RowCount2");
        private static readonly int ColumnCount2 = Shader.PropertyToID("_ColumnCount2");
        private static readonly int Speed = Shader.PropertyToID("_Speed");
        private static readonly int Intensity = Shader.PropertyToID("_Intensity");
        private static readonly int Pow = Shader.PropertyToID("_Pow");


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/ImageBlockGlitch"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetInt(RowCount,rowCount);
            mat.SetInt(ColumnCount,columnCount);
            mat.SetInt(RowCount2,rowCount2);
            mat.SetInt(ColumnCount2,columnCount2);
            mat.SetFloat(Speed,speed);
            mat.SetFloat(Intensity,intensity);
            mat.SetInt(Pow,pow);
            Graphics.Blit(src, dest, mat);
        }
    }
}