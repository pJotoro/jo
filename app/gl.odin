package app

import gl "vendor:OpenGL"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:encoding/ansi"
import "base:runtime"
import "base:intrinsics"

JO_GL :: #config(JO_GL, false)

when JO_GL {

// Initializes OpenGL.
gl_init :: proc(major, minor: int, debug_callback: gl.debug_proc_t = gl_debug_callback, user_data: rawptr = nil, loc := #caller_location) -> bool {
    ok := true

    if !ctx.app_initialized {
        log.error("OpenGL: app not initialized.", location = loc)
        ok = false
    }
    if ctx.gl_initialized {
        log.warn("OpenGL: already initialized.", location = loc)
        ok = false
    }

    if !((major == 4 && minor <= 6) || (major == 3 && minor <= 3) || (major == 2 && minor <= 1) || (major == 1) && (minor <= 5)) {
        log.errorf("OpenGL: invalid version %v.%v used. See https://www.khronos.org/opengl/wiki/History_of_OpenGL for valid OpenGL versions.", major, minor, location = loc)
        ok = false
    }

    if !ok {
        return false
    }

    if _gl_init(major, minor) {
        log.infof("OpenGL: loaded up to version %v.%v.", major, minor, location = loc)

        when ODIN_DEBUG {
            if major == 4 && minor >= 3 {
                when gl.GL_DEBUG {
                    log.warn("OpenGL: cannot use debug message callback when GL_DEBUG == true. Consider adding command line argument -define:GL_DEBUG=false.", location = loc)
                    log.info("OpenGL: debug output disabled.", location = loc)
                } else {
                    gl.Enable(gl.DEBUG_OUTPUT)
                    gl.DebugMessageCallback(debug_callback, user_data)
                    log.info("OpenGL: debug output enabled.", location = loc)
                }
            } else {
                log.info("OpenGL: debug output disabled.", location = loc)
            }
        } else {
            log.info("OpenGL: debug output disabled.", location = loc)
        }
        
        gl.Viewport(0, 0, i32(width()), i32(height()))
        log.infof("OpenGL: set viewport to x = %v, y = %v, width = %v, height = %v.", 0, 0, width(), height(), location = loc)

        ctx.gl_initialized = true
    }
    return ctx.gl_initialized
}

// When using OpenGL, call at the end of every frame.
//
// Must call app.gl_init first.
gl_swap_buffers :: proc(loc := #caller_location) -> bool {
    if !ctx.app_initialized {
        log.fatal("OpenGL: app not initialized.", location = loc)
        ctx.running = false
        return ctx.running
    }
    if !ctx.gl_initialized {
        log.fatal("OpenGL: not initialized.", location = loc)
        ctx.running = false
        return ctx.running
    }
    return _gl_swap_buffers(loc)
}

gl_debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) {
    context = runtime.default_context()
    type := Debug_Type(type)
    severity := Debug_Severity(severity)
    
    b: strings.Builder
    strings.builder_init(&b)
    defer strings.builder_destroy(&b)

    is_error := false

    switch severity {
        case .Debug_Severity_High:
            fmt.sbprint(&b, FG_RED)
            is_error = true
        case .Debug_Severity_Medium:
            fmt.sbprint(&b, FG_YELLOW)
        case .Debug_Severity_Low:
        case .Debug_Severity_Notification, .Dont_Care:
            fmt.sbprint(&b, FG_DARK_GREY)
    }

    debug_type_strings := [10]string{
        "[ERROR] --- ",
        "[DEPRECATED BEHAVIOR] --- ",
        "[UNDEFINED BEHAVIOR] --- ",
        "[PERFORMANCE] --- ",
        "[PORTABILITY] --- ",
        "[MARKER] --- ",
        "[PUSH GROUP] --- ",
        "[POP GROUP] --- ",
        "[OTHER] --- ",
        "[DONT CARE] --- ",
    }

    switch type {
        case .Debug_Type_Error:
            fmt.sbprint(&b, debug_type_strings[0])
        case .Debug_Type_Deprecated_Behavior:
            fmt.sbprint(&b, debug_type_strings[1])
        case .Debug_Type_Undefined_Behavior:
            fmt.sbprint(&b, debug_type_strings[2])
        case .Debug_Type_Performance:
            fmt.sbprint(&b, debug_type_strings[3])
        case .Debug_Type_Portability:
            fmt.sbprint(&b, debug_type_strings[4])
        case .Debug_Type_Marker:
            fmt.sbprint(&b, debug_type_strings[5])
        case .Debug_Type_Push_Group:
            fmt.sbprint(&b, debug_type_strings[6])
        case .Debug_Type_Pop_Group:
            fmt.sbprint(&b, debug_type_strings[7])
        case .Debug_Type_Other:
            fmt.sbprint(&b, debug_type_strings[8])
        case .Dont_Care:
            fmt.sbprint(&b, debug_type_strings[9])
    }

    fmt.sbprint(&b, RESET)
    fmt.sbprintln(&b, message)

    if is_error {
        fmt.eprint(strings.to_string(b))
    } else {
        fmt.print(strings.to_string(b))
    }

    Debug_Type :: enum u32 {
        Debug_Type_Error               = gl.DEBUG_TYPE_ERROR,
        Debug_Type_Deprecated_Behavior = gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR,
        Debug_Type_Undefined_Behavior  = gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR,
        Debug_Type_Performance         = gl.DEBUG_TYPE_PERFORMANCE,
        Debug_Type_Portability         = gl.DEBUG_TYPE_PORTABILITY,
        Debug_Type_Marker              = gl.DEBUG_TYPE_MARKER,
        Debug_Type_Push_Group          = gl.DEBUG_TYPE_PUSH_GROUP,
        Debug_Type_Pop_Group           = gl.DEBUG_TYPE_POP_GROUP,
        Debug_Type_Other               = gl.DEBUG_TYPE_OTHER,
        Dont_Care                      = gl.DONT_CARE,
    }

    Debug_Severity :: enum u32 {
        Debug_Severity_High         = gl.DEBUG_SEVERITY_HIGH,
        Debug_Severity_Medium       = gl.DEBUG_SEVERITY_MEDIUM,
        Debug_Severity_Low          = gl.DEBUG_SEVERITY_LOW,
        Debug_Severity_Notification = gl.DEBUG_SEVERITY_NOTIFICATION,
        Dont_Care                   = gl.DONT_CARE,
    }

    RESET        :: ansi.CSI + ansi.RESET           + ansi.SGR
	
    FG_RED       :: ansi.CSI + ansi.FG_RED          + ansi.SGR
	FG_YELLOW    :: ansi.CSI + ansi.FG_YELLOW       + ansi.SGR
	FG_DARK_GREY :: ansi.CSI + ansi.FG_BRIGHT_BLACK + ansi.SGR
}

} // JO_GL