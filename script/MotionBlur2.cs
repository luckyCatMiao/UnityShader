using System;
using UnityEngine;

public class MotionBlur2 : MonoBehaviour
{
    public Shader shader;
    private Matrix4x4 previousViewProjectionMatrix;
    private Camera _camera;


    private void OnEnable()
    {
        _camera = this.GetComponent<Camera>();
        _camera.depthTextureMode |= DepthTextureMode.Depth;
        previousViewProjectionMatrix = _camera.projectionMatrix * _camera.worldToCameraMatrix;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Material material = new Material(shader);
        material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
        Matrix4x4 currentViewProjectionMatrix = (_camera.projectionMatrix * _camera.worldToCameraMatrix);
        Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
        material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
        previousViewProjectionMatrix = currentViewProjectionMatrix;


        Graphics.Blit(src, dest, material);
    }
}