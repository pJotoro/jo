package app

import gl "vendor:OpenGL"
import "core:log"
import "core:fmt"
import "base:runtime"
import "base:intrinsics"

// Initializes OpenGL.
gl_init :: proc(major, minor: int, debug_callback: gl.debug_proc_t = nil, user_data: rawptr = nil) -> bool {
    ok := true

    if !ctx.app_initialized {
        log.error("OpenGL: app not initialized.")
        ok = false
    }
    if ctx.gl_initialized {
        log.warn("OpenGL: already initialized.")
        ok = false
    }

    if !((major == 4 && minor <= 6) || (major == 3 && minor <= 3) || (major == 2 && minor <= 1) || (major == 1) && (minor <= 5)) {
        log.errorf("OpenGL: invalid version %v.%v used. See https://www.khronos.org/opengl/wiki/History_of_OpenGL for valid OpenGL versions.", major, minor)
        ok = false
    }

    if !ok {
        return false
    }

    if _gl_init(major, minor) {
        log.infof("OpenGL: loaded up to version %v.%v.", major, minor)

        when ODIN_DEBUG {
            if major == 4 && minor >= 3 {
                if gl.GL_DEBUG && !intrinsics.is_package_imported("ngl") {
                    log.warn("OpenGL: cannot use debug message callback when GL_DEBUG == true. Consider adding command line argument -define:GL_DEBUG=false.")
                    log.info("OpenGL: debug output disabled.")
                } else {
                    gl.Enable(gl.DEBUG_OUTPUT)
                    gl.DebugMessageCallback(debug_callback if debug_callback != nil else gl_debug_callback, user_data)
                    log.info("OpenGL: debug output enabled.")
                }
            } else {
                log.info("OpenGL: debug output disabled.")
            }
        } else {
            log.info("OpenGL: debug output disabled.")
        }
        
        gl.Viewport(0, 0, i32(width()), i32(height()))
        log.infof("OpenGL: set viewport to x = %v, y = %v, width = %v, height = %v.", 0, 0, width(), height())

        ctx.gl_initialized = true
    }
    return ctx.gl_initialized
}

// When using OpenGL, call at the end of every frame.
//
// Must call app.gl_init first.
gl_swap_buffers :: proc(loc := #caller_location) -> bool {
    if !ctx.app_initialized {
        log.fatal("OpenGL: app not initialized.")
        ctx.running = false
        return ctx.running
    }
    if !ctx.gl_initialized {
        log.fatal("OpenGL: not initialized.")
        ctx.running = false
        return ctx.running
    }
    return _gl_swap_buffers()
}

gl_debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) {
    context = runtime.default_context()
    fmt.eprintf("GL CALLBACK: %v type = %v, severity = %v, message = %v\n", "** GL ERROR **" if type == gl.DEBUG_TYPE_ERROR else "", type, severity, message)
}