shader_type spatial;
render_mode depth_draw_alpha_prepass, cull_disabled;

uniform float speed : hint_range(0.0, 20.0) = 2.0;
uniform float scale : hint_range(0.0, 20.0) = 2.0;
uniform float transparency : hint_range(0.0, 3.0) = 0.6;
uniform vec4 primary_color : hint_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 secondary_color : hint_color = vec4(0.2, 0.6, 0.8, 1.0);
uniform int colors : hint_range(2, 128) = 128;
uniform sampler2D SlowNoise;
uniform sampler2D FastNoise;

vec3 posterize(vec3 color) {
	if (colors == 128) return color;
	
	color = floor(color * float(colors)) / float(colors);
	return color;
}
void vertex() {
	vec2 noise_uv = UV;
	noise_uv.x += TIME * (speed * 2.0 + 0.3) * 0.05;
	vec4 n = texture(SlowNoise, noise_uv) * scale;
	VERTEX.y += n.r - scale * 0.5;
}

void fragment() {
	vec2 noise_uv = UV;
	vec4 n;
	
	noise_uv.x += TIME * (speed * 0.2 + 0.3) * 0.01;
	n = texture(SlowNoise, noise_uv);
	ALBEDO.rgb = n.rrr * primary_color.rgb;
	
	//ALPHA = smoothstep(0.0, transparency, n.r);

	noise_uv.x += TIME * (speed * 0.5 + 0.3) * 0.03;
	n = texture(FastNoise, noise_uv);
	ALBEDO.rgb += n.r * secondary_color.rgb;
	
	ALBEDO = posterize(ALBEDO);
}
