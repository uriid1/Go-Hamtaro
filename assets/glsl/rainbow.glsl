// Rainbow Color 
// currentTime = os.clock() * 10;
uniform float currentTime;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	// Получаем координаты текущего пикселя
	vec2 xy = texture_coords.xy;

	// Плавно меняем
	vec3 col = 0.5 + 0.5 * cos(currentTime + xy.xyx + vec3(0, 2, 4));

	// Записываем цвет
	color = vec4(col, 1.0);

    vec4 texturecolor = Texel(texture, texture_coords);
    return texturecolor * color;
}