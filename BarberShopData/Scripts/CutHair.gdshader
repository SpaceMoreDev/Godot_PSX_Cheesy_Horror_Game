shader_type spatial;

uniform vec3 brush_position;
uniform float brush_radius = 0.2;

uniform float noise_strength = 0.05;
uniform float noise_scale = 20.0;

uniform float edge_fade = 0.1;

float hash(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x)
		+ (c - a) * u.y * (1.0 - u.x)
		+ (d - b) * u.x * u.y;
}

void vertex()
{
	// WORLD POSITION
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// BRUSH MASK
	float d = distance(world_pos, brush_position);

	float brush = smoothstep(
		brush_radius,
		brush_radius * 0.5,
		d
	);

	// EDGE MASK USING UV
	float edge_mask_x =
		smoothstep(0.0, edge_fade, UV.x) *
		(1.0 - smoothstep(1.0 - edge_fade, 1.0, UV.x));

	float edge_mask_y =
		smoothstep(0.0, edge_fade, UV.y) *
		(1.0 - smoothstep(1.0 - edge_fade, 1.0, UV.y));

	float edge_mask = edge_mask_x * edge_mask_y;

	// NOISE
	float n = noise(UV * noise_scale);

	float messy = (n - 0.5) * noise_strength;

	// REMOVE NOISE UNDER BRUSH
	float final_noise = mix(
		messy,
		0.0,
		brush
	);

	VERTEX += NORMAL * final_noise * edge_mask;
}