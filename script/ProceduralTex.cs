using System;
using UnityEngine;

namespace Colorful
{
    public class ProceduralTex : MonoBehaviour
    {
        public int texHeight = 200;
        public int texWidth = 200;

        private void Start()
        {
            this.GetComponent<MeshRenderer>().material.mainTexture = generateTex();
        }


        public Texture2D generateTex()
        {
            Texture2D texture2D = new Texture2D(texHeight, texWidth);
            float radius = texWidth / 6f;
            for (int y = 0; y < texHeight; y++)
            {
                for (int x = 0; x < texWidth; x++)
                {
                    float dist = float.MaxValue;
                    for (int j = 0; j < 3; j++)
                    {
                        for (int k = 0; k < 3; k++)
                        {
                            Vector2 center = new Vector2( radius+ k * radius*2,
                                radius + j * radius *2);
                            dist = Math.Min(dist, Vector2.Distance(new Vector2(x, y), center));
                        }
                    }

                    dist -= radius;
                    float lerp = Mathf.Lerp(0, 1, dist);
                    texture2D.SetPixel(x, y, Color.white * lerp);
                }
            }

            texture2D.Apply();

            return texture2D;
        }
    }
}