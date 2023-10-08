shader_type canvas_item;
 
uniform sampler2D noise;
uniform sampler2D clumps;

void fragment() {
	vec2 uv = UV;
	
	float random = texture(noise, vec2(0, sin(uv.y * 1.2))).r;
	float clump = texture(clumps, uv).r;
	uv.x += random * 0.1 * abs(sin(random + TIME * 0.3)) + uv.x * 0.6 * clump;
	uv += vec2(sin(TIME * 0.1) * 0.1 - 0.1, 0.2);
	
	float dist = (1.0 - uv.x);
	
	uv = uv - floor(uv);
	COLOR.a = texture(noise, uv).r * dist * dist;
}