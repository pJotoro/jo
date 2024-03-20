package ngl

import gl "vendor:OpenGL"

texture_lod_bias :: proc "contextless" (texture: Texture, lod_bias: f32) {
	gl.TextureParameterf(u32(texture), gl.TEXTURE_LOD_BIAS, lod_bias)
}

texture_min_lod :: proc "contextless" (texture: Texture, min_lod: f32) {
	gl.TextureParameterf(u32(texture), gl.TEXTURE_MIN_LOD, min_lod)
}

texture_max_lod :: proc "contextless" (texture: Texture, max_lod: f32) {
	gl.TextureParameterf(u32(texture), gl.TEXTURE_MAX_LOD, max_lod)
}

texture_border_color_f :: proc "contextless" (texture: Texture, r, g, b, a: f32) {
	params := [4]f32{r, g, b, a}
	gl.TextureParameterfv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

Depth_Stencil_Mode :: enum i32 {
	Stencil_Index = gl.STENCIL_INDEX,
	Depth_Component = gl.DEPTH_COMPONENT,
}

texture_depth_stencil_mode :: proc "contextless" (texture: Texture, mode: Depth_Stencil_Mode) {
	gl.TextureParameteri(u32(texture), gl.DEPTH_STENCIL_TEXTURE_MODE, i32(mode))
}

texture_base_level :: proc "contextless" (texture: Texture, index: i32) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_BASE_LEVEL, index)
}

Compare_Func :: enum i32 {
	Never = 0x0200,
	Less,
	Equal,
	Less_Equal,
	Greater,
	Not_Equal,
	Greater_Equal,
	Always,
}

texture_compare_func :: proc "contextless" (texture: Texture, compare_func: Compare_Func) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_COMPARE_FUNC, i32(compare_func))
}

Compare_Mode :: enum i32 {
	None = 0,
	Ref_To_Texture = 0x884E,
}

texture_compare_mode :: proc "contextless" (texture: Texture, compare_mode: Compare_Mode) {
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

texture_min_filter :: proc "contextless" (texture: Texture, min_filter: Min_Filter) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_MIN_FILTER, i32(min_filter))
}

Mag_Filter :: enum i32 {
	Nearest = 0x2600,
	Linear = 0x2601,
}

texture_mag_filter :: proc "contextless" (texture: Texture, mag_filter: Mag_Filter) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_MAG_FILTER, i32(mag_filter))
}

texture_max_level :: proc "contextless" (texture: Texture, max_level: i32) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_MAX_LEVEL, max_level)
}

Swizzle :: enum i32 {
	Zero = 0,
	One = 1,
	Red = 0x1903,
	Green = 0x1904,
	Blue = 0x1905,
	Alpha = 0x1906,
}

texture_swizzle_r :: proc "contextless" (texture: Texture, swizzle_r: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_R, i32(swizzle_r))
}

texture_swizzle_g :: proc "contextless" (texture: Texture, swizzle_g: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_G, i32(swizzle_g))
}

texture_swizzle_b :: proc "contextless" (texture: Texture, swizzle_b: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_B, i32(swizzle_b))
}

texture_swizzle_a :: proc "contextless" (texture: Texture, swizzle_a: Swizzle) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_SWIZZLE_A, i32(swizzle_a))
}

Wrap :: enum i32 {
	Repeat = 0x2901,
	Clamp_To_Border = 0x812D,
	Clamp_To_Edge = 0x812F,
	Mirrored_Repeat = 0x8370,
	Mirror_Clamp_To_Edge = 0x8743,
}

texture_wrap_s :: proc "contextless" (texture: Texture, wrap: Wrap) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_WRAP_S, i32(wrap))
}

texture_wrap_t :: proc "contextless" (texture: Texture, wrap: Wrap) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_WRAP_T, i32(wrap))
}

texture_wrap_r :: proc "contextless" (texture: Texture, wrap: Wrap) {
	gl.TextureParameteri(u32(texture), gl.TEXTURE_WRAP_R, i32(wrap))
}

texture_border_color_i :: proc "contextless" (texture: Texture, r, g, b, a: i32) {
	params := [4]i32{r, g, b, a}
	gl.TextureParameterIiv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}
texture_border_color_ui :: proc "contextless" (texture: Texture, r, g, b, a: u32) {
	params := [4]u32{r, g, b, a}
	gl.TextureParameterIuiv(u32(texture), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

texture_border_color :: proc{texture_border_color_f, texture_border_color_i, texture_border_color_ui}

texture_swizzle_rgba :: proc "contextless" (texture: Texture, r, g, b, a: Swizzle) {
	swizzles := [4]i32{i32(r), i32(g), i32(b), i32(a)}
	gl.TextureParameterIiv(u32(texture), gl.TEXTURE_SWIZZLE_RGBA, raw_data(swizzles[:]))
}