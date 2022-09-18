using System;
using UnityEngine;

namespace PostEffect
{
    [ExecuteInEditMode]
    [ImageEffectAllowedInSceneView]
    public class SSAA : MonoBehaviour
    {
        private Material material;
        private static readonly int SobelSize = Shader.PropertyToID("_SobelSize");
        private static readonly int Size = Shader.PropertyToID("_Size");
        public float sobelSize;
        public float size;

        private void Start()
        {
            material = new Material(Shader.Find("LX/SSAA"));
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
           
            material.SetFloat(SobelSize, sobelSize);
            material.SetFloat(Size, size);
            Graphics.Blit(src, dest, material);
        }
    }
}