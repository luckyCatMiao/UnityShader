using UnityEngine;

namespace Glitch
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class RGBSplitGlitch:MonoBehaviour
    {
        private Material mat;

        public float distance;
        public bool useTime;
        public float speed;
        
        private static readonly int UseTime = Shader.PropertyToID("_UseTime");
        private static readonly int Speed = Shader.PropertyToID("_Speed");
        private static readonly int Distance = Shader.PropertyToID("_Distance");


        private void OnEnable()
        {
            mat = new Material(Shader.Find("LX/RGBSplitGlitch"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            mat.SetFloat(Distance,distance);
            mat.SetFloat(UseTime,useTime?1:0);
            mat.SetFloat(Speed,speed);
            Graphics.Blit(src, dest, mat);
        }
    }
}