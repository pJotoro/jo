package ngl

import gl "vendor:OpenGL"
import "core:mem"
import "core:strings"
import "../misc"

// VERSION_1_0

cull_face :: proc "contextless" (mode: Cull_Face_Mode) {
	gl.CullFace(u32(mode))
}

front_face :: proc "contextless" (mode: Front_Face_Direction) {
	gl.FrontFace(u32(mode))
}

hint :: proc "contextless" (target: Hint_Target, mode: Hint_Mode) {
	gl.Hint(u32(target), u32(mode))
}

line_width :: proc "contextless" (width: f32) {
	gl.LineWidth(width)
}

point_size :: proc "contextless" (size: f32) {
	gl.PointSize(size)
}

polygon_mode :: proc "contextless" (mode: Polygon_Mode_Face) {
	gl.PolygonMode(gl.FRONT_AND_BACK, u32(mode))
}

scissor :: proc "contextless" (x, y, width, height: i32) {
	gl.Scissor(x, y, width, height)
}

// tex_parameter - see texture_parameter.odin

tex_image_1d_byte :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []byte) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_1d_i8 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []i8) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_1d_u16 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []u16) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_1d_i16 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []i16) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_1d_u32 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []u32) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_1d_i32 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []i32) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.INT, raw_data(pixels))
}

tex_image_1d_f16 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []f16) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_1d_f32 :: proc "contextless" (texture: Texture, level, offset: i32, format: Pixel_Data_Format, pixels: []f32) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), u32(format), gl.FLOAT, raw_data(pixels))
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

tex_image_2d_byte :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []byte, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_2d_i8 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []i8, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_2d_u16 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []u16, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_2d_i16 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []i16, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_2d_u32 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []u32, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_2d_i32 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []i32, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.INT, raw_data(pixels))
}

tex_image_2d_f16 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []f16, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_2d_f32 :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []f32, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl.FLOAT, raw_data(pixels))
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

draw_buffer :: proc "contextless" (framebuffer: Framebuffer, buf: Draw_Buffer) {
	gl.NamedFramebufferDrawBuffer(u32(framebuffer), u32(buf))
}

clear :: proc "contextless" (flags: Clear_Bits) {
	gl.Clear(transmute(u32)flags)
}

clear_color :: proc "contextless" (red, green, blue, alpha: f32) {
	gl.ClearColor(red, green, blue, alpha)
}

clear_stencil :: proc "contextless" (s: i32) {
	gl.ClearStencil(s)
}

clear_depth :: proc "contextless" (depth: f64) {
	gl.ClearDepth(depth)
}

stencil_mask :: proc "contextless" (mask: u32) {
	gl.StencilMask(mask)
}

color_mask :: proc "contextless" (red, green, blue, alpha: bool) {
	gl.ColorMask(red, green, blue, alpha)
}

depth_mask :: proc "contextless" (flag: bool) {
	gl.DepthMask(flag)
}

disable :: proc "contextless" (cap: Disable_Target) {
	gl.Disable(u32(cap))
}

enable :: proc "contextless" (cap: Enable_Target) {
	gl.Enable(u32(cap))
}

finish :: proc "contextless" () {
	gl.Finish()
}

flush :: proc "contextless" () {
	gl.Flush()
}

blend_func :: proc "contextless" (sfactor, dfactor: Blend_Function) {
	gl.BlendFunc(u32(sfactor), u32(dfactor))
}

logic_op :: proc "contextless" (opcode: Logical_Operation) {
	gl.LogicOp(u32(opcode))
}

stencil_func :: proc "contextless" (func: Comparison_Func, ref: i32, mask: u32) {
	gl.StencilFunc(u32(func), ref, mask)
}

stencil_op :: proc "contextless" (sfail, dpfail, dppass: Stencil_Operation) {
	gl.StencilOp(u32(sfail), u32(dpfail), u32(dppass))
}

