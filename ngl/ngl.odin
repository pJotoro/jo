// This is a wrapper over postmodern OpenGL - that is, only direct state access is allowed, wherever possible.
// The API is made much easier to use in Odin using slices, explicit procedure overloading, enums, and bit sets.
//
// If you would like to use jo:ngl with jo:app, it is enough to call app.gl_init(4, 6).
package ngl

import gl "vendor:OpenGL"
import "core:mem"
import "core:strings"
import "../misc"

cull_face :: proc "contextless" (mode: Cull_Face_Mode) {
	gl.impl_CullFace(u32(mode))
}

front_face :: proc "contextless" (mode: Front_Face_Direction) {
	gl.impl_FrontFace(u32(mode))
}

hint :: proc "contextless" (target: Hint_Target, mode: Hint_Mode) {
	gl.impl_Hint(u32(target), u32(mode))
}

line_width :: proc "contextless" (width: f32) {
	gl.impl_LineWidth(width)
}

point_size :: proc "contextless" (size: f32) {
	gl.impl_PointSize(size)
}

polygon_mode :: proc "contextless" (mode: Polygon_Mode_Face) {
	gl.impl_PolygonMode(gl.FRONT_AND_BACK, u32(mode))
}

scissor :: proc "contextless" (x, y, width, height: i32) {
	gl.impl_Scissor(x, y, width, height)
}

clear :: proc "contextless" (flags: Clear_Mask) {
	gl.impl_Clear(transmute(u32)flags)
}

clear_color :: proc "contextless" (red, green, blue, alpha: f32) {
	gl.impl_ClearColor(red, green, blue, alpha)
}

clear_stencil :: proc "contextless" (s: i32) {
	gl.impl_ClearStencil(s)
}

clear_depth_f64 :: proc "contextless" (depth: f64) {
	gl.impl_ClearDepth(depth)
}

clear_depth_f32 :: proc "contextless" (depth: f32) {
	gl.impl_ClearDepthf(depth)
}

clear_depth :: proc {
	clear_depth_f64,
	clear_depth_f32,
}

stencil_mask :: proc "contextless" (mask: u32) {
	gl.impl_StencilMask(mask)
}

color_mask_no_i :: proc "contextless" (red, green, blue, alpha: bool) {
	gl.impl_ColorMask(red, green, blue, alpha)
}

color_mask_i :: proc "contextless" (index: u32, r: bool, g: bool, b: bool, a: bool) {
	gl.impl_ColorMaski(index, r, g, b, a)
}

color_mask :: proc {
	color_mask_no_i,
	color_mask_i,
}

depth_mask :: proc "contextless" (flag: bool) {
	gl.impl_DepthMask(flag)
}

disable_no_i :: proc "contextless" (cap: Disable_Target) {
	gl.impl_Disable(u32(cap))
}

disable_i :: proc "contextless" (target: Disable_Target, index: u32) {
	gl.impl_Disablei(u32(target), index)
}

disable :: proc {
	disable_no_i,
	disable_i,
}

enable_no_i :: proc "contextless" (cap: Enable_Target) {
	gl.impl_Enable(u32(cap))
}

enable_i :: proc "contextless" (target: Enable_Target, index: u32) {
	gl.impl_Enablei(u32(target), index)
}

enable :: proc {
	enable_no_i, 
	enable_i,
}

finish :: proc "contextless" () {
	gl.impl_Finish()
}

flush :: proc "contextless" () {
	gl.impl_Flush()
}

blend_func_no_i :: proc "contextless" (sfactor, dfactor: Blend_Function) {
	gl.impl_BlendFunc(u32(sfactor), u32(dfactor))
}

blend_func_i :: proc "contextless" (buf: u32, src, dst: Blend_Function) {
	gl.impl_BlendFunci(buf, u32(src), u32(dst))
}

blend_func :: proc {
	blend_func_no_i,
	blend_func_i,
}

logic_op :: proc "contextless" (opcode: Logical_Operation) {
	gl.impl_LogicOp(u32(opcode))
}

