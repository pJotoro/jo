package app

import gl "vendor:OpenGL"
import "core:log"

gl_init :: proc(major, minor: int) -> bool {
    if !ctx.app_initialized {
        log.panic("App not initialized.")
    }
    if ctx.gl_initialized {
        log.panic("OpenGL already initialized.")
    }

    if !((major == 4 && minor <= 6) || (major == 3 && minor <= 3) || (major == 2 && minor <= 1) || (major == 1) && (minor <= 5)) {
        log.panicf("Invalid OpenGL version %v.%v used. See https://www.khronos.org/opengl/wiki/History_of_OpenGL for valid OpenGL versions.", major, minor)
    }

    if _gl_init(major, minor) {
        log.infof("OpenGL: loaded up to version %v.%v.", major, minor)
        
        gl.Viewport(0, 0, i32(width()), i32(height()))
        log.infof("OpenGL: set viewport to x = %v, y = %v, width = %v, height = %v.", 0, 0, width(), height())

        ctx.gl_initialized = true
        return true
    }
    return false
}

gl_swap_buffers :: proc(loc := #caller_location) {
    if !ctx.app_initialized {
        log.panic("App not initialized.")
    }
    if !ctx.gl_initialized {
        log.panic("OpenGL not initialized.")
    }
    _gl_swap_buffers()
}