depth_func :: proc "contextless" (func: Comparison_Func) {
	gl.DepthFunc(u32(func))
}

pixel_store_f :: proc "contextless" (pname: Pixel_Store_Parameter, param: f32) {
	gl.PixelStoref(u32(pname), param)
}

pixel_store_i :: proc "contextless" (pname: Pixel_Store_Parameter, param: i32) {
	gl.PixelStorei(u32(pname), param)
}

pixel_store :: proc{pixel_store_f, pixel_store_i}

read_buffer :: proc "contextless" (framebuffer: Framebuffer, src: Draw_Buffer) {
	gl.NamedFramebufferReadBuffer(u32(framebuffer), u32(src))
}

read_pixels_byte :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []byte) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.UNSIGNED_BYTE, i32(len(buf)), raw_data(buf))
}

read_pixels_i8 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []i8) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.BYTE, i32(len(buf)), raw_data(buf))
}

read_pixels_u16 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []u16) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.UNSIGNED_SHORT, i32(len(buf)), raw_data(buf))
}

read_pixels_i16 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []i16) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.SHORT, i32(len(buf)), raw_data(buf))
}

read_pixels_u32 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []u32) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.UNSIGNED_INT, i32(len(buf)), raw_data(buf))
}

read_pixels_i32 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []i32) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.INT, i32(len(buf)), raw_data(buf))
}

read_pixels_f16 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []f16) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.HALF_FLOAT, i32(len(buf)), raw_data(buf))
}

read_pixels_f32 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []f32) {
	gl.ReadnPixels(x, y, width, height, u32(format), gl.FLOAT, i32(len(buf)), raw_data(buf))
}

read_pixels :: proc {
	read_pixels_byte,
	read_pixels_i8,
	read_pixels_u16,
	read_pixels_i16,
	read_pixels_u32,
	read_pixels_i32,
	read_pixels_f16,
	read_pixels_f32,
}

// get_boolean - see get.odin

// get_double - see get.odin

get_error :: proc "contextless" () -> Error {
    return Error(gl.GetError())
}

// get_float - see get.odin

// get_integer - see get.odin

get_string :: proc "contextless" (name: Get_String_Name) -> string {
	return string(gl.GetString(u32(name)))
}

get_tex_image_byte :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []byte) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.UNSIGNED_BYTE, i32(len(buf)), raw_data(buf))
}

get_tex_image_i8 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []i8) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.BYTE, i32(len(buf)), raw_data(buf))
}

get_tex_image_u16 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []u16) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.UNSIGNED_SHORT, i32(len(buf)), raw_data(buf))
}

get_tex_image_i16 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []i16) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.SHORT, i32(len(buf)), raw_data(buf))
}

get_tex_image_u32 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []u32) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.UNSIGNED_INT, i32(len(buf)), raw_data(buf))
}

get_tex_image_i32 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []i32) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.INT, i32(len(buf)), raw_data(buf))
}

get_tex_image_f16 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []f16) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.HALF_FLOAT, i32(len(buf)), raw_data(buf))
}

get_tex_image_f32 :: proc "contextless" (texture: Texture, level: i32, format: Pixel_Data_Format, buf: []f32) {
	gl.GetTextureImage(u32(texture), level, u32(format), gl.FLOAT, i32(len(buf)), raw_data(buf))
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

// get_tex_parameter - see tex_parameter.odin

// get_tex_level_parameter - see tex_parameter.odin

is_enabled :: proc "contextless" (cap: Is_Enabled_Cap) -> bool {
	return gl.IsEnabled(u32(cap))
}

depth_range :: proc "contextless" (near, far: f64) {
	gl.DepthRange(near, far)
}

viewport :: proc "contextless" (x, y, width, height: i32) {
	gl.Viewport(x, y, width, height)
}


// VERSION_1_1

draw_arrays :: proc "contextless" (mode: Draw_Mode, first, count: i32) {
	gl.DrawArrays(u32(mode), first, count)
}

draw_elements_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices))
}

