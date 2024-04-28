package ngl

import gl "vendor:OpenGL"

renderbuffer_storage_multisample :: proc "contextless" (renderbuffer: Renderbuffer, samples: i32, internal_format: Color_Depth_Stencil_Renderable_Format, width, height: i32) {
	gl.NamedRenderbufferStorageMultisample(u32(renderbuffer), samples, u32(internal_format), width, height)
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