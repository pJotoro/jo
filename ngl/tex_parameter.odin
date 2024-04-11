package ngl

import gl "vendor:OpenGL"

Texture :: distinct u32

tex_lod_bias :: proc "contextless" (texture: Texture, lod_bias: f32) {
	gl.TextureParameterf(u32(texture), gl.TEXTURE_LOD_BIAS, lod_bias)
}

get_tex_lod_bias :: proc "contextless" (texture: Texture) -> (lod_bias: f32) {
	gl.GetTextureParameterfv(u32(texture), gl.TEXTURE_LOD_BIAS, &lod_bias)
	return
}

tex_min_lod :: proc "contextless" (texture: Texture, min_lod: f32) {
	gl.TextureParameterf(u32(texture), gl.TEXTURE_MIN_LOD, min_lod)
}

get_tex_min_lod :: proc "contextless" (texture: Texture) -> (min_lod: f32) {
	gl.GetTextureParameterfv(u32(texture), gl.TEXTURE_MIN_LOD, &min_lod)
	return
}

tex_max_lod :: proc "contextless" (texture: Texture, max_lod: f32) {
	gl.TextureParameterf(u32(texture), gl.TEXTURE_MAX_LOD, max_lod)
}

get_tex_max_lod :: proc "contextless" (texture: Texture) -> (max_lod: f32) {
	gl.GetTextureParameterfv(u32(texture), gl.TEXTURE_MAX_LOD, &max_lod)
	return
}

tex_border_color_f32 :: proc "contextless" (texture: Texture, r, g, b, a: f32) {
	params := [4]f32{r, g, b, a}
	gl.TextureParameterfv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color_i32 :: proc "contextless" (texture: Texture, r, g, b, a: i32) {
	params := [4]i32{r, g, b, a}
	gl.TextureParameterIiv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color_u32 :: proc "contextless" (texture: Texture, r, g, b, a: u32) {
	params := [4]u32{r, g, b, a}
	gl.TextureParameterIuiv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color :: proc{tex_border_color_f32, tex_border_color_i32, tex_border_color_u32}

get_tex_border_color_f32 :: proc "contextless" (texture: Texture) -> (r, g, b, a: f32) {
	rgba: [4]f32 = ---
	gl.GetTextureParameterfv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

get_tex_border_color_i32 :: proc "contextless" (texture: Texture) -> (r, g, b, a: i32) {
	rgba: [4]i32 = ---
	gl.GetTextureParameteriv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

get_tex_border_color_u32 :: proc "contextless" (texture: Texture) -> (r, g, b, a: u32) {
	rgba: [4]u32 = ---
	gl.GetTextureParameterIuiv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

Depth_Stencil_Mode :: enum i32 {
	Stencil_Index = gl.STENCIL_INDEX,
	Depth_Component = gl.DEPTH_COMPONENT,
}

tex_depth_stencil_mode :: proc "contextless" (texture: Texture, mode: Depth_Stencil_Mode) {
	gl.TextureParameteri(u32(texture), gl.DEPTH_STENCIL_TEXTURE_MODE, i32(mode))
}

tex_base_level :: proc "contextless" (texture: Texture, index: i32) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_BASE_LEVEL, index)
}

tex_compare_func :: proc "contextless" (texture: Texture, compare_func: Comparison_Func) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_COMPARE_FUNC, i32(compare_func))
}

Compare_Mode :: enum i32 {
	None = 0,
	Ref_To_Texture = 0x884E,
}

tex_compare_mode :: proc "contextless" (texture: Texture, compare_mode: Compare_Mode) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_COMPARE_MODE, i32(compare_mode))
}

Min_Filter :: enum i32 {
	Nearest = 0x2600,
	Linear = 0x2601,
	Nearest_Mipmap_Nearest = 0x2700,
	Linear_Mipmap_Nearest = 0x2701,
	Nearest_Mipmap_Linear = 0x2702,
	Linear_Mipmap_Linear = 0x2703,
}

tex_min_filter :: proc "contextless" (texture: Texture, min_filter: Min_Filter) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_MIN_FILTER, i32(min_filter))
}

Mag_Filter :: enum i32 {
	Nearest = 0x2600,
	Linear = 0x2601,
}

tex_mag_filter :: proc "contextless" (texture: Texture, mag_filter: Mag_Filter) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_MAG_FILTER, i32(mag_filter))
}

tex_max_level :: proc "contextless" (texture: Texture, max_level: i32) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_MAX_LEVEL, max_level)
}

Swizzle :: enum i32 {
	Zero = gl.ZERO,
	One = gl.ONE,
	Red = gl.RED,
	Green = gl.GREEN,
	Blue = gl.BLUE,
	Alpha = gl.ALPHA,
}

tex_swizzle_r :: proc "contextless" (texture: Texture, swizzle_r: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_R, i32(swizzle_r))
}

tex_swizzle_g :: proc "contextless" (texture: Texture, swizzle_g: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_G, i32(swizzle_g))
}

tex_swizzle_b :: proc "contextless" (texture: Texture, swizzle_b: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_B, i32(swizzle_b))
}

tex_swizzle_a :: proc "contextless" (texture: Texture, swizzle_a: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_A, i32(swizzle_a))
}

Wrap :: enum i32 {
	Repeat = gl.REPEAT,
	Clamp_To_Border = gl.CLAMP_TO_BORDER,
	Clamp_To_Edge = gl.CLAMP_TO_EDGE,
	Mirrored_Repeat = gl.MIRRORED_REPEAT,
	Mirror_Clamp_To_Edge = gl.MIRROR_CLAMP_TO_EDGE,
}

tex_wrap_s :: proc "contextless" (texture: Texture, wrap: Wrap) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_WRAP_S, i32(wrap))
}

tex_wrap_t :: proc "contextless" (texture: Texture, wrap: Wrap) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_WRAP_T, i32(wrap))
}

tex_wrap_r :: proc "contextless" (texture: Texture, wrap: Wrap) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_WRAP_R, i32(wrap))
}

tex_swizzle_rgba :: proc "contextless" (texture: Texture, r, g, b, a: Swizzle) {
	swizzles := [4]i32{i32(r), i32(g), i32(b), i32(a)}
	gl.TextureParameterIiv(u32(texture), gl.TEXTURE_SWIZZLE_RGBA, raw_data(swizzles[:]))
}