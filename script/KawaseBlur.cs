using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class KawaseBlur:MonoBehaviour
    {
        private Material mat;
        public int interation=1;
        public int downSample=1;
        public int blurDistance=1;
        private static readonly int BlurDistance = Shader.PropertyToID("_BlurDistance");

        private void Awake()
        {
            this.mat = new Material(Shader.Find("LX/KawaseBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            var width = src.width >> downSample;
            var height = src.height >> downSample;
            var tempBuffer = RenderTexture.GetTemporary(width, height);
            tempBuffer.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src,tempBuffer);

            for (int i = 0; i < interation; i++)
            {
                var tempBuffer2 = RenderTexture.GetTemporary(width, height);
                tempBuffer2.filterMode = FilterMode.Bilinear;
                mat.SetFloat(BlurDistance,blurDistance*(i+1));
                Graphics.Blit(tempBuffer,tempBuffer2,mat);
                RenderTexture.ReleaseTemporary(tempBuffer);
                tempBuffer = tempBuffer2;
            }
            
            Graphics.Blit(tempBuffer,dest);
            RenderTexture.ReleaseTemporary(tempBuffer);
        }
    }
}