#+ private
package app

import win32 "core:sys/windows"
import gl "vendor:OpenGL"
import "../misc"
import "core:log"

_gl_init :: proc(major, minor: int) -> bool {
    if ctx.gl_procs_initialized {
        if win32.wglChoosePixelFormatARB == nil || win32.wglCreateContextAttribsARB == nil || win32.wglSwapIntervalEXT == nil {
            log.error("OpenGL: unable to initialize after having already failed to load wgl procedures.")
            return false
        }
    } else {
        ctx.gl_procs_initialized = true

        spall_buffer_begin("load_wgl_procs")
        defer spall_buffer_end()

        spall_buffer_begin("CreateWindowExW")
        dummy := win32.CreateWindowExW(0, L("STATIC"), L("DummyWindow"), 0, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, nil, nil)
        spall_buffer_end()

        if dummy == nil {
            log.errorf("OpenGL: failed to create dummy window. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to create dummy window.")

        defer {
            spall_buffer_begin("DestroyWindow")
            win32.DestroyWindow(dummy)
            spall_buffer_end()
        }

        spall_buffer_begin("GetDC")
        hdc := win32.GetDC(dummy)
        spall_buffer_end()

        if hdc == nil {
            log.error("OpenGL: failed to get dummy window device context.")
            return false
        }
        log.debug("OpenGL: succeeded to get dummy window device context.")

        defer {
            spall_buffer_begin("ReleaseDC")
            win32.ReleaseDC(dummy, hdc)
            spall_buffer_end()
        }

        desc := win32.PIXELFORMATDESCRIPTOR{
            nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
            nVersion = 1,
            dwFlags = win32.PFD_DRAW_TO_WINDOW | win32.PFD_SUPPORT_OPENGL | win32.PFD_DOUBLEBUFFER,
            iPixelType = win32.PFD_TYPE_RGBA,
            cColorBits = 24,
        }

        spall_buffer_begin("ChoosePixelFormat")
        format := win32.ChoosePixelFormat(hdc, &desc)
        spall_buffer_end()

        if format == 0 {
            log.errorf("OpenGL: failed to choose pixel format for dummy window. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to choose pixel format for dummy window.")

        spall_buffer_begin("DescribePixelFormat")
        describe_pixel_format_result := win32.DescribePixelFormat(hdc, format, size_of(desc), &desc)
        spall_buffer_end()

        if describe_pixel_format_result == 0 {
            log.errorf("OpenGL: failed to describe pixel format for dummy window. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to describe pixel format for dummy window.")

        spall_buffer_begin("SetPixelFormat")
        set_pixel_format_result := win32.SetPixelFormat(hdc, format, &desc)
        spall_buffer_end()

        if !set_pixel_format_result {
            log.errorf("OpenGL: failed to set pixel format for dummy window. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to set pixel format for dummy window.")

        spall_buffer_begin("wglCreateContext")
        rc := win32.wglCreateContext(hdc)
        spall_buffer_end()

        if rc == nil {
            log.errorf("OpenGL: failed to create dummy context. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to create dummy context.")

        defer {
            spall_buffer_begin("wglDeleteContext")
            win32.wglDeleteContext(rc)
            spall_buffer_end()
        }

        spall_buffer_begin("wglMakeCurrent")
        make_current_result := win32.wglMakeCurrent(hdc, rc)
        spall_buffer_end()

        if !make_current_result {
            log.errorf("OpenGL: failed to make dummy context current. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to make dummy context current.")

        defer {
            spall_buffer_begin("wglMakeCurrent")
            win32.wglMakeCurrent(nil, nil)
            spall_buffer_end()
        }

        spall_buffer_begin("wglGetProcAddress")
        win32.wglChoosePixelFormatARB = win32.ChoosePixelFormatARBType(win32.wglGetProcAddress("wglChoosePixelFormatARB"))
        spall_buffer_end()

        if win32.wglChoosePixelFormatARB == nil {
            log.errorf("OpenGL: failed to load wglChoosePixelFormatARB. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to load wglChoosePixelFormatARB.")

        spall_buffer_begin("wglGetProcAddress")
        win32.wglCreateContextAttribsARB = win32.CreateContextAttribsARBType(win32.wglGetProcAddress("wglCreateContextAttribsARB"))
        spall_buffer_end()

        if win32.wglCreateContextAttribsARB == nil {
            log.errorf("OpenGL: failed to load wglCreateContextAttribsARB. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to load wglCreateContextAttribsARB.")

        spall_buffer_begin("wglGetProcAddress")
        win32.wglSwapIntervalEXT = win32.SwapIntervalEXTType(win32.wglGetProcAddress("wglSwapIntervalEXT"))
        spall_buffer_end()
        
        if win32.wglSwapIntervalEXT == nil {
            log.debugf("OpenGL: failed to load wglSwapIntervalEXT. %v", misc.get_last_error_message())
            log.info("OpenGL: VSync disabled.")
        } else {
            log.debug("OpenGL: succeeded to load wglSwapIntervalEXT.")
            ctx.gl_vsync = true
        }
    }

    if ctx.gl_hdc != nil {
        win32.ReleaseDC(win32.HWND(ctx.window), ctx.gl_hdc)
    }

    spall_buffer_begin("GetDC")
    ctx.gl_hdc = win32.GetDC(win32.HWND(ctx.window))
    spall_buffer_end()
    if ctx.gl_hdc == nil {
        log.error("OpenGL: failed to get window device context.")
        return false
    }
    log.debug("OpenGL: succeeded to get window device context.")
    
    {
        attrib := [?]i32{
            win32.WGL_DRAW_TO_WINDOW_ARB, 1,
            win32.WGL_SUPPORT_OPENGL_ARB, 1,
            win32.WGL_DOUBLE_BUFFER_ARB, 1,
            win32.WGL_PIXEL_TYPE_ARB, win32.WGL_TYPE_RGBA_ARB,
            win32.WGL_COLOR_BITS_ARB, 24,
            win32.WGL_STENCIL_BITS_ARB, 8,

            0,
        }

        format: i32
        formats: u32
        
        spall_buffer_begin("wglChoosePixelFormatARB")
        choose_pixel_format_result := win32.wglChoosePixelFormatARB(ctx.gl_hdc, &attrib[0], nil, 1, &format, &formats)
        spall_buffer_end()

        if !choose_pixel_format_result {
            log.error("OpenGL: failed to choose pixel format.")
            return false
        }
        log.debug("OpenGL: succeeded to choose pixel format.")

        desc := win32.PIXELFORMATDESCRIPTOR{
            nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
        }

        spall_buffer_begin("DescribePixelFormat")
        describe_pixel_format_result := win32.DescribePixelFormat(ctx.gl_hdc, format, size_of(desc), &desc)
        spall_buffer_end()

        if describe_pixel_format_result == 0 {
            log.errorf("OpenGL: failed to describe pixel format. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to describe pixel format.")

        spall_buffer_begin("SetPixelFormat")
        set_pixel_format_result := win32.SetPixelFormat(ctx.gl_hdc, format, &desc)
        spall_buffer_end()

        if !set_pixel_format_result {
            log.errorf("OpenGL: failed to set pixel format. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to set pixel format.")
    }
    
    {
        when ODIN_DEBUG {
            attrib := [?]i32{
                win32.WGL_CONTEXT_MAJOR_VERSION_ARB, i32(major),
                win32.WGL_CONTEXT_MINOR_VERSION_ARB, i32(minor),
                win32.WGL_CONTEXT_PROFILE_MASK_ARB, win32.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
    
                win32.WGL_CONTEXT_FLAGS_ARB, win32.WGL_CONTEXT_DEBUG_BIT_ARB,
    
                0,
            }
        } else {
            attrib := [?]i32{
                win32.WGL_CONTEXT_MAJOR_VERSION_ARB, i32(major),
                win32.WGL_CONTEXT_MINOR_VERSION_ARB, i32(minor),
                win32.WGL_CONTEXT_PROFILE_MASK_ARB, win32.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
    
                0,
            }
        }

        spall_buffer_begin("wglCreateContextAttribsARB")
        rc := win32.wglCreateContextAttribsARB(ctx.gl_hdc, nil, raw_data(&attrib))
        spall_buffer_end()

        if rc == nil {
            log.errorf("OpenGL: failed to create context.")
            return false
        }
        log.debug("OpenGL: succeeded to create context.")

        spall_buffer_begin("wglMakeCurrent")
        make_current_result := win32.wglMakeCurrent(ctx.gl_hdc, rc)
        spall_buffer_end()

        if !make_current_result {
            log.errorf("OpenGL: failed to make context current. %v", misc.get_last_error_message())
            return false
        }
        log.debug("OpenGL: succeeded to make context current.")
    }

    if ctx.gl_vsync {
        spall_buffer_begin("wglSwapIntervalEXT")
        swap_interval_result := win32.wglSwapIntervalEXT(1)
        spall_buffer_end()

        if !swap_interval_result {
            log.debug("OpenGL: failed to set swap interval.")
            log.info("OpenGL: VSync disabled.")
            ctx.gl_vsync = false
        }
        else {
            log.debug("OpenGL: succeeded to set swap interval.")
            log.info("OpenGL: VSync enabled.")
        }
    }

    gl.load_up_to(major, minor, win32.gl_set_proc_address)

    return true
}

_gl_swap_buffers :: proc(loc := #caller_location) -> bool {
    if !win32.SwapBuffers(ctx.gl_hdc) {
        log.fatalf("OpenGL: failed to swap buffers. %v", misc.get_last_error_message(), location = loc)
        ctx.running = false
    }
    return ctx.running
}