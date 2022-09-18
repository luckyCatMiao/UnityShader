using UnityEngine;

namespace Blur
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class TiltShiftBlur:MonoBehaviour
    {
        private Material mat;
        public float rotateDistance=1;
        public int sampleCount=20;
        public float radius=1;
        public float offset=0;
        public int pow=3;
        private static readonly int RotateDistance = Shader.PropertyToID("_RotateDistance");
        private static readonly int SampleCount = Shader.PropertyToID("_SampleCount");
        private static readonly int Radius = Shader.PropertyToID("_Radius");
        private static readonly int Pow = Shader.PropertyToID("_Pow");
        private static readonly int Offset = Shader.PropertyToID("_Offset");


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/TiltShiftBlur"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Offset,offset);
            mat.SetFloat(RotateDistance,rotateDistance);
            mat.SetInt(SampleCount,sampleCount);
            mat.SetFloat(Radius,radius);
            mat.SetFloat(Pow,pow);
            
            Graphics.Blit(src,dest,mat);
        }
    }
}