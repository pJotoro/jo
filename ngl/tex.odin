package ngl

import gl "vendor:OpenGL"

tex_buffer :: proc "contextless" (tex: Tex, internal_format: Tex_Buffer_Internalformat, buffer: Buffer) {
	gl.impl_TextureBuffer(u32(tex), u32(internal_format), u32(buffer))
}

tex_image_1d_byte :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []byte) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_1d_i8 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []i8) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_1d_u16 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []u16) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_1d_i16 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []i16) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_1d_u32 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []u32) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_1d_i32 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []i32) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.INT, raw_data(pixels))
}

tex_image_1d_f16 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []f16) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_1d_f32 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []f32) {
	gl.impl_TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.FLOAT, raw_data(pixels))
}

tex_image_1d :: proc {
	tex_image_1d_byte,
	tex_image_1d_i8,
	tex_image_1d_u16,
	tex_image_1d_i16,
	tex_image_1d_u32,
	tex_image_1d_i32,
	tex_image_1d_f16,
	tex_image_1d_f32,
}

tex_image_2d_byte :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]byte) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_BYTE, pixels)
}

tex_image_2d_i8 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]i8) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.BYTE, pixels)
}

tex_image_2d_u16 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]u16) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_SHORT, pixels)
}

tex_image_2d_i16 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]i16) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.SHORT, pixels)
}

tex_image_2d_u32 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]u32) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_INT, pixels)
}

tex_image_2d_i32 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]i32) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.INT, pixels)
}

tex_image_2d_f16 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]f16) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.HALF_FLOAT, pixels)
}

tex_image_2d_f32 :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: [^]f32) {
	gl.impl_TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.FLOAT, pixels)
}

tex_image_2d :: proc {
	tex_image_2d_byte,
	tex_image_2d_i8,
	tex_image_2d_u16,
	tex_image_2d_i16,
	tex_image_2d_u32,
	tex_image_2d_i32,
	tex_image_2d_f16,
	tex_image_2d_f32,
}

get_tex_image_byte :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []byte) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.UNSIGNED_BYTE, i32(len(buf)), raw_data(buf))
}

get_tex_image_i8 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []i8) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.BYTE, i32(len(buf)), raw_data(buf))
}

get_tex_image_u16 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []u16) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.UNSIGNED_SHORT, i32(len(buf)), raw_data(buf))
}

get_tex_image_i16 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []i16) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.SHORT, i32(len(buf)), raw_data(buf))
}

get_tex_image_u32 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []u32) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.UNSIGNED_INT, i32(len(buf)), raw_data(buf))
}

get_tex_image_i32 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []i32) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.INT, i32(len(buf)), raw_data(buf))
}

get_tex_image_f16 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []f16) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.HALF_FLOAT, i32(len(buf)), raw_data(buf))
}

get_tex_image_f32 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []f32) {
	gl.impl_GetTextureImage(u32(tex), level, u32(format), gl.FLOAT, i32(len(buf)), raw_data(buf))
}

get_tex_image :: proc {
	get_tex_image_byte,
	get_tex_image_i8,
	get_tex_image_u16,
	get_tex_image_i16,
	get_tex_image_u32,
	get_tex_image_i32,
	get_tex_image_f16,
	get_tex_image_f32,
}

copy_tex_image_1d :: proc "contextless" (tex: Tex, level, xoffset, x, y, width: i32) {
	gl.impl_CopyTextureSubImage1D(u32(tex), level, xoffset, x, y, width)
}

copy_tex_image_2d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, x, y, width, height: i32) {
	gl.impl_CopyTextureSubImage2D(u32(tex), level, xoffset, yoffset, x, y, width, height)
}

delete_textures :: proc "contextless" (textures: []Tex) {
	gl.impl_DeleteTextures(i32(len(textures)), (^u32)(raw_data(textures)))
}

gen_textures :: proc "contextless" (target: Texture_Target, textures: []Tex) {
	gl.impl_CreateTextures(u32(target), i32(len(textures)), (^u32)(raw_data(textures)))
}

