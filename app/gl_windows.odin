//+private
package app

import gl "vendor:OpenGL"
import win32 "core:sys/windows"
import "../misc"

when USING_OPENGL {
    _gl_init :: proc(major, minor: int, loc := #caller_location) -> bool {
        {
            dummy := win32.CreateWindowExW(0, L("STATIC"), L("DummyWindow"), 0, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, nil, nil)
            if dummy == nil do return false
            defer win32.DestroyWindow(dummy)

            hdc := win32.GetDC(dummy)
            if hdc == nil do return false
            defer win32.ReleaseDC(dummy, hdc)

            desc := win32.PIXELFORMATDESCRIPTOR{
                nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
                nVersion = 1,
                dwFlags = win32.PFD_DRAW_TO_WINDOW | win32.PFD_SUPPORT_OPENGL | win32.PFD_DOUBLEBUFFER,
                iPixelType = win32.PFD_TYPE_RGBA,
                cColorBits = 24,
            }
            format := win32.ChoosePixelFormat(hdc, &desc)
            if format == 0 do return false
            if win32.DescribePixelFormat(hdc, format, size_of(desc), &desc) == 0 do return false
            if !win32.SetPixelFormat(hdc, format, &desc) do return false

            rc := win32.wglCreateContext(hdc)
            if rc == nil do return false
            defer win32.wglDeleteContext(rc)
            
            if !win32.wglMakeCurrent(hdc, rc) do return false
            defer win32.wglMakeCurrent(nil, nil)

            win32.wglChoosePixelFormatARB = win32.ChoosePixelFormatARBType(win32.wglGetProcAddress("wglChoosePixelFormatARB"))
            if win32.wglChoosePixelFormatARB == nil do return false
            win32.wglCreateContextAttribsARB = win32.CreateContextAttribsARBType(win32.wglGetProcAddress("wglCreateContextAttribsARB"))
            if win32.wglCreateContextAttribsARB == nil do return false
            win32.wglSwapIntervalEXT = win32.SwapIntervalEXTType(win32.wglGetProcAddress("wglSwapIntervalEXT"))
            if win32.wglSwapIntervalEXT != nil do ctx.gl_vsync = true
        }

        ctx.gl_hdc = win32.GetDC(ctx.window)
        if ctx.gl_hdc == nil do return false
        
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
            if !win32.wglChoosePixelFormatARB(ctx.gl_hdc, &attrib[0], nil, 1, &format, &formats) do return false
            desc := win32.PIXELFORMATDESCRIPTOR{
                nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
            }
            if win32.DescribePixelFormat(ctx.gl_hdc, format, size_of(desc), &desc) == 0 do return false
            if !win32.SetPixelFormat(ctx.gl_hdc, format, &desc) do return false
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

            rc := win32.wglCreateContextAttribsARB(ctx.gl_hdc, nil, &attrib[0])
            if rc == nil do return false
            if !win32.wglMakeCurrent(ctx.gl_hdc, rc) do return false
        }

        if ctx.gl_vsync {
            if !win32.wglSwapIntervalEXT(1) do ctx.gl_vsync = false
        }

        gl.load_up_to(major, minor, win32.gl_set_proc_address)
        gl.Viewport(0, 0, i32(width()), i32(height()))
        return true
    }

    _gl_swap_buffers :: proc(loc := #caller_location) {
        if !win32.SwapBuffers(ctx.gl_hdc) do misc.panic(loc)
        if !ctx.gl_vsync {
            // TODO(pJotoro): Would it make sense to base this amount of milliseconds on how long the frame took? The problem is, the smallest the number of milliseconds can be is 1, and it has to be an integer, so it's highly inaccurate. Beyond that, I'm pretty sure most gamers nowadays use GPUs and monitors with vsync, so it's hard to imagine this being an issue anyway.
            win32.timeBeginPeriod(1)
            win32.Sleep(1)
            win32.timeEndPeriod(1)
        }
    }
}