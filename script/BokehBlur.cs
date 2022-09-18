using UnityEngine;

namespace Blur
{
    public class BokehBlur:MonoBehaviour
    {
        private Material mat;
        public float rotateDistance=1;
        public int sampleCount=20;
        public float radius=1;
        private static readonly int RotateDistance = Shader.PropertyToID("_RotateDistance");
        private static readonly int SampleCount = Shader.PropertyToID("_SampleCount");
        private static readonly int Radius = Shader.PropertyToID("_Radius");


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/BokehBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(RotateDistance,rotateDistance);
            mat.SetInt(SampleCount,sampleCount);
            mat.SetFloat(Radius,radius);
            
            Graphics.Blit(src,dest,mat);
        }
    }
}