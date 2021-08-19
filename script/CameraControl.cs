using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        this.GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
