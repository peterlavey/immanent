shader_type canvas_item;

uniform float strength : hint_range(-1.0, 1.0) = -0.01;
uniform float curvature : hint_range(0.0, 10.0) = 2.0;
uniform float roundness : hint_range(0.0, 1.0) = 0.04;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.03;
uniform float scanline_count : hint_range(0.0, 2000.0) = 480.0;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.1;
uniform float scanline_speed : hint_range(0.0, 10.0) = 0.5;
uniform float neon_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float neon_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float neon_softness : hint_range(0.0, 1.0) = 0.1;
uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.002;
uniform float phosphor_opacity : hint_range(0.0, 1.0) = 0.05;
uniform float flicker_intensity : hint_range(0.0, 0.1) = 0.001;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Glitch logic: horizontal offsets
    if (glitch_intensity > 0.0) {
        float glitch_time = floor(TIME * 10.0);
        float glitch_chance = rand(vec2(glitch_time, 0.0));
        if (glitch_chance < glitch_intensity * 0.3) {
            float y_strip = floor(uv.y * 20.0);
            float offset = (rand(vec2(glitch_time, y_strip)) - 0.5) * glitch_intensity * 0.1;
            uv.x += offset;
        }
        
        // Vertical jump
        if (rand(vec2(glitch_time, 1.0)) < glitch_intensity * 0.1) {
            uv.y += (rand(vec2(glitch_time, 2.0)) - 0.5) * glitch_intensity * 0.05;
        }
    }

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
        // Flicker/Noise
        float flicker = (sin(TIME * 60.0) * 0.5 + 0.5) * flicker_intensity;
        float noise = (fract(sin(dot(uv * TIME, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 0.01;
        
        // Chromatic Aberration
        vec4 tex;
        if (chromatic_aberration > 0.0) {
            float r = texture(screen_texture, uv + vec2(chromatic_aberration, 0.0)).r;
            float g = texture(screen_texture, uv).g;
            float b = texture(screen_texture, uv - vec2(chromatic_aberration, 0.0)).b;
            tex = vec4(r, g, b, 1.0);
        } else {
            tex = texture(screen_texture, uv);
        }
        
        tex.rgb += noise + flicker;
        
        // Scanlines: Using a slightly softer wave with smoothstep or just a nicer sin
        float s = sin(uv.y * scanline_count + TIME * scanline_speed);
        // Soften the scanline intensity using a power function or just a mix
        float scanline = mix(1.0, 1.0 - scanline_opacity, (s + 1.0) * 0.5);
        tex.rgb *= scanline;
        
        // Phosphor mask (vertical strips)
        // Using a smoother triangle wave or a better sin to avoid aliasing
        float p = sin(uv.x * scanline_count * 1.5);
        float phosphor = mix(1.0, 1.0 - phosphor_opacity, (p + 1.0) * 0.5);
        tex.rgb *= phosphor;
        
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
