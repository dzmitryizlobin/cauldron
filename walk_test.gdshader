shader_type canvas_item;

uniform vec2 center_uv = vec2(0.5, 0.5); // центр котла в SCREEN UV (0..1)
uniform float radius = 0.25;             // радиус в UV (0..~1)
uniform float soft = 0.06;               // мягкость границы (UV)
uniform float noise_scale = 8.0;         // размер шума
uniform float noise_strength = 0.03;     // "рваность" края (UV)
uniform vec4 outside_color : source_color = vec4(0.02, 0.03, 0.06, 0.92); // тёмный фог
uniform vec4 inside_tint   : source_color = vec4(0.12, 0.22, 0.10, 0.18); // зелёный оттенок внутри

float hash(vec2 p){
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)*u.y*(1.0 - u.x) + (d - b)*u.x*u.y;
}

void fragment(){
    vec2 uv = SCREEN_UV;

    // шум для живой кромки
    float n = noise(uv * noise_scale + vec2(TIME * 0.15, TIME * 0.11));
    float d = distance(uv, center_uv);
    d += (n - 0.5) * noise_strength;

    // edge: 0 внутри, 1 снаружи (мягкая граница)
    float edge = smoothstep(radius - soft, radius + soft, d);

    // цвет: внутри слегка зелёный, снаружи тёмный
    vec4 col = mix(inside_tint, outside_color, edge);

    // чуть “дышащий” туман снаружи
    float fog_wobble = 0.9 + 0.1 * n;
    col.a *= mix(0.6, fog_wobble, edge);

    COLOR = col;
}