is_texture :: proc "contextless" (texture: u32) -> bool {
	return gl.IsTexture(texture)
}

tex_image_3d_byte :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []byte, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_3d_i8 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i8, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_3d_u16 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []u16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_3d_i16 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_3d_u32 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []u32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_3d_i32 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.INT, raw_data(pixels))
}

tex_image_3d_f16 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []f16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_3d_f32 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []f32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.impl_TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.FLOAT, raw_data(pixels))
}

tex_image_3d :: proc {
	tex_image_3d_byte,
	tex_image_3d_i8,
	tex_image_3d_u16,
	tex_image_3d_i16,
	tex_image_3d_u32,
	tex_image_3d_i32,
	tex_image_3d_f16,
	tex_image_3d_f32,
}

copy_tex_image_3d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, zoffset, x, y, width, height: i32) {
	gl.impl_CopyTextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, x, y, width, height)
}

active_texture :: proc "contextless" (unit: u32, tex: Tex) {
	gl.impl_BindTextureUnit(unit, u32(tex))
}

compressed_tex_image_1d :: proc "contextless" (tex: Tex, level, xoffset, width: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.impl_CompressedTextureSubImage1D(u32(tex), level, xoffset, width, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

compressed_tex_image_2d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.impl_CompressedTextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

compressed_tex_image_3d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.impl_CompressedTextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

get_compressed_tex_image :: proc "contextless" (tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, compressed_image: []byte) {
	gl.impl_GetCompressedTextureSubImage(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, i32(len(compressed_image)), raw_data(compressed_image))
}

generate_mipmap :: proc "contextless" (tex: Tex) {
	gl.impl_GenerateTextureMipmap(u32(tex))
}

tex_lod_bias :: proc "contextless" (tex: Tex, lod_bias: f32) {
	gl.impl_TextureParameterf(u32(tex), gl.TEXTURE_LOD_BIAS, lod_bias)
}

get_tex_lod_bias :: proc "contextless" (tex: Tex) -> (lod_bias: f32) {
	gl.impl_GetTextureParameterfv(u32(tex), gl.TEXTURE_LOD_BIAS, &lod_bias)
	return
}

tex_min_lod :: proc "contextless" (tex: Tex, min_lod: f32) {
	gl.impl_TextureParameterf(u32(tex), gl.TEXTURE_MIN_LOD, min_lod)
}

get_tex_min_lod :: proc "contextless" (tex: Tex) -> (min_lod: f32) {
	gl.impl_GetTextureParameterfv(u32(tex), gl.TEXTURE_MIN_LOD, &min_lod)
	return
}

tex_max_lod :: proc "contextless" (tex: Tex, max_lod: f32) {
	gl.impl_TextureParameterf(u32(tex), gl.TEXTURE_MAX_LOD, max_lod)
}

get_tex_max_lod :: proc "contextless" (tex: Tex) -> (max_lod: f32) {
	gl.impl_GetTextureParameterfv(u32(tex), gl.TEXTURE_MAX_LOD, &max_lod)
	return
}

tex_border_color_f32 :: proc "contextless" (tex: Tex, r, g, b, a: f32) {
	params := [4]f32{r, g, b, a}
	gl.impl_TextureParameterfv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color_i32 :: proc "contextless" (tex: Tex, r, g, b, a: i32) {
	params := [4]i32{r, g, b, a}
	gl.impl_TextureParameterIiv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color_u32 :: proc "contextless" (tex: Tex, r, g, b, a: u32) {
	params := [4]u32{r, g, b, a}
	gl.impl_TextureParameterIuiv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(params[:]))
}

tex_border_color :: proc{tex_border_color_f32, tex_border_color_i32, tex_border_color_u32}

get_tex_border_color_f32 :: proc "contextless" (tex: Tex) -> (r, g, b, a: f32) {
	rgba: [4]f32 = ---
	gl.impl_GetTextureParameterfv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

get_tex_border_color_i32 :: proc "contextless" (tex: Tex) -> (r, g, b, a: i32) {
	rgba: [4]i32 = ---
	gl.impl_GetTextureParameteriv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
	r = rgba[0]
	g = rgba[1]
	b = rgba[2]
	a = rgba[3]
	return
}

get_tex_border_color_u32 :: proc "contextless" (tex: Tex) -> (r, g, b, a: u32) {
	rgba: [4]u32 = ---
	gl.impl_GetTextureParameterIuiv(u32(tex), gl.TEXTURE_BORDER_COLOR, raw_data(&rgba))
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
	gl.impl_TextureParameteri(u32(tex), gl.DEPTH_STENCIL_TEXTURE_MODE, i32(mode))
}

tex_base_level :: proc "contextless" (tex: Tex, index: i32) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_BASE_LEVEL, index)
}

tex_compare_func :: proc "contextless" (tex: Tex, compare_func: Comparison_Func) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_COMPARE_FUNC, i32(compare_func))
}

