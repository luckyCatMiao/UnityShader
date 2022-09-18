using UnityEngine;

namespace Mono.Effects
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class FogNoise:MonoBehaviour
    {
        private Material mat;
        private static readonly int RayTopLeft = Shader.PropertyToID("rayTopLeft");
        private static readonly int RayTopRight = Shader.PropertyToID("rayTopRight");
        private static readonly int RayBottomLeft = Shader.PropertyToID("rayBottomLeft");
        private static readonly int RayBottomRight = Shader.PropertyToID("rayBottomRight");

        public Color fogColor;
        public float fogStart;
        public float fogEnd;
        public Texture noiseTex;
        public float fogDensity;
        public Vector2 noiseSpeed;

        private static readonly int FogColor = Shader.PropertyToID("_FogColor");
        private static readonly int FogStart = Shader.PropertyToID("_FogStart");
        private static readonly int FogEnd = Shader.PropertyToID("_FogEnd");
        private static readonly int NoiseTex = Shader.PropertyToID("_NoiseTex");
        private static readonly int FogDensity = Shader.PropertyToID("_FogDensity");
        private static readonly int NoiseSpeed = Shader.PropertyToID("_NoiseSpeed");

        private void Start()
        {
            this.mat = new Material(Shader.Find("LX/FogNoise"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            var camera=Camera.main;
            camera.depthTextureMode = DepthTextureMode.Depth;
			
            var pos = camera.transform.position;
            var halfHeight=camera.nearClipPlane*Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
            var halfWidth = halfHeight * camera.aspect;

            var nearClipPlane = camera.nearClipPlane;
            var topRightPoint = pos + new Vector3(halfWidth,halfHeight,nearClipPlane);
            var topLeftPoint = pos + new Vector3(-halfWidth,halfHeight,nearClipPlane);
            var bottomRightPoint = pos + new Vector3(halfWidth,-halfHeight,nearClipPlane);
            var bottomLeftPoint = pos + new Vector3(-halfWidth,-halfHeight,nearClipPlane);

            var topRightRay = topRightPoint - pos;
            var topLeftRay = topLeftPoint - pos;
            var bottomRightRay =bottomRightPoint - pos;
            var bottomLeftRay = bottomLeftPoint - pos;
			
			
            mat.SetVector(RayTopLeft,topLeftRay);
            mat.SetVector(RayTopRight,topRightRay);
            mat.SetVector(RayBottomLeft,bottomLeftRay);
            mat.SetVector(RayBottomRight,bottomRightRay);
            
            mat.SetColor(FogColor,fogColor);
            mat.SetFloat(FogStart,fogStart);
            mat.SetFloat(FogEnd,fogEnd);
            mat.SetTexture(NoiseTex,noiseTex);
            mat.SetFloat(FogDensity,fogDensity);
            mat.SetVector(NoiseSpeed,noiseSpeed);

            Graphics.Blit(src,dest,mat);
        }
    }
}