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

tex_image_1d_byte :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []byte) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_1d_i8 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []i8) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_1d_u16 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []u16) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_1d_i16 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []i16) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_1d_u32 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []u32) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_1d_i32 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []i32) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.INT, raw_data(pixels))
}

tex_image_1d_f16 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []f16) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_1d_f32 :: proc "contextless" (tex: Tex, level, offset: i32, format: Pixel_Data_Format, pixels: []f32) {
	gl.TextureSubImage1D(u32(tex), level, offset, i32(len(pixels)), u32(format), gl.FLOAT, raw_data(pixels))
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

tex_image_2d_byte :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []byte, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_2d_i8 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []i8, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_2d_u16 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []u16, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_2d_i16 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []i16, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_2d_u32 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []u32, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_2d_i32 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []i32, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.INT, raw_data(pixels))
}

tex_image_2d_f16 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []f16, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_2d_f32 :: proc(tex: Tex, level, xoffset, yoffset, width, height: i32, format: Pixel_Data_Format, pixels: []f32, loc := #caller_location) {
	assert(int(width) * int(height) == len(pixels), "width * height != len(pixels)", loc)
	gl.TextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), gl.FLOAT, raw_data(pixels))
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

color_mask_no_i :: proc "contextless" (red, green, blue, alpha: bool) {
	gl.ColorMask(red, green, blue, alpha)
}

color_mask_i :: proc "contextless" (index: u32, r: bool, g: bool, b: bool, a: bool) {
	gl.ColorMaski(index, r, g, b, a)
}

color_mask :: proc {
	color_mask_no_i,
	color_mask_i,
}

depth_mask :: proc "contextless" (flag: bool) {
	gl.DepthMask(flag)
}

disable_no_i :: proc "contextless" (cap: Disable_Target) {
	gl.Disable(u32(cap))
}

disable_i :: proc "contextless" (target: Disable_Target, index: u32) {
	gl.Disablei(u32(target), index)
}

disable :: proc {
	disable_no_i,
	disable_i,
}

enable_no_i :: proc "contextless" (cap: Enable_Target) {
	gl.Enable(u32(cap))
}

enable_i :: proc "contextless" (target: Enable_Target, index: u32) {
	gl.Enablei(u32(target), index)
}

enable :: proc {
	enable_no_i, 
	enable_i,
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

get_string_no_i :: proc "contextless" (name: Get_String_Name) -> string {
	return string(gl.GetString(u32(name)))
}

get_string_i :: proc "contextless" (name: Get_Stringi_Name, index: u32) -> cstring {
	return gl.GetStringi(u32(name), index)
}

get_string :: proc {
	get_string_no_i,
	get_string_i,
}

get_tex_image_byte :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []byte) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.UNSIGNED_BYTE, i32(len(buf)), raw_data(buf))
}

get_tex_image_i8 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []i8) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.BYTE, i32(len(buf)), raw_data(buf))
}

get_tex_image_u16 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []u16) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.UNSIGNED_SHORT, i32(len(buf)), raw_data(buf))
}

get_tex_image_i16 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []i16) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.SHORT, i32(len(buf)), raw_data(buf))
}

get_tex_image_u32 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []u32) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.UNSIGNED_INT, i32(len(buf)), raw_data(buf))
}

get_tex_image_i32 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []i32) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.INT, i32(len(buf)), raw_data(buf))
}

get_tex_image_f16 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []f16) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.HALF_FLOAT, i32(len(buf)), raw_data(buf))
}

