package app

import gl "vendor:OpenGL"
import "core:log"
import "core:fmt"
import "base:runtime"

gl_init :: proc(major, minor: int, debug_callback: gl.debug_proc_t = nil, user_data: rawptr = nil) -> bool {
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

        if major == 4 && minor >= 3 {
            when gl.GL_DEBUG {
                log.warn("OpenGL: cannot use debug message callback when GL_DEBUG == true. Consider adding command line argument -define:GL_DEBUG=false")
            } else {
                gl.Enable(gl.DEBUG_OUTPUT)
                gl.DebugMessageCallback(debug_callback if debug_callback != nil else gl_debug_callback, user_data)
            }
        }
        
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

gl_debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) {
    context = runtime.default_context()
    fmt.eprintf("GL CALLBACK: %v type = %v, severity = %v, message = %v\n", "** GL ERROR **" if type == gl.DEBUG_TYPE_ERROR else "", type, severity, message)
}