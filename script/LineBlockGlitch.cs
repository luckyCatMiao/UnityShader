using UnityEngine;

namespace Glitch
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class LineBlockGlitch : MonoBehaviour
    {
        private Material mat;
        public int rowCount = 4;
        public int rowCount2 = 10;
        public int rowCount3 = 17;
        public float speed = 100;
        public int pow = 1;
        public float intensity=1;
        private static readonly int RowCount = Shader.PropertyToID("_RowCount");
        private static readonly int RowCount2 = Shader.PropertyToID("_RowCount2");
        private static readonly int RowCount3 = Shader.PropertyToID("_RowCount3");
        private static readonly int Speed = Shader.PropertyToID("_Speed");
        private static readonly int Pow = Shader.PropertyToID("_Pow");
        private static readonly int Intensity = Shader.PropertyToID("_Intensity");


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/LineBlockGlitch"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetInt(RowCount, rowCount);
            mat.SetInt(RowCount2, rowCount2);
            mat.SetInt(RowCount3, rowCount3);
            mat.SetInt(Pow, pow);
            mat.SetFloat(Speed, speed);
            mat.SetFloat(Intensity,intensity);
            Graphics.Blit(src, dest, mat);
        }
    }
}