draw_elements_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices))
}

draw_elements_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices))
}

draw_elements :: proc{draw_elements_byte, draw_elements_u16, draw_elements_u32}

polygon_offset :: proc "contextless" (factor, units: f32) {
	gl.PolygonOffset(factor, units)
}

copy_tex_image_1d :: proc "contextless" (texture: Texture, level, xoffset, x, y, width: i32) {
	gl.CopyTextureSubImage1D(u32(texture), level, xoffset, x, y, width)
}

copy_tex_image_2d :: proc "contextless" (texture: Texture, level, xoffset, yoffset, x, y, width, height: i32) {
	gl.CopyTextureSubImage2D(u32(texture), level, xoffset, yoffset, x, y, width, height)
}

delete_textures :: proc "contextless" (textures: []Texture) {
	gl.DeleteTextures(i32(len(textures)), (^u32)(raw_data(textures)))
}

gen_textures :: proc "contextless" (target: Texture_Target, textures: []Texture) {
	gl.CreateTextures(u32(target), i32(len(textures)), (^u32)(raw_data(textures)))
}

is_texture :: proc "contextless" (maybe_texture: u32) -> bool {
	return gl.IsTexture(maybe_texture)
}


// VERSION_1_2

// draw_range_elements - see draw_elements, and slices.

tex_image_3d_byte :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []byte, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_3d_i8 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i8, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_3d_u16 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []u16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_3d_i16 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_3d_u32 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []u32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_3d_i32 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.INT, raw_data(pixels))
}

tex_image_3d_f16 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []f16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_3d_f32 :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []f32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.FLOAT, raw_data(pixels))
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

copy_tex_image_3d :: proc "contextless" (texture: Texture, level, xoffset, yoffset, zoffset, x, y, width, height: i32) {
	gl.CopyTextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, x, y, width, height)
}


// VERSION_1_3

active_texture :: proc "contextless" (unit: u32, texture: Texture) {
	gl.BindTextureUnit(unit, u32(texture))
}

sample_coverage :: proc "contextless" (value: f32, invert: bool) {
	gl.SampleCoverage(value, invert)
}