get_tex_image_f32 :: proc "contextless" (tex: Tex, level: i32, format: Pixel_Data_Format, buf: []f32) {
	gl.GetTextureImage(u32(tex), level, u32(format), gl.FLOAT, i32(len(buf)), raw_data(buf))
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

is_enabled_no_i :: proc "contextless" (cap: Is_Enabled_Cap) -> bool {
	return gl.IsEnabled(u32(cap))
}

is_enabled :: proc {
	is_enabled_no_i,
	is_enabled_i,
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

copy_tex_image_1d :: proc "contextless" (tex: Tex, level, xoffset, x, y, width: i32) {
	gl.CopyTextureSubImage1D(u32(tex), level, xoffset, x, y, width)
}

copy_tex_image_2d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, x, y, width, height: i32) {
	gl.CopyTextureSubImage2D(u32(tex), level, xoffset, yoffset, x, y, width, height)
}

delete_textures :: proc "contextless" (textures: []Tex) {
	gl.DeleteTextures(i32(len(textures)), (^u32)(raw_data(textures)))
}

gen_textures :: proc "contextless" (target: Texture_Target, textures: []Tex) {
	gl.CreateTextures(u32(target), i32(len(textures)), (^u32)(raw_data(textures)))
}

is_texture :: proc "contextless" (maybe_texture: u32) -> bool {
	return gl.IsTexture(maybe_texture)
}


// VERSION_1_2

// draw_range_elements - see draw_elements, and slices.

tex_image_3d_byte :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []byte, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_BYTE, raw_data(pixels))
}

tex_image_3d_i8 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i8, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.BYTE, raw_data(pixels))
}

tex_image_3d_u16 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []u16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_SHORT, raw_data(pixels))
}

tex_image_3d_i16 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.SHORT, raw_data(pixels))
}

tex_image_3d_u32 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []u32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.UNSIGNED_INT, raw_data(pixels))
}

tex_image_3d_i32 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []i32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.INT, raw_data(pixels))
}

tex_image_3d_f16 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []f16, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.HALF_FLOAT, raw_data(pixels))
}

tex_image_3d_f32 :: proc(tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Pixel_Data_Format, pixels: []f32, loc := #caller_location) {
	assert(int(width) * int(height) * int(depth) == len(pixels), "width * height * depth != len(pixels)", loc)
	gl.TextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), gl.FLOAT, raw_data(pixels))
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
	gl.CopyTextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, x, y, width, height)
}


// VERSION_1_3

active_texture :: proc "contextless" (unit: u32, tex: Tex) {
	gl.BindTextureUnit(unit, u32(tex))
}

sample_coverage :: proc "contextless" (value: f32, invert: bool) {
	gl.SampleCoverage(value, invert)
}

