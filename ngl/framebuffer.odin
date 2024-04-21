package ngl

import gl "vendor:OpenGL"

Framebuffer_Attachment_Object_Type :: enum i32 {
    None = gl.NONE,
    Framebuffer_Default = gl.FRAMEBUFFER_DEFAULT,
    Texture = gl.TEXTURE,
    Renderbuffer = gl.RENDERBUFFER,
}

get_framebuffer_attachment_object_type :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (type: Framebuffer_Attachment_Object_Type) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, (^i32)(&type))
    return
}

get_framebuffer_attachment_red_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_RED_SIZE, &size)
    return
}

get_framebuffer_attachment_green_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_GREEN_SIZE, &size)
    return
}

get_framebuffer_attachment_blue_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_BLUE_SIZE, &size)
    return
}

get_framebuffer_attachment_alpha_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE, &size)
    return
}

get_framebuffer_attachment_depth_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE, &size)
    return
}

get_framebuffer_attachment_stencil_size :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (size: i32) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE, &size)
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
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE, (^i32)(&type))
    return
}

Framebuffer_Attachment_Color_Encoding :: enum i32 {
    Linear = gl.LINEAR,
    SRGB = gl.SRGB,
}

get_framebuffer_attachment_color_encoding :: proc "contextless" (framebuffer: Framebuffer, attachment: Framebuffer_Attachment) -> (encoding: Framebuffer_Attachment_Color_Encoding) {
    gl.GetNamedFramebufferAttachmentParameteriv(u32(framebuffer), u32(attachment), gl.FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING, (^i32)(&encoding))
    return
}

// TODO