compressed_tex_image_1d :: proc "contextless" (texture: Texture, level, xoffset, width: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.CompressedTextureSubImage1D(u32(texture), level, xoffset, width, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

compressed_tex_image_2d :: proc "contextless" (texture: Texture, level, xoffset, yoffset, width, height: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.CompressedTextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

compressed_tex_image_3d :: proc "contextless" (texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.CompressedTextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

get_compressed_tex_image :: proc "contextless" (texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, compressed_image: []byte) {
	gl.GetCompressedTextureSubImage(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, i32(len(compressed_image)), raw_data(compressed_image))
}


// VERSION_1_4

blend_func_separate :: proc "contextless" (s_factor_rgb, d_factor_rgb, s_factor_alpha, d_factor_alpha: Blend_Function) {
	gl.BlendFuncSeparate(u32(s_factor_rgb), u32(d_factor_rgb), u32(s_factor_alpha), u32(d_factor_alpha))
}

multi_draw_arrays :: proc(mode: Draw_Mode, first, count: []i32, loc := #caller_location) {
	assert(len(first) == len(count), "len(first) != len(count)", loc)
	gl.MultiDrawArrays(u32(mode), raw_data(first), raw_data(count), i32(len(first)))
}

multi_draw_elements_byte :: proc(mode: Draw_Mode, count: []i32, indices: []byte, loc := #caller_location) {
	assert(len(count) == len(indices), "len(count) != len(indices)", loc)
	gl.MultiDrawElements(u32(mode), raw_data(count), gl.UNSIGNED_BYTE, (^rawptr)(raw_data(indices)), i32(len(count)))
}

multi_draw_elements_u16 :: proc(mode: Draw_Mode, count: []i32, indices: []u16, loc := #caller_location) {
	assert(len(count) == len(indices), "len(count) != len(indices)", loc)
	gl.MultiDrawElements(u32(mode), raw_data(count), gl.UNSIGNED_SHORT, (^rawptr)(raw_data(indices)), i32(len(count)))
}

multi_draw_elements_u32 :: proc(mode: Draw_Mode, count: []i32, indices: []u32, loc := #caller_location) {
	assert(len(count) == len(indices), "len(count) != len(indices)", loc)
	gl.MultiDrawElements(u32(mode), raw_data(count), gl.UNSIGNED_INT, (^rawptr)(raw_data(indices)), i32(len(count)))
}

multi_draw_elements :: proc {
	multi_draw_elements_byte,
	multi_draw_elements_u16,
	multi_draw_elements_u32,
}

point_fade_threshold_size :: proc "contextless" (value: f32) {
	gl.PointParameterf(gl.POINT_FADE_THRESHOLD_SIZE, value)
}

Point_Sprite_Coord_Origin :: enum i32 {
	Lower_Left = gl.LOWER_LEFT,
	Upper_Left = gl.UPPER_LEFT,
}

point_sprite_coord_origin :: proc "contextless" (value: Point_Sprite_Coord_Origin) {
	gl.PointParameteri(gl.POINT_SPRITE_COORD_ORIGIN, i32(value))
}

blend_color :: proc "contextless" (red, green, blue, alpha: f32) {
	gl.BlendColor(red, green, blue, alpha)
}

blend_equation :: proc "contextless" (mode: Blend_Mode) {
	gl.BlendEquation(u32(mode))
}


// VERSION_1_5

gen_queries :: proc "contextless" (target: Query_And_Timestamp_Target, ids: []Query) {
	gl.CreateQueries(u32(target), i32(len(ids)), ([^]u32)(raw_data(ids)))
}

delete_queries :: proc "contextless" (ids: []Query) {
	gl.DeleteQueries(i32(len(ids)), ([^]u32)(raw_data(ids)))
}

is_query :: proc "contextless" (query: u32) -> bool {
	return gl.IsQuery(query)
}

// TODO

delete_buffers :: proc "contextless" (buffers: []Buffer) {
	gl.DeleteBuffers(i32(len(buffers)), ([^]u32)(raw_data(buffers)))
}

gen_buffers :: proc "contextless" (buffers: []Buffer) {
	gl.GenBuffers(i32(len(buffers)), ([^]u32)(raw_data(buffers)))
}

is_buffer :: proc "contextless" (buffer: u32) -> bool {
	return gl.IsBuffer(buffer)
}

buffer_data :: proc "contextless" (buffer: Buffer, data: []byte, usage: Buffer_Data_Usage) {
	gl.NamedBufferData(u32(buffer), len(data), raw_data(data), u32(usage))
}

buffer_sub_data :: proc "contextless" (buffer: Buffer, offset: int, data: []byte) {
	gl.NamedBufferSubData(u32(buffer), offset, len(data), raw_data(data))
}

get_buffer_sub_data :: proc "contextless" (buffer: Buffer, offset: int, data: []byte) {
	gl.GetNamedBufferSubData(u32(buffer), offset, len(data), raw_data(data))
}

map_buffer :: proc "contextless" (buffer: Buffer, offset, length: int, access: Access_Bits) -> []byte {
	data: mem.Raw_Slice
	data.len = length
	data.data = gl.MapNamedBufferRange(u32(buffer), offset, length, u32(access))
	return transmute([]byte)data
}

unmap_buffer :: proc "contextless" (buffer: Buffer) {
	gl.UnmapNamedBuffer(u32(buffer))
}

// get_buffer_parameter - see buffer_parameter.odin

get_buffer_pointer :: proc "contextless" (buffer: Buffer) -> (pointer: rawptr) {
	gl.GetNamedBufferPointerv(u32(buffer), gl.BUFFER_MAP_POINTER, &pointer)
	return
}


// VERSION_2_0



/*

buffer_storage :: proc "contextless" (buffer: Buffer, data: []byte, flags: Buffer_Storage_Flags) {
	gl.NamedBufferStorage(u32(buffer), len(data), raw_data(data), transmute(u32)flags)
}

copy_buffer_sub_data :: proc "contextless" (read_buffer, write_buffer: Buffer, read_offset, write_offset, size: int) {
	gl.CopyNamedBufferSubData(u32(read_buffer), u32(write_buffer), read_offset, write_offset, size)
}

create_shader_from_binary :: proc(binary: []byte, type: Shader_Type, entry := "main", loc := #caller_location) -> (Shader, bool) #optional_ok {
	assert(condition = align_of(raw_data(binary)) >= align_of(u32), loc = loc)
	cstring_entry := strings.clone_to_cstring(entry, context.temp_allocator, loc)
	shader := gl.CreateShader(u32(type))
	gl.ShaderBinary(1, &shader, gl.SHADER_BINARY_FORMAT_SPIR_V, raw_data(binary), i32(len(binary)))
	gl.SpecializeShader(shader, cstring_entry, 0, nil, nil)
	success: i32 = ---
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
	when !ODIN_DISABLE_ASSERT {
		if success == 0 {
			info_log: [512]byte = ---
			gl.GetShaderInfoLog(shader, 512, nil, raw_data(info_log[:]))
			panic(string(cstring(raw_data(info_log[:]))), loc)
		}
	}
	return Shader(shader), bool(success)
}

create_shader_from_file :: proc(filename: string, type: Shader_Type, entry := "main", loc := #caller_location) -> (Shader, bool) #optional_ok {
	binary, ok := misc.read_entire_file_aligned(filename, align_of(u32))
	assert(condition = ok, loc = loc)
	return create_shader_from_binary(binary, type, entry, loc)
}

create_shader :: proc{create_shader_from_binary, create_shader_from_file}



create_program :: proc(shaders: ..Shader, loc := #caller_location) -> (Program, bool) #optional_ok {
	program := gl.CreateProgram()
	for shader in shaders {
		gl.AttachShader(program, u32(shader))
	}
	gl.LinkProgram(program)
	success: i32 = ---
	gl.GetProgramiv(program, gl.LINK_STATUS, &success)
	when !ODIN_DISABLE_ASSERT {
		if success == 0 {
			info_log: [512]byte = ---
			gl.GetShaderInfoLog(program, 512, nil, raw_data(info_log[:]))
			panic(string(cstring(raw_data(info_log[:]))), loc)
		}
	}
	return Program(program), bool(success)
}

use_program :: proc "contextless" (program: Program) {
	gl.UseProgram(u32(program))
}

get_uniform_location_cstring :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.GetUniformLocation(u32(program), name)
}

get_uniform_location_string :: proc(program: Program, name: string, loc := #caller_location) -> i32 {
	cstring_name := strings.clone_to_cstring(name, context.temp_allocator, loc)
	return gl.GetUniformLocation(u32(program), cstring_name)
}

get_uniform_location :: proc{get_uniform_location_cstring, get_uniform_location_string}



create_pipeline :: proc "contextless" () -> Pipeline {
	pipeline: u32 = ---
	gl.CreateProgramPipelines(1, &pipeline)
	return Pipeline(pipeline)
}

create_pipelines :: proc(n: i32, allocator := context.allocator, loc := #caller_location) -> []Pipeline {
	pipelines := make([]u32, n, allocator, loc)
	gl.CreateProgramPipelines(n, raw_data(pipelines))
	return transmute([]Pipeline)pipelines
}

use_stages :: proc "contextless" (pipeline: Pipeline, stages: Stage_Flags, program: Program) {
	gl.UseProgramStages(u32(pipeline), transmute(u32)stages, u32(program))
}

bind_pipeline :: proc "contextless" (pipeline: Pipeline) {
	gl.BindProgramPipeline(u32(pipeline))
}



create_vertex_array :: proc "contextless" () -> Vertex_Array {
	vertex_array: u32 = ---
	gl.CreateVertexArrays(1, &vertex_array)
	return Vertex_Array(vertex_array)
}

create_vertex_arrays :: proc(n: i32) -> []Vertex_Array {
	vertex_arrays := make([]u32, n)
	gl.CreateVertexArrays(n, raw_data(vertex_arrays))
	return transmute([]Vertex_Array)vertex_arrays
}

bind_vertex_buffer :: proc "contextless" (vertex_array: Vertex_Array, binding_index: u32, vertex_buffer: Buffer, offset: int, stride: i32) {
	gl.VertexArrayVertexBuffer(u32(vertex_array), binding_index, u32(vertex_buffer), offset, stride)
}

bind_element_buffer :: proc "contextless" (vertex_array: Vertex_Array, element_buffer: Buffer) {
	gl.VertexArrayElementBuffer(u32(vertex_array), u32(element_buffer))
}

enable_vertex_array_attrib :: proc "contextless" (vertex_array: Vertex_Array, attrib_index: u32) {
	gl.EnableVertexArrayAttrib(u32(vertex_array), attrib_index)
}

vertex_array_attrib_format :: proc "contextless" (vertex_array: Vertex_Array, attrib_index: u32, size: i32, $type: typeid, normalized: bool, relative_offset: u32, loc := #caller_location) {
	gl.VertexArrayAttribFormat(u32(vertex_array), attrib_index, size, gl_type(type), normalized, relative_offset)
}

vertex_array_attrib_binding :: proc "contextless" (vertex_array: Vertex_Array, attrib_index, binding_index: u32) {
	gl.VertexArrayAttribBinding(u32(vertex_array), attrib_index, binding_index)
}

bind_vertex_array :: proc "contextless" (vertex_array: Vertex_Array) {
	gl.BindVertexArray(u32(vertex_array))
}

program_uniform_1f :: proc "contextless" (program: Program, location: i32, v0: f32) {
	gl.ProgramUniform1f(u32(program), location, v0)
}

program_uniform_2f :: proc "contextless" (program: Program, location: i32, v0, v1: f32) {
	gl.ProgramUniform2f(u32(program), location, v0, v1)
}

program_uniform_3f :: proc "contextless" (program: Program, location: i32, v0, v1, v2: f32) {
	gl.ProgramUniform3f(u32(program), location, v0, v1, v2)
}

program_uniform_4f :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: f32) {
	gl.ProgramUniform4f(u32(program), location, v0, v1, v2, v3)
}

program_uniform_1i :: proc "contextless" (program: Program, location: i32, v0: i32) {
	gl.ProgramUniform1i(u32(program), location, v0)
}

program_uniform_2i :: proc "contextless" (program: Program, location: i32, v0, v1: i32) {
	gl.ProgramUniform2i(u32(program), location, v0, v1)
}

program_uniform_3i :: proc "contextless" (program: Program, location: i32, v0, v1, v2: i32) {
	gl.ProgramUniform3i(u32(program), location, v0, v1, v2)
}

program_uniform_4i :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: i32) {
	gl.ProgramUniform4i(u32(program), location, v0, v1, v2, v3)
}

program_uniform_1ui :: proc "contextless" (program: Program, location: i32, v0: u32) {
	gl.ProgramUniform1ui(u32(program), location, v0)
}

program_uniform_2ui :: proc "contextless" (program: Program, location: i32, v0, v1: u32) {
	gl.ProgramUniform2ui(u32(program), location, v0, v1)
}

program_uniform_3ui :: proc "contextless" (program: Program, location: i32, v0, v1, v2: u32) {
	gl.ProgramUniform3ui(u32(program), location, v0, v1, v2)
}

program_uniform_4ui :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: u32) {
	gl.ProgramUniform4ui(u32(program), location, v0, v1, v2, v3)
}

program_uniform :: proc{
	program_uniform_1f,
	program_uniform_2f,
	program_uniform_3f,
	program_uniform_4f,

	program_uniform_1i,
	program_uniform_2i,
	program_uniform_3i,
	program_uniform_4i,

	program_uniform_1ui,
	program_uniform_2ui,
	program_uniform_3ui,
	program_uniform_4ui,
}

texture_storage_1d :: proc "contextless" (texture: Texture, levels: i32, format: Internal_Format, size: i32) {
	gl.TextureStorage1D(u32(texture), levels, u32(format), size)
}

texture_storage_2d :: proc "contextless" (texture: Texture, levels: i32, format: Internal_Format, width, height: i32) {
	gl.TextureStorage2D(u32(texture), levels, u32(format), width, height)
}

texture_storage_3d :: proc "contextless" (texture: Texture, levels: i32, format: Internal_Format, width, height, depth: i32) {
	gl.TextureStorage3D(u32(texture), levels, u32(format), width, height, depth)
}

// TODO(pJotoro): Should we allow all the crazy formats like GL_UNSIGNED_BYTE_2_3_3_REV here? Or should we just keep the basic ones? 



bind_texture_unit :: proc(unit: u32, texture: Texture, loc := #caller_location) {
	assert(unit >= 0 && unit <= 31, "invalid texture unit", loc)
	gl.BindTextureUnit(unit + gl.TEXTURE0, u32(texture))
}

generate_texture_mipmap :: proc "contextless" (texture: Texture) {
	gl.GenerateTextureMipmap(u32(texture))
}



create_framebuffer :: proc "contextless" () -> Framebuffer {
	framebuffer: u32 = ---
	gl.CreateFramebuffers(1, &framebuffer)
	return Framebuffer(framebuffer)
}

create_framebuffers :: proc(n: i32, allocator := context.allocator, loc := #caller_location) -> []Framebuffer {
	framebuffers := make([]u32, n, allocator, loc)
	gl.CreateFramebuffers(n, raw_data(framebuffers))
	return transmute([]Framebuffer)framebuffers
}

framebuffer_texture :: proc(framebuffer: Framebuffer, attachment: u32, texture: Texture, level: i32, loc := #caller_location) {
	if attachment >= 0 && attachment <= 31 {
		gl.NamedFramebufferTexture(u32(framebuffer), attachment + gl.COLOR_ATTACHMENT0, u32(texture), level)
	} else if attachment == DEPTH || attachment == STENCIL || attachment == DEPTH_STENCIL {
		gl.NamedFramebufferTexture(u32(framebuffer), attachment, u32(texture), level)
	} else {
		panic("invalid attachment", loc)
	}
}

blit_framebuffer :: proc "contextless" (read_framebuffer, draw_framebuffer: Framebuffer, src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1: i32, mask: Clear_Flags, filter: Stretch_Filter) {
	gl.BlitNamedFramebuffer(u32(read_framebuffer), u32(draw_framebuffer), src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1, transmute(u32)mask, u32(filter))
}

clear_framebuffer_color_iv :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: i32) {
	value := [4]i32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color_uiv :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: u32) {
	value := [4]u32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferuiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color_fv :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: f32) {
	value := [4]f32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferfv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color :: proc{clear_framebuffer_color_iv, clear_framebuffer_color_uiv, clear_framebuffer_color_fv}

clear_framebuffer_depth :: proc "contextless" (framebuffer: Framebuffer, value: f32) {
	value := value
	gl.ClearNamedFramebufferfv(u32(framebuffer), gl.DEPTH, 0, &value)
}

clear_framebuffer_stencil :: proc "contextless" (framebuffer: Framebuffer, value: i32) {
	value := value
	gl.ClearNamedFramebufferiv(u32(framebuffer), gl.STENCIL, 0, &value)
}

clear_framebuffer_depth_stencil :: proc "contextless" (framebuffer: Framebuffer, depth: f32, stencil: i32) {
	gl.ClearNamedFramebufferfi(u32(framebuffer), gl.DEPTH_STENCIL, 0, depth, stencil)
}

*/