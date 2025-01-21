package app

import win32 "core:sys/windows"
import gl "vendor:OpenGL"
import "core:fmt"

when JO_GL {

_gl_init :: proc(ctx: ^Context, major, minor: int) -> bool {
    if ctx.win32_gl_procs_initialized {
        assert(win32.wglChoosePixelFormatARB == nil && win32.wglCreateContextAttribsARB == nil && win32.wglSwapIntervalEXT == nil,
            "OpenGL: unable to initialize after having already failed to load wgl procedures.")
    } else {
        ctx.win32_gl_procs_initialized = true

        dummy := win32.CreateWindowExW(0, L("STATIC"), L("DummyWindow"), 0, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, nil, nil)
        fmt.assertf(dummy != nil, "OpenGL: failed to create dummy window. %v", _win32_last_error_message())
        defer {
            win32.DestroyWindow(dummy)
        }

        hdc := win32.GetDC(dummy)
        assert(hdc != nil, "OpenGL: failed to get dummy window device context.")
        defer win32.ReleaseDC(dummy, hdc)

        desc := win32.PIXELFORMATDESCRIPTOR{
            nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
            nVersion = 1,
            dwFlags = win32.PFD_DRAW_TO_WINDOW | win32.PFD_SUPPORT_OPENGL | win32.PFD_DOUBLEBUFFER,
            iPixelType = win32.PFD_TYPE_RGBA,
            cColorBits = 24,
        }

        format := win32.ChoosePixelFormat(hdc, &desc)
        fmt.assertf(format != 0, "OpenGL: failed to choose pixel format for dummy window. %v", _win32_last_error_message())

        describe_pixel_format_result := win32.DescribePixelFormat(hdc, format, size_of(desc), &desc)
        fmt.assertf(describe_pixel_format_result != 0, "OpenGL: failed to describe pixel format for dummy window. %v", _win32_last_error_message())

        set_pixel_format_result := win32.SetPixelFormat(hdc, format, &desc)
        fmt.assertf(set_pixel_format_result == true, "OpenGL: failed to set pixel format for dummy window. %v", _win32_last_error_message())

        rc := win32.wglCreateContext(hdc)
        fmt.assertf(rc != nil, "OpenGL: failed to create dummy context. %v", _win32_last_error_message())
        defer win32.wglDeleteContext(rc)

        make_current_result := win32.wglMakeCurrent(hdc, rc)
        fmt.assertf(make_current_result == true, "OpenGL: failed to make dummy context current. %v", _win32_last_error_message())
        defer win32.wglMakeCurrent(nil, nil)

        win32.wglChoosePixelFormatARB = win32.ChoosePixelFormatARBType(win32.wglGetProcAddress("wglChoosePixelFormatARB"))
        fmt.assertf(win32.wglChoosePixelFormatARB != nil, "OpenGL: failed to load wglChoosePixelFormatARB. %v", _win32_last_error_message())

        win32.wglCreateContextAttribsARB = win32.CreateContextAttribsARBType(win32.wglGetProcAddress("wglCreateContextAttribsARB"))
        fmt.assertf(win32.wglCreateContextAttribsARB != nil, "OpenGL: failed to load wglCreateContextAttribsARB. %v", _win32_last_error_message())

        win32.wglSwapIntervalEXT = win32.SwapIntervalEXTType(win32.wglGetProcAddress("wglSwapIntervalEXT"))
        fmt.assertf(win32.wglSwapIntervalEXT != nil, "OpenGL: failed to load wglSwapIntervalEXT. %v", _win32_last_error_message())
    }
    
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
        
        choose_pixel_format_result := win32.wglChoosePixelFormatARB(ctx.win32_hdc, &attrib[0], nil, 1, &format, &formats)
        assert(choose_pixel_format_result == true, "OpenGL: failed to choose pixel format.")
        
        desc := win32.PIXELFORMATDESCRIPTOR{
            nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
        }
        describe_pixel_format_result := win32.DescribePixelFormat(ctx.win32_hdc, format, size_of(desc), &desc)
        fmt.assertf(describe_pixel_format_result != 0, "OpenGL: failed to describe pixel format. %v", _win32_last_error_message())

        set_pixel_format_result := win32.SetPixelFormat(ctx.win32_hdc, format, &desc)
        fmt.assertf(set_pixel_format_result == true, "OpenGL: failed to set pixel format. %v", _win32_last_error_message())
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

        rc := win32.wglCreateContextAttribsARB(ctx.win32_hdc, nil, raw_data(&attrib))
        assert(rc != nil, "OpenGL: failed to create context.")

        make_current_result := win32.wglMakeCurrent(ctx.win32_hdc, rc)
        fmt.assertf(make_current_result == true, "OpenGL: failed to make context current. %v", _win32_last_error_message())
    }

    swap_interval_result := win32.wglSwapIntervalEXT(1)
    assert(swap_interval_result, "OpenGL: failed to set swap interval.") // TODO: should we handle vsync not being available?

    gl.load_up_to(major, minor, win32.gl_set_proc_address)

    return true
}

_gl_swap_buffers :: proc(ctx: ^Context) {
    res := win32.SwapBuffers(ctx.win32_hdc)
    fmt.assertf(res == true, "OpenGL: failed to swap buffers. %v", _win32_last_error_message())
}

} // JO_GL