compressed_tex_image_1d :: proc "contextless" (tex: Tex, level, xoffset, width: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.CompressedTextureSubImage1D(u32(tex), level, xoffset, width, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

compressed_tex_image_2d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, width, height: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.CompressedTextureSubImage2D(u32(tex), level, xoffset, yoffset, width, height, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

compressed_tex_image_3d :: proc "contextless" (tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Texture_Internalformat, compressed_image: []byte) {
	gl.CompressedTextureSubImage3D(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, u32(format), i32(len(compressed_image)), raw_data(compressed_image))
}

get_compressed_tex_image :: proc "contextless" (tex: Tex, level, xoffset, yoffset, zoffset, width, height, depth: i32, compressed_image: []byte) {
	gl.GetCompressedTextureSubImage(u32(tex), level, xoffset, yoffset, zoffset, width, height, depth, i32(len(compressed_image)), raw_data(compressed_image))
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
	gl.CreateBuffers(i32(len(buffers)), ([^]u32)(raw_data(buffers)))
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

blend_equation_separate :: proc "contextless" (mode_rgb, mode_alpha: Blend_Mode) {
	gl.BlendEquationSeparate(u32(mode_rgb), u32(mode_alpha))
}

draw_buffers :: proc "contextless" (framebuffer: Framebuffer, bufs: []Draw_Buffers) {
	gl.NamedFramebufferDrawBuffers(u32(framebuffer), i32(len(bufs)), ([^]u32)(raw_data(bufs)))
}

stencil_op_separate :: proc "contextless" (face: Stencil_Face, sfail, dpfail, dppass: Stencil_Operation) {
	gl.StencilOpSeparate(u32(face), u32(sfail), u32(dpfail), u32(dppass))
}

stencil_func_separate :: proc "contextless" (face: Stencil_Face, func: Comparison_Func, ref: i32, mask: u32) {
	gl.StencilFuncSeparate(u32(face), u32(func), ref, mask)
}

stencil_mask_separate :: proc "contextless" (face: Stencil_Face, mask: u32) {
	gl.StencilMaskSeparate(u32(face), mask)
}

attach_shader :: proc "contextless" (program: Program, shader: Shader) {
	gl.AttachShader(u32(program), u32(shader))
}

bind_attrib_location :: proc(program: Program, index: u32, name: string) {
	name := strings.clone_to_cstring(name)
	gl.BindAttribLocation(u32(program), index, name)
}

compile_shaders :: proc "contextless" (shaders: []Shader, binary: []byte) {
	gl.ShaderBinary(i32(len(shaders)), ([^]u32)(raw_data(shaders)), gl.SHADER_BINARY_FORMAT_SPIR_V, raw_data(binary), i32(len(binary)))
}

create_program :: proc "contextless" () -> Program {
	return Program(gl.CreateProgram())
}

create_shader :: proc "contextless" (type: Shader_Type) -> Shader {
	return Shader(gl.CreateShader(u32(type)))
}

delete_program :: proc "contextless" (program: Program) {
	gl.DeleteProgram(u32(program))
}

delete_shader :: proc "contextless" (shader: Shader) {
	gl.DeleteShader(u32(shader))
}

detach_shader :: proc "contextless" (program: Program, shader: Shader) {
	gl.DetachShader(u32(program), u32(shader))
}

disable_vertex_attrib_array :: proc "contextless" (vertex_array: Vertex_Array, index: u32) {
	gl.DisableVertexArrayAttrib(u32(vertex_array), index)
}

enable_vertex_attrib_array :: proc "contextless" (vertex_array: Vertex_Array, index: u32) {
	gl.EnableVertexArrayAttrib(u32(vertex_array), index)
}

// TODO(pJotoro): Do some testing to find out if this procedure get return
// the length of the string without anything else.
// get_active_attrib :: proc "contextless" (program: Program, index: u32) -> (size: i32, type: Attribute_Type, name: string) {
// 	length: i32 = ---
// 	gl.GetActiveAttrib(u32(program), index, 0, &length, &size, (^u32)(&type), nil)

// 	//name = transmute(string)mem.Raw_String{raw_data(&buf), int(length)}
// 	return
// }

// ...

is_program :: proc "contextless" (program: u32) -> bool {
	return gl.IsProgram(program)
}

is_shader :: proc "contextless" (shader: u32) -> bool {
	return gl.IsShader(shader)
}

link_program :: proc "contextless" (program: Program) {
	gl.LinkProgram(u32(program))
}

// shader_source - see compile_shaders

use_program :: proc "contextless" (program: Program) {
	gl.UseProgram(u32(program))
}

uniform_1_f32 :: proc "contextless" (program: Program, location: i32, v0: f32) {
	gl.ProgramUniform1f(u32(program), location, v0)
}

uniform_2_f32 :: proc "contextless" (program: Program, location: i32, v0, v1: f32) {
	gl.ProgramUniform2f(u32(program), location, v0, v1)
}

uniform_3_f32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2: f32) {
	gl.ProgramUniform3f(u32(program), location, v0, v1, v2)
}

uniform_4_f32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: f32) {
	gl.ProgramUniform4f(u32(program), location, v0, v1, v2, v3)
}

uniform_1_i32 :: proc "contextless" (program: Program, location: i32, v0: i32) {
	gl.ProgramUniform1i(u32(program), location, v0)
}

uniform_2_i32 :: proc "contextless" (program: Program, location: i32, v0, v1: i32) {
	gl.ProgramUniform2i(u32(program), location, v0, v1)
}

uniform_3_i32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2: i32) {
	gl.ProgramUniform3i(u32(program), location, v0, v1, v2)
}

uniform_4_i32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: i32) {
	gl.ProgramUniform4i(u32(program), location, v0, v1, v2, v3)
}

uniform_matrix_2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 2]f32) {
	value := value
	gl.ProgramUniformMatrix2fv(u32(program), location, 2*2, transpose, raw_data(&value))
}