stencil_func :: proc "contextless" (func: Comparison_Func, ref: i32, mask: u32) {
	gl.impl_StencilFunc(u32(func), ref, mask)
}

stencil_op :: proc "contextless" (sfail, dpfail, dppass: Stencil_Operation) {
	gl.impl_StencilOp(u32(sfail), u32(dpfail), u32(dppass))
}

depth_func :: proc "contextless" (func: Comparison_Func) {
	gl.impl_DepthFunc(u32(func))
}

pack_swap_bytes :: proc "contextless" () {
	gl.impl_PixelStorei(gl.PACK_SWAP_BYTES, 1)
}

pack_lsb_first :: proc "contextless" () {
	gl.impl_PixelStorei(gl.PACK_LSB_FIRST, 1)
}

pack_lsb_last :: proc "contextless" () {
	gl.impl_PixelStorei(gl.PACK_LSB_FIRST, 0)
}

pack_row_length :: proc "contextless" (length: i32) {
	gl.impl_PixelStorei(gl.PACK_ROW_LENGTH, length)
}

pack_image_height :: proc "contextless" (image_height: i32) {
	gl.impl_PixelStorei(gl.PACK_IMAGE_HEIGHT, image_height)
}

pack_skip_pixels :: proc "contextless" (pixels: i32) {
	gl.impl_PixelStorei(gl.PACK_SKIP_PIXELS, pixels)
}

pack_skip_rows :: proc "contextless" (rows: i32) {
	gl.impl_PixelStorei(gl.PACK_SKIP_ROWS, rows)
}

pack_skip_images :: proc "contextless" (images: i32) {
	gl.impl_PixelStorei(gl.PACK_SKIP_IMAGES, images)
}

pack_alignment :: proc "contextless" (alignment: i32) {
	gl.impl_PixelStorei(gl.PACK_ALIGNMENT, alignment)
}

unpack_swap_bytes :: proc "contextless" () {
	gl.impl_PixelStorei(gl.UNPACK_SWAP_BYTES, 1)
}

unpack_lsb_first :: proc "contextless" () {
	gl.impl_PixelStorei(gl.UNPACK_LSB_FIRST, 1)
}

unpack_lsb_last :: proc "contextless" () {
	gl.impl_PixelStorei(gl.UNPACK_LSB_FIRST, 0)
}

unpack_row_length :: proc "contextless" (length: i32) {
	gl.impl_PixelStorei(gl.UNPACK_ROW_LENGTH, length)
}

unpack_image_height :: proc "contextless" (image_height: i32) {
	gl.impl_PixelStorei(gl.UNPACK_IMAGE_HEIGHT, image_height)
}

unpack_skip_pixels :: proc "contextless" (pixels: i32) {
	gl.impl_PixelStorei(gl.UNPACK_SKIP_PIXELS, pixels)
}

unpack_skip_rows :: proc "contextless" (rows: i32) {
	gl.impl_PixelStorei(gl.UNPACK_SKIP_ROWS, rows)
}

unpack_skip_images :: proc "contextless" (images: i32) {
	gl.impl_PixelStorei(gl.UNPACK_SKIP_IMAGES, images)
}

unpack_alignment :: proc "contextless" (alignment: i32) {
	gl.impl_PixelStorei(gl.UNPACK_ALIGNMENT, alignment)
}

read_pixels_byte :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []byte) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.UNSIGNED_BYTE, i32(len(buf)), raw_data(buf))
}

read_pixels_i8 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []i8) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.BYTE, i32(len(buf)), raw_data(buf))
}

read_pixels_u16 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []u16) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.UNSIGNED_SHORT, i32(len(buf)), raw_data(buf))
}

read_pixels_i16 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []i16) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.SHORT, i32(len(buf)), raw_data(buf))
}

read_pixels_u32 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []u32) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.UNSIGNED_INT, i32(len(buf)), raw_data(buf))
}

read_pixels_i32 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []i32) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.INT, i32(len(buf)), raw_data(buf))
}

