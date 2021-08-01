using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace Colorful
{
    public class PostEdgeDetection : MonoBehaviour
    {
        public Color edgeColor = Color.black;
        public Color backgroundColor = Color.white;
        public float thresholdNormal = 0.5f;
        public float thresholdDepth = 0.5f;
        public Shader shader;

        private void Start()
        {
            GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            Material material = new Material(shader);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_ThresholdNormal", thresholdNormal);
            material.SetFloat("_ThresholdDepth", thresholdDepth);
            Graphics.Blit(src, dest, material);
        }
    }
}