using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class KernelTest : MonoBehaviour
    {
        private Material mat;
        public int iteration = 1;
        private static readonly int Lerp = Shader.PropertyToID("_Lerp");
        [Range(0, 1)] public float lerp;
        private static readonly int Tex = Shader.PropertyToID("_Tex");

        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/KernelTest"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            var tempBuffer1 = RenderTexture.GetTemporary(src.width, src.height, src.depth);
            var tempBuffer2 = RenderTexture.GetTemporary(src.width, src.height, src.depth);
            Graphics.Blit(src, tempBuffer1);
            for (int i = 0; i < iteration; i++)
            {
                Graphics.Blit(tempBuffer1, tempBuffer2, mat, 0);
                var temp = tempBuffer1;
                tempBuffer1 = tempBuffer2;
                tempBuffer2 = temp;
            }

            mat.SetTexture(Tex, tempBuffer1);
            mat.SetFloat(Lerp, lerp);
            Graphics.Blit(src, dest, mat, 1);

            RenderTexture.ReleaseTemporary(tempBuffer2);
            RenderTexture.ReleaseTemporary(tempBuffer1);
        }
    }
}