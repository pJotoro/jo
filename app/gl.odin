package app

import gl "vendor:OpenGL"
import "core:log"
import win32 "core:sys/windows"
import "core:prof/spall"

gl_init :: proc(major, minor: int) -> bool {
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    if !ctx.app_initialized {
        log.panic("App not initialized.")
    }
    if ctx.gl_initialized {
        log.panic("OpenGL already initialized.")
    }

    if _gl_init(major, minor) {
        gl.load_up_to(major, minor, win32.gl_set_proc_address)
        log.infof("OpenGL: loaded up to version %v.%v.", major, minor)
        
        gl.Viewport(0, 0, i32(width()), i32(height()))
        log.infof("OpenGL: set viewport to x = %v, y = %v, width = %v, height = %v.", 0, 0, width(), height())

        ctx.gl_initialized = true
        return true
    }
    return false
}

gl_swap_buffers :: proc(loc := #caller_location) {
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    if !ctx.app_initialized {
        log.panic("App not initialized.")
    }
    if !ctx.gl_initialized {
        log.panic("OpenGL not initialized.")
    }
    _gl_swap_buffers()
}