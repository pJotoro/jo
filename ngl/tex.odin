package ngl

import gl "vendor:OpenGL"

tex_lod_bias :: proc "contextless" (tex: Tex, lod_bias: f32) {
	gl.TextureParameterf(u32(tex), gl.TEXTURE_LOD_BIAS, lod_bias)
}

get_tex_lod_bias :: proc "contextless" (tex: Tex) -> (lod_bias: f32) {
	gl.GetTextureParameterfv(u32(tex), gl.TEXTURE_LOD_BIAS, &lod_bias)
	return
}

tex_min_lod :: proc "contextless" (tex: Tex, min_lod: f32) {
	gl.TextureParameterf(u32(tex), gl.TEXTURE_MIN_LOD, min_lod)
}

get_tex_min_lod :: proc "contextless" (tex: Tex) -> (min_lod: f32) {
	gl.GetTextureParameterfv(u32(tex), gl.TEXTURE_MIN_LOD, &min_lod)
	return
}

tex_max_lod :: proc "contextless" (tex: Tex, max_lod: f32) {
	gl.TextureParameterf(u32(tex), gl.TEXTURE_MAX_LOD, max_lod)
}

get_tex_max_lod :: proc "contextless" (tex: Tex) -> (max_lod: f32) {
	gl.GetTextureParameterfv(u32(tex), gl.TEXTURE_MAX_LOD, &max_lod)
	return
}

tex_border_color_f32 :: proc "contextless" (tex: Tex, r, g, b, a: f32) {
	params := [4]f32{r, g, b, a}
	gl.TextureParameterfv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color_i32 :: proc "contextless" (tex: Tex, r, g, b, a: i32) {
	params := [4]i32{r, g, b, a}
	gl.TextureParameterIiv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color_u32 :: proc "contextless" (tex: Tex, r, g, b, a: u32) {
	params := [4]u32{r, g, b, a}
	gl.TextureParameterIuiv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color :: proc{tex_border_color_f32, tex_border_color_i32, tex_border_color_u32}

get_tex_border_color_f32 :: proc "contextless" (tex: Tex) -> (r, g, b, a: f32) {
	rgba: [4]f32 = ---
	gl.GetTextureParameterfv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

get_tex_border_color_i32 :: proc "contextless" (tex: Tex) -> (r, g, b, a: i32) {
	rgba: [4]i32 = ---
	gl.GetTextureParameteriv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

get_tex_border_color_u32 :: proc "contextless" (tex: Tex) -> (r, g, b, a: u32) {
	rgba: [4]u32 = ---
	gl.GetTextureParameterIuiv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
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

tex_depth_stencil_mode :: proc "contextless" (tex: Tex, mode: Depth_Stencil_Mode) {
	gl.TextureParameteri(u32(tex), gl.DEPTH_STENCIL_TEXTURE_MODE, i32(mode))
}

tex_base_level :: proc "contextless" (tex: Tex, index: i32) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_BASE_LEVEL, index)
}

tex_compare_func :: proc "contextless" (tex: Tex, compare_func: Comparison_Func) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_COMPARE_FUNC, i32(compare_func))
}

Compare_Mode :: enum i32 {
	None = gl.NONE,
	Compare_Ref_To_Texture = gl.COMPARE_REF_TO_TEXTURE,
}

tex_compare_mode :: proc "contextless" (tex: Tex, compare_mode: Compare_Mode) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_COMPARE_MODE, i32(compare_mode))
}

Min_Filter :: enum i32 {
	Nearest = gl.NEAREST,
	Linear = gl.LINEAR,
	Nearest_Mipmap_Nearest = gl.NEAREST_MIPMAP_NEAREST,
	Linear_Mipmap_Nearest = gl.LINEAR_MIPMAP_NEAREST,
	Nearest_Mipmap_Linear = gl.NEAREST_MIPMAP_LINEAR,
	Linear_Mipmap_Linear = gl.LINEAR_MIPMAP_LINEAR,
}

tex_min_filter :: proc "contextless" (tex: Tex, min_filter: Min_Filter) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_MIN_FILTER, i32(min_filter))
}

Mag_Filter :: enum i32 {
	Nearest = gl.NEAREST,
	Linear = gl.LINEAR,
}

tex_mag_filter :: proc "contextless" (tex: Tex, mag_filter: Mag_Filter) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_MAG_FILTER, i32(mag_filter))
}

tex_max_level :: proc "contextless" (tex: Tex, max_level: i32) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_MAX_LEVEL, max_level)
}

Swizzle :: enum i32 {
	Zero = gl.ZERO,
	One = gl.ONE,
	Red = gl.RED,
	Green = gl.GREEN,
	Blue = gl.BLUE,
	Alpha = gl.ALPHA,
}

tex_swizzle_r :: proc "contextless" (tex: Tex, swizzle_r: Swizzle) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_R, i32(swizzle_r))
}

tex_swizzle_g :: proc "contextless" (tex: Tex, swizzle_g: Swizzle) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_G, i32(swizzle_g))
}

tex_swizzle_b :: proc "contextless" (tex: Tex, swizzle_b: Swizzle) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_B, i32(swizzle_b))
}

tex_swizzle_a :: proc "contextless" (tex: Tex, swizzle_a: Swizzle) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_A, i32(swizzle_a))
}

Wrap :: enum i32 {
	Repeat = gl.REPEAT,
	Clamp_To_Border = gl.CLAMP_TO_BORDER,
	Clamp_To_Edge = gl.CLAMP_TO_EDGE,
	Mirrored_Repeat = gl.MIRRORED_REPEAT,
	Mirror_Clamp_To_Edge = gl.MIRROR_CLAMP_TO_EDGE,
}

tex_wrap_s :: proc "contextless" (tex: Tex, wrap: Wrap) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_WRAP_S, i32(wrap))
}

tex_wrap_t :: proc "contextless" (tex: Tex, wrap: Wrap) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_WRAP_T, i32(wrap))
}

tex_wrap_r :: proc "contextless" (tex: Tex, wrap: Wrap) {
	gl.TextureParameteri(u32(tex), gl.TEXTURE_WRAP_R, i32(wrap))
}

tex_swizzle_rgba :: proc "contextless" (tex: Tex, r, g, b, a: Swizzle) {
	swizzles := [4]i32{i32(r), i32(g), i32(b), i32(a)}
	gl.TextureParameterIiv(u32(tex), gl.TEXTURE_SWIZZLE_RGBA, raw_data(swizzles[:]))
}