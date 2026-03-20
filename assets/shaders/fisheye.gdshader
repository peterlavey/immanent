shader_type canvas_item;

uniform float strength : hint_range(-1.0, 1.0) = -0.01;
uniform float curvature : hint_range(0.0, 10.0) = 2.0;
uniform float roundness : hint_range(0.0, 1.0) = 0.04;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.03;
uniform float scanline_count : hint_range(0.0, 2000.0) = 600.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.03;
uniform float scanline_speed : hint_range(0.0, 10.0) = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5);
    vec2 dir = uv - center;
    float dist = length(dir);
    
    // Improved fisheye distortion logic
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
        
        // Add a slight vignette/shadow at the edges for more "TV" feel
        float edge_dist = max(q.x, q.y);
        float vignette = smoothstep(1.0, 1.0 - vignette_softness, corner_mask);
        
        COLOR = tex * vignette;
        COLOR.a = 1.0;
    }
}
