package ngl

import gl "vendor:OpenGL"

framebuffer_texture_layer :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Renderbuffer_Attachment, tex: Tex, level, layer: i32) {
	gl.impl_NamedFramebufferTextureLayer(u32(framebuffer), u32(attachment), u32(tex), level, layer)
}

delete_framebuffers :: proc "contextless" (framebuffers: []Framebuffer) {
	gl.impl_DeleteFramebuffers(i32(len(framebuffers)), ([^]u32)(raw_data(framebuffers)))
}

gen_framebuffers :: proc "contextless" (framebuffers: []Framebuffer) {
	gl.impl_CreateFramebuffers(i32(len(framebuffers)), ([^]u32)(raw_data(framebuffers)))
}

draw_framebuffer :: proc "contextless" (framebuffer: Framebuffer, buf: Draw_Buffer) {
	gl.impl_NamedFramebufferDrawBuffer(u32(framebuffer), u32(buf))
}

draw_framebuffers :: proc "contextless" (framebuffer: Framebuffer, bufs: []Draw_Buffers) {
	gl.impl_NamedFramebufferDrawBuffers(u32(framebuffer), i32(len(bufs)), ([^]u32)(raw_data(bufs)))
}

read_framebuffer :: proc "contextless" (framebuffer: Framebuffer, src: Draw_Buffer) {
	gl.impl_NamedFramebufferReadBuffer(u32(framebuffer), u32(src))
}

// no clear_buffer - use clear_framebuffer_color, clear_framebuffer_depth, clear_framebuffer_stencil, or clear_framebuffer_depth_stencil

clear_framebuffer_iv_color :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: i32) {
	value := [4]i32{v0, v1, v2, v3}
	gl.impl_ClearNamedFramebufferiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_uiv_color :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: u32) {
	value := [4]u32{v0, v1, v2, v3}
	gl.impl_ClearNamedFramebufferuiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_fv_color :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: f32) {
	value := [4]f32{v0, v1, v2, v3}
	gl.impl_ClearNamedFramebufferfv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color :: proc {
	clear_framebuffer_iv_color, 
	clear_framebuffer_uiv_color, 
	clear_framebuffer_fv_color,
}

clear_framebuffer_depth :: proc "contextless" (framebuffer: Framebuffer, value: f32) {
	value := value
	gl.impl_ClearNamedFramebufferfv(u32(framebuffer), gl.DEPTH, 0, &value)
}

clear_framebuffer_stencil :: proc "contextless" (framebuffer: Framebuffer, value: i32) {
	value := value
	gl.impl_ClearNamedFramebufferiv(u32(framebuffer), gl.STENCIL, 0, &value)
}

clear_framebuffer_depth_stencil :: proc "contextless" (framebuffer: Framebuffer, depth: f32, stencil: i32) {
	gl.impl_ClearNamedFramebufferfi(u32(framebuffer), gl.DEPTH_STENCIL, 0, depth, stencil)
}

is_framebuffer :: proc "contextless" (framebuffer: u32) -> bool {
	return gl.impl_IsFramebuffer(framebuffer)
}

// no framebuffer_texture_1d, framebuffer_texture_2d, or framebuffer_texture_3d, only framebuffer_texture

framebuffer_texture :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Renderbuffer_Attachment, tex: Tex, level: i32) {
	gl.impl_NamedFramebufferTexture(u32(framebuffer), u32(attachment), u32(tex), level)
}

framebuffer_renderbuffer :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Renderbuffer_Attachment, renderbuffer: Renderbuffer) {
	gl.impl_NamedFramebufferRenderbuffer(u32(framebuffer), u32(attachment), gl.RENDERBUFFER, u32(renderbuffer))
}

check_framebuffer_status :: proc "contextless" (framebuffer: Framebuffer, target: Framebuffer_Target) -> Framebuffer_Status {
	return Framebuffer_Status(gl.impl_CheckNamedFramebufferStatus(u32(framebuffer), u32(target)))
}

blit_framebuffer :: proc "contextless" (read_framebuffer, draw_framebuffer: Framebuffer, src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1: i32, mask: Blit_Mask, filter: Blit_Framebuffer_Filter) {
	gl.impl_BlitNamedFramebuffer(u32(read_framebuffer), u32(draw_framebuffer), src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1, transmute(u32)mask, u32(filter))
}

Framebuffer_Attachment_Object_Type :: enum i32 {
    None = gl.NONE,
    Framebuffer_Default = gl.FRAMEBUFFER_DEFAULT,
    Texture = gl.TEXTURE,
    Renderbuffer = gl.RENDERBUFFER,
}

get_framebuffer_attachment_object_type :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (type: Framebuffer_Attachment_Object_Type) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, (^i32)(&type))
    return
}

get_framebuffer_attachment_red_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_RED_SIZE, &size)
    return
}

get_framebuffer_attachment_green_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_GREEN_SIZE, &size)
    return
}

get_framebuffer_attachment_blue_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_BLUE_SIZE, &size)
    return
}

get_framebuffer_attachment_alpha_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE, &size)
    return
}

get_framebuffer_attachment_depth_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE, &size)
    return
}

get_framebuffer_attachment_stencil_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE, &size)
    return
}

Framebuffer_Attachment_Component_Type :: enum i32 {
    Float = gl.FLOAT,
    Int = gl.INT,
    Unsigned_Int = gl.UNSIGNED_INT,
    Signed_Normalized = gl.SIGNED_NORMALIZED,
    Unsigned_Normalized = gl.UNSIGNED_NORMALIZED,
}

get_framebuffer_attachment_component_type :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (type: Framebuffer_Attachment_Component_Type) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE, (^i32)(&type))
    return
}

Framebuffer_Attachment_Color_Encoding :: enum i32 {
    Linear = gl.LINEAR,
    SRGB = gl.SRGB,
}

get_framebuffer_attachment_color_encoding :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (encoding: Framebuffer_Attachment_Color_Encoding) {
    gl.impl_GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING, (^i32)(&encoding))
    return
}