shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Recolours only the body paint of the Kenney Car Kit models. The colormap is sampled as plain
// sRGB values; saturated pixels whose colour direction matches the model's paint (or the near-white
// cab of the flat-bed truck) are replaced by the requested paint, keeping the baked shading.
// Chassis, glass, lights and tyres keep their original colour. Written without branches or pow()
// because this runs per pixel in up to five showroom viewports.
uniform sampler2D colormap : filter_linear_mipmap, repeat_disable;
uniform vec3 paint_color = vec3(1.0);
uniform vec3 base_direction = vec3(1.0, 0.0, 0.0); // unit chroma direction of the model's paint
uniform float ref_value = 0.9;
uniform float white_paint = 0.0;
// The flat 2D art is evenly lit; side faces in 3D receive less light, so the paint is lifted a little.
uniform float paint_gain = 1.1;

vec3 srgb_to_linear(vec3 c) {
	return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

void fragment() {
	vec3 c = texture(colormap, UV).rgb;
	float mx = max(c.r, max(c.g, c.b));
	float mn = min(c.r, min(c.g, c.b));
	float spread = mx - mn;
	vec3 chroma = c - (c.r + c.g + c.b) / 3.0;
	float similarity = dot(chroma, base_direction) * inversesqrt(max(dot(chroma, chroma), 0.000001));
	float saturated = step(0.40 * mx, spread) * step(0.45, mx) * step(0.93, similarity);
	float white = step(spread, 0.07 * mx) * step(0.86, mx);
	float mask = mix(saturated, white, white_paint);
	vec3 tinted = min(paint_color * paint_gain, vec3(1.0)) * clamp(mx / ref_value, 0.6, 1.15);
	ALBEDO = srgb_to_linear(mix(c, tinted, mask));
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
