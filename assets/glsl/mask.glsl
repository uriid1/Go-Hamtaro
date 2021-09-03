vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
   if (Texel(tex, texture_coords).rgb == vec3(0.0)) {
      discard;
   }
   return vec4(1.0);
}