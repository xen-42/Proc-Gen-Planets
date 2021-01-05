shader_type spatial;

uniform float max_height;
uniform float min_height;
uniform sampler2D gradient;

varying vec3 sampled_colour;

void vertex() {
	float x = VERTEX.x;
	float y = VERTEX.y;
	float z = VERTEX.z;
	float height = sqrt(x * x + y * y + z * z);
	float lh = (height - min_height) / (max_height - min_height);
	sampled_colour = texture(gradient, vec2(lh, 0.0)).rgb;
}

void fragment() {
	ROUGHNESS = 0.4;
	ALBEDO = sampled_colour;
}