uniform_matrix_3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 3]f32) {
	value := value
	gl.ProgramUniformMatrix3fv(u32(program), location, 3*3, transpose, raw_data(&value))
}

uniform_matrix_4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 4]f32) {
	value := value
	gl.ProgramUniformMatrix4fv(u32(program), location, 4*4, transpose, raw_data(&value))
}

uniform_matrix_2x3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 3]f32) {
	value := value
	gl.ProgramUniformMatrix3x2fv(u32(program), location, 2*3, transpose, raw_data(&value))
}

uniform_matrix_3x2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 2]f32) {
	value := value
	gl.ProgramUniformMatrix2x3fv(u32(program), location, 3*2, transpose, raw_data(&value))
}

uniform_matrix_2x4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 4]f32) {
	value := value
	gl.ProgramUniformMatrix4x2fv(u32(program), location, 2*4, transpose, raw_data(&value))
}

uniform_matrix_4x2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 2]f32) {
	value := value
	gl.ProgramUniformMatrix2x4fv(u32(program), location, 4*2, transpose, raw_data(&value))
}

uniform_matrix_3x4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 4]f32) {
	value := value
	gl.ProgramUniformMatrix4x3fv(u32(program), location, 3*4, transpose, raw_data(&value))
}

uniform_matrix_4x3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 3]f32) {
	value := value
	gl.ProgramUniformMatrix3x4fv(u32(program), location, 4*3, transpose, raw_data(&value))
}

uniform :: proc {
	uniform_1_f32,
	uniform_2_f32,
	uniform_3_f32,
	uniform_4_f32,
	uniform_1_i32,
	uniform_2_i32,
	uniform_3_i32,
	uniform_4_i32,
	uniform_matrix_2_f32,
	uniform_matrix_3_f32,
	uniform_matrix_4_f32,
	uniform_matrix_2x3_f32,
	uniform_matrix_3x2_f32,
	uniform_matrix_2x4_f32,
	uniform_matrix_4x2_f32,
	uniform_matrix_3x4_f32,
	uniform_matrix_4x3_f32,
}

validate_program :: proc "contextless" (program: Program) {
	gl.ValidateProgram(u32(program))
}

// No vertex_attrib_pointer. Must use vertex_attrib_binding + vertex_attrib_format.

vertex_attrib_binding :: proc "contextless" (vertex_array: Vertex_Array, attrib_index, binding_index: u32) {
	gl.VertexArrayAttribBinding(u32(vertex_array), attrib_index, binding_index)
}

vertex_attrib_format :: proc "contextless" (vertex_array: Vertex_Array, attrib_index: u32, size: i32, type: Attribute_Type, normalized: bool, relative_offset: u32) {
	gl.VertexArrayAttribFormat(u32(vertex_array), attrib_index, size, u32(type), normalized, relative_offset)
}


// VERSION_2_1

// Nothing to see here...


// VERSION_3_0

// get_booleani_v, get_integeri_v - see get.odin

is_enabled_i :: proc "contextless" (target: Is_Enabledi_Target, index: u32) {
	gl.IsEnabledi(u32(target), index)
}

begin_transform_feedback :: proc "contextless" (primitive_mode: Transform_Feedback_Primitive_Mode) {
	gl.BeginTransformFeedback(u32(primitive_mode))
}

end_transform_feedback :: proc "contextless" () {
	gl.EndTransformFeedback()
}

transform_feedback_varyings_cstring :: proc "contextless" (program: Program, varyings: []cstring, buffer_mode: Transform_Feedback_Buffer_Mode) {
	gl.TransformFeedbackVaryings(u32(program), i32(len(varyings)), raw_data(varyings), u32(buffer_mode))
}

transform_feedback_varyings_string :: proc(program: Program, varyings: []string, buffer_mode: Transform_Feedback_Buffer_Mode) -> mem.Allocator_Error {
	varyings_cstring := make([]cstring, len(varyings), context.temp_allocator) or_return
	for _, i in varyings_cstring {
		varyings_cstring[i] = strings.clone_to_cstring(varyings[i], context.temp_allocator) or_return
	}
	transform_feedback_varyings_cstring(program, varyings_cstring, buffer_mode)
	return .None
}

