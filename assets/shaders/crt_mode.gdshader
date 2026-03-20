shader_type canvas_item;

uniform float strength : hint_range(-1.0, 1.0) = -0.01;
uniform float curvature : hint_range(0.0, 10.0) = 2.0;
uniform float roundness : hint_range(0.0, 1.0) = 0.04;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.03;
uniform float scanline_count : hint_range(0.0, 2000.0) = 600.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.03;
uniform float scanline_speed : hint_range(0.0, 10.0) = 0.5;
uniform float neon_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float neon_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float neon_softness : hint_range(0.0, 1.0) = 0.1;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);
    vec2 dir = uv - center;
    float dist = length(dir);
    
    // CRT Mode distortion logic
    if (strength != 0.0) {
        float distortion = 1.0 + strength * pow(dist, curvature);
        uv = center + dir * distortion;
    }
    
    // Check if uv is within bounds with rounded corners
    // CRT-style rounded edges logic
    vec2 q = abs(uv - center) * 2.0;
    // The curve for rounded corners: (x/a)^n + (y/b)^n = 1
    // We can use a power function to define the corner mask
    float corner_mask = pow(q.x, 1.0 / roundness) + pow(q.y, 1.0 / roundness);
    
    if (corner_mask > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        vec4 tex = texture(screen_texture, uv);
        
        // Scanlines
        float s = sin(uv.y * scanline_count + TIME * scanline_speed);
        tex.rgb -= s * scanline_opacity;
        
        // Neon Glow effect (simplified 5-sample bloom/glow)
        if (neon_intensity > 0.0) {
            vec2 texel_size = SCREEN_PIXEL_SIZE * 2.0; // Slightly larger for better "spread"
            vec3 glow = texture(screen_texture, uv + vec2(texel_size.x, 0.0)).rgb;
            glow += texture(screen_texture, uv + vec2(-texel_size.x, 0.0)).rgb;
            glow += texture(screen_texture, uv + vec2(0.0, texel_size.y)).rgb;
            glow += texture(screen_texture, uv + vec2(0.0, -texel_size.y)).rgb;
            glow *= 0.25;
            
            // Luminance thresholding
            float luma = dot(glow, vec3(0.299, 0.587, 0.114));
            float threshold_mask = smoothstep(neon_threshold, neon_threshold + neon_softness, luma);
            
            // Add the glow to the original texture
            tex.rgb += glow * threshold_mask * neon_intensity;
            
            // Slight saturation boost for neon feel
            float max_c = max(max(tex.r, tex.g), tex.b);
            tex.rgb = mix(vec3(max_c), tex.rgb, 1.2);
        }
        
        // Add a slight vignette/shadow at the edges for more "TV" feel
        float edge_dist = max(q.x, q.y);
        float vignette = smoothstep(1.0, 1.0 - vignette_softness, corner_mask);
        
        COLOR = tex * vignette;
        COLOR.a = 1.0;
    }
}