read_pixels_f16 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []f16) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.HALF_FLOAT, i32(len(buf)), raw_data(buf))
}

read_pixels_f32 :: proc "contextless" (x, y, width, height: i32, format: Pixel_Data_Format, buf: []f32) {
	gl.impl_ReadnPixels(x, y, width, height, u32(format), gl.FLOAT, i32(len(buf)), raw_data(buf))
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

get_error :: proc "contextless" () -> Error {
    return Error(gl.impl_GetError())
}

get_string_no_i :: proc "contextless" (name: Get_String_Name) -> string {
	return string(gl.impl_GetString(u32(name)))
}

get_string_i :: proc "contextless" (name: Get_Stringi_Name, index: u32) -> cstring {
	return gl.impl_GetStringi(u32(name), index)
}

get_string :: proc {
	get_string_no_i,
	get_string_i,
}

is_enabled_no_i :: proc "contextless" (cap: Is_Enabled_Cap) -> bool {
	return gl.impl_IsEnabled(u32(cap))
}

is_enabled :: proc {
	is_enabled_no_i,
	is_enabled_i,
}

depth_range_f64 :: proc "contextless" (near, far: f64) {
	gl.impl_DepthRange(near, far)
}

depth_range_f32 :: proc "contextless" (near, far: f32) {
	gl.impl_DepthRangef(near, far)
}

depth_range :: proc {
	depth_range_f64,
	depth_range_f32,
}

viewport :: proc "contextless" (x, y, width, height: i32) {
	gl.impl_Viewport(x, y, width, height)
}

polygon_offset :: proc "contextless" (factor, units: f32) {
	gl.impl_PolygonOffset(factor, units)
}

sample_coverage :: proc "contextless" (value: f32, invert: bool) {
	gl.impl_SampleCoverage(value, invert)
}

blend_func_separate_no_i :: proc "contextless" (s_factor_rgb, d_factor_rgb, s_factor_alpha, d_factor_alpha: Blend_Function) {
	gl.impl_BlendFuncSeparate(u32(s_factor_rgb), u32(d_factor_rgb), u32(s_factor_alpha), u32(d_factor_alpha))
}

blend_func_separate_i :: proc "contextless" (buf: u32, s_factor_rgb, d_factor_rgb, s_factor_alpha, d_factor_alpha: Blend_Function) {
	gl.impl_BlendFuncSeparate(u32(s_factor_rgb), u32(d_factor_rgb), u32(s_factor_alpha), u32(d_factor_alpha))
}

blend_func_separate :: proc {
	blend_func_separate_no_i,
	blend_func_separate_i,
}

point_fade_threshold_size :: proc "contextless" (value: f32) {
	gl.impl_PointParameterf(gl.POINT_FADE_THRESHOLD_SIZE, value)
}

Point_Sprite_Coord_Origin :: enum i32 {
	Lower_Left = gl.LOWER_LEFT,
	Upper_Left = gl.UPPER_LEFT,
}

point_sprite_coord_origin :: proc "contextless" (value: Point_Sprite_Coord_Origin) {
	gl.impl_PointParameteri(gl.POINT_SPRITE_COORD_ORIGIN, i32(value))
}

blend_color :: proc "contextless" (red, green, blue, alpha: f32) {
	gl.impl_BlendColor(red, green, blue, alpha)
}

blend_equation_no_i :: proc "contextless" (mode: Blend_Mode) {
	gl.impl_BlendEquation(u32(mode))
}

blend_equation_i :: proc "contextless" (buf: u32, mode: Blend_Mode) {
	gl.impl_BlendEquationi(buf, u32(mode))
}

blend_equation :: proc {
	blend_equation_no_i,
	blend_equation_i,
}

blend_equation_separate_no_i :: proc "contextless" (mode_rgb, mode_alpha: Blend_Mode) {
	gl.impl_BlendEquationSeparate(u32(mode_rgb), u32(mode_alpha))
}

blend_equation_separate_i :: proc "contextless" (buf: u32, mode_rgb, mode_alpha: Blend_Mode) {
	gl.impl_BlendEquationSeparatei(buf, u32(mode_rgb), u32(mode_alpha))
}

blend_equation_separate :: proc {
	blend_equation_no_i,
	blend_equation_i,
}

stencil_op_separate :: proc "contextless" (face: Stencil_Face, sfail, dpfail, dppass: Stencil_Operation) {
	gl.impl_StencilOpSeparate(u32(face), u32(sfail), u32(dpfail), u32(dppass))
}

stencil_func_separate :: proc "contextless" (face: Stencil_Face, func: Comparison_Func, ref: i32, mask: u32) {
	gl.impl_StencilFuncSeparate(u32(face), u32(func), ref, mask)
}

stencil_mask_separate :: proc "contextless" (face: Stencil_Face, mask: u32) {
	gl.impl_StencilMaskSeparate(u32(face), mask)
}

is_enabled_i :: proc "contextless" (target: Is_Enabledi_Target, index: u32) {
	gl.impl_IsEnabledi(u32(target), index)
}

begin_transform_feedback :: proc "contextless" (primitive_mode: Transform_Feedback_Primitive_Mode) {
	gl.impl_BeginTransformFeedback(u32(primitive_mode))
}

end_transform_feedback :: proc "contextless" () {
	gl.impl_EndTransformFeedback()
}

transform_feedback_varyings :: proc "contextless" (program: Program, varyings: []cstring, buffer_mode: Transform_Feedback_Buffer_Mode) {
	gl.impl_TransformFeedbackVaryings(u32(program), i32(len(varyings)), raw_data(varyings), u32(buffer_mode))
}

clamp_color :: proc "contextless" (clamp: bool) {
	gl.impl_ClampColor(gl.CLAMP_READ_COLOR, u32(clamp))
}

begin_conditional_render :: proc "contextless" (id: Query, mode: Conditional_Render_Mode) {
	gl.impl_BeginConditionalRender(u32(id), u32(mode))
}

end_conditional_render :: proc "contextless" () {
	gl.impl_EndConditionalRender()
}

primitive_restart_index :: proc "contextless" (index: u32) {
	gl.impl_PrimitiveRestartIndex(index)
}

provoking_vertex :: proc "contextless" (mode: Provoking_Vertex_Mode) {
	gl.impl_ProvokingVertex(u32(mode))
}

sample_mask :: proc "contextless" (mask_number, mask: u32) {
	gl.impl_SampleMaski(mask_number, mask)
}

min_sample_shading :: proc "contextless" (value: f32) {
	gl.impl_MinSampleShading(value)
}

delete_transform_feedbacks :: proc "contextless" (transform_feedbacks: []Transform_Feedback) {
	gl.impl_DeleteTransformFeedbacks(i32(len(transform_feedbacks)), ([^]u32)(raw_data(transform_feedbacks)))
}

gen_transform_feedbacks :: proc "contextless" (transform_feedbacks: []Transform_Feedback) {
	gl.impl_CreateTransformFeedbacks(i32(len(transform_feedbacks)), ([^]u32)(raw_data(transform_feedbacks)))
}

is_transform_feedback :: proc "contextless" (transform_feedback: u32) -> bool {
	return gl.impl_IsTransformFeedback(transform_feedback)
}

get_aliased_line_width_range :: proc "contextless" () -> (lo, hi: i32) {
	arr: [2]i32 = ---
	gl.impl_GetIntegerv(gl.ALIASED_LINE_WIDTH_RANGE, raw_data(&arr))
	lo = arr[0]
	hi = arr[1]
	return
}

get_blend_enabled :: proc "contextless" () -> (res: bool) {
    gl.impl_GetBooleanv(gl.BLEND, &res)
    return
}

get_blend_color :: proc "contextless" () -> (r, g, b, a: f32) {
    arr: [4]f32 = ---
    gl.impl_GetFloatv(gl.BLEND_COLOR, raw_data(&arr))
    r = arr[0]
    g = arr[1]
    b = arr[2]
    a = arr[3]
    return
}