transform_feedback_varyings :: proc {
	transform_feedback_varyings_cstring,
	transform_feedback_varyings_string,
}

// ...

clamp_color :: proc "contextless" (clamp: bool) {
	gl.ClampColor(gl.CLAMP_READ_COLOR, u32(clamp))
}

begin_conditional_render :: proc "contextless" (id: Query, mode: Conditional_Render_Mode) {
	gl.BeginConditionalRender(u32(id), u32(mode))
}

end_conditional_render :: proc "contextless" () {
	gl.EndConditionalRender()
}

get_uniform_uiv :: proc "contextless" (program: Program, location: i32) -> (param: u32) {
	gl.GetnUniformuiv(u32(program), location, 1, &param)
	return
}

getn_uniform_uiv :: proc "contextless" (program: Program, location: i32, params: []u32) {
	gl.GetnUniformuiv(u32(program), location, i32(len(params)), raw_data(params))
	return
}

get_uniform :: proc {
	get_uniform_uiv,
	getn_uniform_uiv,
}

bind_frag_data_location :: proc "contextless" (program: Program, color: u32, name: cstring) {
	gl.BindFragDataLocation(u32(program), color, name)
}

get_frag_data_location :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.GetFragDataLocation(u32(program), name)
}

// no clear_buffer - use clear_framebuffer_color, clear_framebuffer_depth, clear_framebuffer_stencil, or clear_framebuffer_depth_stencil

clear_framebuffer_iv_color :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: i32) {
	value := [4]i32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_uiv_color :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: u32) {
	value := [4]u32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferuiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_fv_color :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: f32) {
	value := [4]f32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferfv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color :: proc {
	clear_framebuffer_iv_color, 
	clear_framebuffer_uiv_color, 
	clear_framebuffer_fv_color,
}

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

is_renderbuffer :: proc "contextless" (renderbuffer: u32) -> bool {
	return gl.IsRenderbuffer(renderbuffer)
}

delete_renderbuffers :: proc "contextless" (renderbuffers: []Renderbuffer) {
	gl.DeleteRenderbuffers(i32(len(renderbuffers)), ([^]u32)(raw_data(renderbuffers)))
}

gen_renderbuffers :: proc "contextless" (renderbuffers: []Renderbuffer) {
	gl.CreateRenderbuffers(i32(len(renderbuffers)), ([^]u32)(raw_data(renderbuffers)))
}

renderbuffer_storage :: proc "contextless" (renderbuffer: Renderbuffer, internal_format: Color_Depth_Stencil_Renderable_Format, width, height: i32) {
	gl.NamedRenderbufferStorage(u32(renderbuffer), u32(internal_format), width, height)
}

// get_renderbuffer_parameter - see renderbuffer_parameter.odin (TODO)

is_framebuffer :: proc "contextless" (framebuffer: u32) -> bool {
	return gl.IsFramebuffer(framebuffer)
}

delete_framebuffers :: proc "contextless" (framebuffers: []Framebuffer) {
	gl.DeleteFramebuffers(i32(len(framebuffers)), ([^]u32)(raw_data(framebuffers)))
}

gen_framebuffers :: proc "contextless" (framebuffers: []Framebuffer) {
	gl.CreateFramebuffers(i32(len(framebuffers)), ([^]u32)(raw_data(framebuffers)))
}

check_framebuffer_status :: proc "contextless" (framebuffer: Framebuffer, target: Framebuffer_Target) -> Framebuffer_Status {
	return Framebuffer_Status(gl.CheckNamedFramebufferStatus(u32(framebuffer), u32(target)))
}

// no framebuffer_texture_1d, framebuffer_texture_2d, or framebuffer_texture_3d, only framebuffer_texture

framebuffer_texture :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Renderbuffer_Attachment, tex: Tex, level: i32) {
	gl.NamedFramebufferTexture(u32(framebuffer), u32(attachment), u32(tex), level)
}

