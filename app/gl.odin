package app

USING_OPENGL :: #config(APP_USING_OPENGL, true)

when USING_OPENGL {
    gl_init :: proc(major, minor: int, loc := #caller_location) -> bool {
        return _gl_init(major, minor, loc)
    }

    gl_swap_buffers :: proc(loc := #caller_location) {
        _gl_swap_buffers(loc)
    }
}