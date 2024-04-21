package ngl

import gl "vendor:OpenGL"

get_renderbuffer_width :: proc "contextless" (renderbuffer: Renderbuffer) -> (width: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_WIDTH, &width)
    return
}

get_renderbuffer_height :: proc "contextless" (renderbuffer: Renderbuffer) -> (height: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_HEIGHT, &height)
    return
}

get_renderbuffer_internal_format :: proc "contextless" (renderbuffer: Renderbuffer) -> (internal_format: Color_Depth_Stencil_Renderable_Format) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_INTERNAL_FORMAT, (^i32)(&internal_format))
    return
}

get_renderbuffer_samples :: proc "contextless" (renderbuffer: Renderbuffer) -> (samples: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_SAMPLES, &samples)
    return
}

get_renderbuffer_red_size :: proc "contextless" (renderbuffer: Renderbuffer) -> (size: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_RED_SIZE, &size)
    return
}

get_renderbuffer_green_size :: proc "contextless" (renderbuffer: Renderbuffer) -> (size: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_GREEN_SIZE, &size)
    return
}

get_renderbuffer_blue_size :: proc "contextless" (renderbuffer: Renderbuffer) -> (size: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_BLUE_SIZE, &size)
    return
}

get_renderbuffer_alpha_size :: proc "contextless" (renderbuffer: Renderbuffer) -> (size: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_ALPHA_SIZE, &size)
    return
}

get_renderbuffer_depth_size :: proc "contextless" (renderbuffer: Renderbuffer) -> (size: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_DEPTH_SIZE, &size)
    return
}

get_renderbuffer_stencil_size :: proc "contextless" (renderbuffer: Renderbuffer) -> (size: i32) {
    gl.GetNamedRenderbufferParameteriv(u32(renderbuffer), gl.RENDERBUFFER_STENCIL_SIZE, &size)
    return
}