framebuffer_renderbuffer :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Renderbuffer_Attachment, renderbuffer: Renderbuffer) {
	gl.NamedFramebufferRenderbuffer(u32(framebuffer), u32(attachment), gl.RENDERBUFFER, u32(renderbuffer))
}

// get_framebuffer_attachment_parameter - see framebuffer_parameter.odin (TODO)

generate_mipmap :: proc "contextless" (tex: Tex) {
	gl.GenerateTextureMipmap(u32(tex))
}

blit_framebuffer :: proc "contextless" (read_framebuffer, draw_framebuffer: Framebuffer, src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1: i32, mask: Blit_Mask, filter: Blit_Framebuffer_Filter) {
	gl.BlitNamedFramebuffer(u32(read_framebuffer), u32(draw_framebuffer), src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1, transmute(u32)mask, u32(filter))
}

renderbuffer_storage_multisample :: proc "contextless" (renderbuffer: Renderbuffer, samples: i32, internal_format: Color_Depth_Stencil_Renderable_Format, width, height: i32) {
	gl.NamedRenderbufferStorageMultisample(u32(renderbuffer), samples, u32(internal_format), width, height)
}

framebuffer_texture_layer :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Renderbuffer_Attachment, tex: Tex, level, layer: i32) {
	gl.NamedFramebufferTextureLayer(u32(framebuffer), u32(attachment), u32(tex), level, layer)
}

flush_mapped_buffer_range :: proc "contextless" (buffer: Buffer, offset, length: int) {
	gl.FlushMappedNamedBufferRange(u32(buffer), offset, length)
}

bind_vertex_array :: proc "contextless" (vertex_array: Vertex_Array) {
	gl.BindVertexArray(u32(vertex_array))
}

delete_vertex_arrays :: proc "contextless" (vertex_arrays: []Vertex_Array) {
	gl.DeleteVertexArrays(i32(len(vertex_arrays)), ([^]u32)(raw_data(vertex_arrays)))
}

gen_vertex_arrays :: proc "contextless" (vertex_arrays: []Vertex_Array) {
	gl.CreateVertexArrays(i32(len(vertex_arrays)), ([^]u32)(raw_data(vertex_arrays)))
}

is_vertex_array :: proc "contextless" (vertex_array: u32) -> bool {
	return gl.IsVertexArray(u32(vertex_array))
}


// VERSION_3_1

draw_arrays_instanced :: proc "contextless" (mode: Draw_Mode, first: i32, count: i32, instance_count: i32) {
	gl.DrawArraysInstanced(u32(mode), first, count, instance_count)
}

draw_elements_instanced_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte, instance_count: i32) {
	gl.DrawElementsInstanced(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), instance_count)
}

draw_elements_instanced_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16, instance_count: i32) {
	gl.DrawElementsInstanced(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), instance_count)
}

draw_elements_instanced_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32, instance_count: i32) {
	gl.DrawElementsInstanced(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), instance_count)
}

draw_elements_instanced :: proc{draw_elements_instanced_byte, draw_elements_instanced_u16, draw_elements_instanced_u32}

tex_buffer :: proc "contextless" (tex: Tex, internal_format: Tex_Buffer_Internalformat, buffer: Buffer) {
	gl.TextureBuffer(u32(tex), u32(internal_format), u32(buffer))
}

primitive_restart_index :: proc "contextless" (index: u32) {
	gl.PrimitiveRestartIndex(index)
}

copy_buffer_sub_data :: proc "contextless" (read_buffer, write_buffer: Buffer, read_offset, write_offset, size: int) {
	gl.CopyNamedBufferSubData(u32(read_buffer), u32(write_buffer), read_offset, write_offset, size)
}

get_uniform_indices :: proc "contextless" (program: Program, uniform_names: []cstring, uniform_indices: []u32) {
	gl.GetUniformIndices(u32(program), i32(min(len(uniform_names), len(uniform_indices))), raw_data(uniform_names), raw_data(uniform_indices))
}

// ...

uniform_block_binding :: proc "contextless" (program: Program, uniform_block_index, uniform_block_binding: u32) {
	gl.UniformBlockBinding(u32(program), uniform_block_index, uniform_block_binding)
}

/*

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

*/