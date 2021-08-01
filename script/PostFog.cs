using System;
using UnityEngine;

namespace Colorful
{
    public class PostFog : MonoBehaviour
    {
        private Camera _camera;
        public Shader shader;
        public Color fogColor;
        public float fogStart;
        public float fogEnd;

        private void Start()
        {
            _camera = GetComponent<Camera>();
            _camera.depthTextureMode |= DepthTextureMode.Depth;
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            Material material = new Material(shader);

            Matrix4x4 directions = Matrix4x4.identity;

            float fov = _camera.fieldOfView;
            float near = _camera.nearClipPlane;
            float aspect = _camera.aspect;
            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            var cameraTransform = _camera.transform;
            Vector3 toRight = cameraTransform.right * halfHeight * aspect;
            Vector3 toTop = cameraTransform.up * halfHeight;
            Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;
            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = cameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            directions.SetRow(0, bottomLeft);
            directions.SetRow(1, bottomRight);
            directions.SetRow(2, topRight);
            directions.SetRow(3, topLeft);

            material.SetMatrix("_Directions", directions);
            
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(src, dest, material);
        }
    }
}