Compare_Mode :: enum i32 {
	None = gl.NONE,
	Compare_Ref_To_Texture = gl.COMPARE_REF_TO_TEXTURE,
}

tex_compare_mode :: proc "contextless" (tex: Tex, compare_mode: Compare_Mode) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_COMPARE_MODE, i32(compare_mode))
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
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_MIN_FILTER, i32(min_filter))
}

Mag_Filter :: enum i32 {
	Nearest = gl.NEAREST,
	Linear = gl.LINEAR,
}

tex_mag_filter :: proc "contextless" (tex: Tex, mag_filter: Mag_Filter) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_MAG_FILTER, i32(mag_filter))
}

tex_max_level :: proc "contextless" (tex: Tex, max_level: i32) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_MAX_LEVEL, max_level)
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
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_R, i32(swizzle_r))
}

tex_swizzle_g :: proc "contextless" (tex: Tex, swizzle_g: Swizzle) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_G, i32(swizzle_g))
}

tex_swizzle_b :: proc "contextless" (tex: Tex, swizzle_b: Swizzle) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_B, i32(swizzle_b))
}

tex_swizzle_a :: proc "contextless" (tex: Tex, swizzle_a: Swizzle) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_SWIZZLE_A, i32(swizzle_a))
}

Wrap :: enum i32 {
	Repeat = gl.REPEAT,
	Clamp_To_Border = gl.CLAMP_TO_BORDER,
	Clamp_To_Edge = gl.CLAMP_TO_EDGE,
	Mirrored_Repeat = gl.MIRRORED_REPEAT,
	Mirror_Clamp_To_Edge = gl.MIRROR_CLAMP_TO_EDGE,
}

tex_wrap_s :: proc "contextless" (tex: Tex, wrap: Wrap) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_WRAP_S, i32(wrap))
}

tex_wrap_t :: proc "contextless" (tex: Tex, wrap: Wrap) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_WRAP_T, i32(wrap))
}

tex_wrap_r :: proc "contextless" (tex: Tex, wrap: Wrap) {
	gl.impl_TextureParameteri(u32(tex), gl.TEXTURE_WRAP_R, i32(wrap))
}

tex_swizzle_rgba :: proc "contextless" (tex: Tex, r, g, b, a: Swizzle) {
	swizzles := [4]i32{i32(r), i32(g), i32(b), i32(a)}
	gl.impl_TextureParameterIiv(u32(tex), gl.TEXTURE_SWIZZLE_RGBA, raw_data(swizzles[:]))
}

tex_storage_1d :: proc "contextless" (tex: Tex, levels: i32, internal_format: Texture_Internalformat, width: i32) {
	gl.impl_TextureStorage1D(u32(tex), levels, u32(internal_format), width)
}

tex_storage_2d :: proc "contextless" (tex: Tex, levels: i32, format: Texture_Internalformat, width, height: i32) {
	gl.impl_TextureStorage2D(u32(tex), levels, u32(format), width, height)
}

tex_storage_3d :: proc "contextless" (tex: Tex, levels: i32, internal_format: Texture_Internalformat, width, height, depth: i32) {
	gl.impl_TextureStorage3D(u32(tex), levels, u32(internal_format), width, height, depth)
}