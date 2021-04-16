namespace Colorful
{
    using UnityEngine;
    
    [ExecuteInEditMode]
    public class ComicBook : MonoBehaviour
    {
        [Tooltip("Strip orientation in radians.")]
        public float StripAngle = 0.6f;

        [Min(0f), Tooltip("Amount of strips to draw.")]
        public float StripDensity = 180f;

        [Range(0f, 1f), Tooltip("Thickness of the inner strip fill.")]
        public float StripThickness = 0.5f;

        public Vector2 StripLimits = new Vector2(0.25f, 0.4f);

        [ColorUsage(false)] public Color StripInnerColor = new Color(0.3f, 0.3f, 0.3f);

        [ColorUsage(false)] public Color StripOuterColor = new Color(0.8f, 0.8f, 0.8f);

        [ColorUsage(false)] public Color FillColor = new Color(0.1f, 0.1f, 0.1f);

        [ColorUsage(false)] public Color BackgroundColor = Color.white;

        [Range(0f, 1f), Tooltip("Blending factor.")]
        public float Amount = 1f;

        public Shader shader;

        protected void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            Material material = new Material(shader);
            shader.hideFlags = HideFlags.HideAndDontSave;
            material.SetFloat("_StripCosAngle", Mathf.Cos(StripAngle / 180 * Mathf.PI));
            material.SetFloat("_StripSinAngle", Mathf.Sin(StripAngle / 180 * Mathf.PI));
            material.SetFloat("_StripLimitsMin", StripLimits.x);
            material.SetFloat("_StripLimitsMax", StripLimits.y);
            material.SetFloat("_StripDensity", StripDensity * 10f);
            material.SetFloat("_StripThickness", StripThickness);
            material.SetFloat("_Amount", Amount);
            material.SetColor("_StripInnerColor", StripInnerColor);
            material.SetColor("_StripOuterColor", StripOuterColor);

            material.SetColor("_FillColor", FillColor);
            material.SetColor("_BackgroundColor", BackgroundColor);


            Graphics.Blit(source, destination, material, 0);
        }
    }
}