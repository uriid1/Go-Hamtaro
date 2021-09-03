#pragma language glsl3
extern vec2 stepSize;
float alpha;

vec4 effect(vec4 col, Image tex, vec2 texturePos, vec2 screenPos) {
	// get color of pixels:
	alpha = Texel(tex, texturePos).a;
	alpha = alpha * 4.0f;

	alpha -= Texel(tex, texturePos - vec2( stepSize.x, -stepSize.y)).a;
	alpha -= Texel(tex, texturePos - vec2(-stepSize.x, -stepSize.y)).a;
	alpha -= Texel(tex, texturePos - vec2( stepSize.x,  stepSize.y)).a;
	alpha -= Texel(tex, texturePos - vec2(-stepSize.x,  stepSize.y)).a;

	// calculate resulting color
	return vec4(1.0f, 1.0f, 1.0f, alpha);
}