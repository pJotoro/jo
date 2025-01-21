package app

import "base:runtime"
import win32 "core:sys/windows"
import "base:intrinsics"
import "core:fmt"
import "core:io"
import "core:unicode"
import "core:strings"

OS_Specific :: struct {
    win32_instance: win32.HINSTANCE,
    win32_cursor: win32.HCURSOR,
    win32_dpi_aware: bool,

    win32_hdc: win32.HDC,
    win32_gl_procs_initialized: bool,

    win32_window: win32.HWND,
    win32_event_proc: win32.WNDPROC, // TODO
    win32_window_ready: int, // 0=no, 1=almost, 2=yes
    win32_window_style, win32_window_ex_style: u32,

    window_rect: Rect,
    d3d11_ctx: ^D3D11_Context,
}

L :: intrinsics.constant_utf16_cstring

_win32_event_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    context = runtime.default_context()

    ctx := transmute(^Context)win32.GetWindowLongPtrW(window, win32.GWLP_USERDATA)
    if ctx == nil {
        return win32.DefWindowProcW(window, message, w_param, l_param)
    }

    result := win32.LRESULT(0)

    get_key :: proc(vk: win32.WPARAM) -> Key {
        switch vk {
            case win32.VK_CANCEL:       return .Cancel
            case win32.VK_BACK:         return .Backspace
            case win32.VK_TAB:          return .Tab
            case win32.VK_CLEAR:        return .Clear
            case win32.VK_RETURN:       return .Enter
            case win32.VK_SHIFT:        return .Shift
            case win32.VK_CONTROL:      return .Control
            case win32.VK_MENU:         return .Alt
            case win32.VK_PAUSE:        return .Pause
            case win32.VK_CAPITAL:      return .Caps_Lock
            case win32.VK_ESCAPE:       return .Escape
            case win32.VK_SPACE:        return .Space
            case win32.VK_PRIOR:        return .Page_Up
            case win32.VK_NEXT:         return .Page_Down
            case win32.VK_END:          return .End
            case win32.VK_HOME:         return .Home
            case win32.VK_LEFT:         return .Left
            case win32.VK_UP:           return .Up
            case win32.VK_RIGHT:        return .Right
            case win32.VK_DOWN:         return .Down
            case win32.VK_SELECT:       return .Select
            case win32.VK_PRINT:        return .Print
            case win32.VK_EXECUTE:      return .Execute
            case win32.VK_SNAPSHOT:     return .Print_Screen
            case win32.VK_INSERT:       return .Insert
            case win32.VK_DELETE:       return .Delete
            case win32.VK_HELP:         return .Help
            case win32.VK_0:            return .Zero
            case win32.VK_1:            return .One
            case win32.VK_2:            return .Two
            case win32.VK_3:            return .Three
            case win32.VK_4:            return .Four
            case win32.VK_5:            return .Five
            case win32.VK_6:            return .Six
            case win32.VK_7:            return .Seven
            case win32.VK_8:            return .Eight
            case win32.VK_9:            return .Nine
            case 'A':                   return .A
            case 'B':                   return .B
            case 'C':                   return .C
            case 'D':                   return .D
            case 'E':                   return .E
            case 'F':                   return .F
            case 'G':                   return .G
            case 'H':                   return .H
            case 'I':                   return .I
            case 'J':                   return .J
            case 'K':                   return .K
            case 'L':                   return .L
            case 'M':                   return .M
            case 'N':                   return .N
            case 'O':                   return .O
            case 'P':                   return .P
            case 'Q':                   return .Q
            case 'R':                   return .R
            case 'S':                   return .S
            case 'T':                   return .T
            case 'U':                   return .U
            case 'V':                   return .V
            case 'W':                   return .W
            case 'X':                   return .X
            case 'Y':                   return .Y
            case 'Z':                   return .Z
            case win32.VK_LWIN:         return .Left_Logo
            case win32.VK_RWIN:         return .Right_Logo
            case win32.VK_APPS:         return .Apps
            case win32.VK_SLEEP:        return .Sleep
            case win32.VK_NUMPAD0:      return .Numpad0
            case win32.VK_NUMPAD1:      return .Numpad1
            case win32.VK_NUMPAD2:      return .Numpad2
            case win32.VK_NUMPAD3:      return .Numpad3
            case win32.VK_NUMPAD4:      return .Numpad4
            case win32.VK_NUMPAD5:      return .Numpad5
            case win32.VK_NUMPAD6:      return .Numpad6
            case win32.VK_NUMPAD7:      return .Numpad7
            case win32.VK_NUMPAD8:      return .Numpad8
            case win32.VK_NUMPAD9:      return .Numpad9
            case win32.VK_MULTIPLY:     return .Multiply
            case win32.VK_ADD:          return .Add
            case win32.VK_SEPARATOR:    return .Separator
            case win32.VK_SUBTRACT:     return .Subtract
            case win32.VK_DECIMAL:      return .Decimal
            case win32.VK_DIVIDE:       return .Divide
            case win32.VK_F1:           return .F1
            case win32.VK_F2:           return .F2
            case win32.VK_F3:           return .F3
            case win32.VK_F4:           return .F4
            case win32.VK_F5:           return .F5
            case win32.VK_F6:           return .F6
            case win32.VK_F7:           return .F7
            case win32.VK_F8:           return .F8
            case win32.VK_F9:           return .F9
            case win32.VK_F10:          return .F10
            case win32.VK_F11:          return .F11
            case win32.VK_F12:          return .F12
            case win32.VK_F13:          return .F13
            case win32.VK_F14:          return .F14
            case win32.VK_F15:          return .F15
            case win32.VK_F16:          return .F16
            case win32.VK_F17:          return .F17
            case win32.VK_F18:          return .F18
            case win32.VK_F19:          return .F19
            case win32.VK_F20:          return .F20
            case win32.VK_F21:          return .F21
            case win32.VK_F22:          return .F22
            case win32.VK_F23:          return .F23
            case win32.VK_F24:          return .F24
            case win32.VK_NUMLOCK:      return .Num_Lock
            case win32.VK_SCROLL:       return .Scroll
            case win32.VK_VOLUME_MUTE:  return .Volume_Mute
            case win32.VK_VOLUME_DOWN:  return .Volume_Down
            case win32.VK_VOLUME_UP:    return .Volume_Up
            case win32.VK_OEM_COMMA:    return .Comma
            case win32.VK_OEM_PERIOD:   return .Period
        }

        panic("Win32: unsupported key")
    }

    switch message {
        case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
            ctx.running = false

        case win32.WM_ACTIVATE:
            w_param := transmute([4]u16)w_param
            if w_param[0] == win32.WA_INACTIVE {
                ctx.open = false
            } else {
                ctx.open = true

                if _, ok := ctx.window_mode.(Window_Mode_Fullscreen); ok {
                    _toggle_cursor(ctx, false)
                }
            }

        case win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN:
            key := get_key(w_param)
            if !(int(key) > len(ctx.keys)) {
                if .Down not_in ctx.keys[key] {
                    ctx.keys[key] += {.Pressed}
                }
                ctx.keys[key] += {.Down}
            }

        case win32.WM_KEYUP, win32.WM_SYSKEYUP:
            key := get_key(w_param)
            if int(key) < len(ctx.keys) {
                ctx.keys[key] -= {.Down}
                ctx.keys[key] += {.Released}
            }

        case win32.WM_LBUTTONDOWN:
            if .Down not_in ctx.mouse_left {
                ctx.mouse_left += {.Pressed}
            }
            ctx.mouse_left += {.Down}
            
        case win32.WM_LBUTTONUP:
            ctx.mouse_left -= {.Down}
            ctx.mouse_left += {.Released}

        // TODO: Why are mouse double click events not happening
        // Is the mouse not captured by the window?
        case win32.WM_LBUTTONDBLCLK:
            ctx.mouse_left += {.Double_Click}

        case win32.WM_RBUTTONDOWN:
            if .Down not_in ctx.mouse_right {
                ctx.mouse_right += {.Pressed}
            }
            ctx.mouse_right += {.Down}

        case win32.WM_RBUTTONUP:
            ctx.mouse_right -= {.Down}
            ctx.mouse_right += {.Released}

        case win32.WM_RBUTTONDBLCLK:
            ctx.mouse_right += {.Double_Click}

        case win32.WM_MBUTTONDOWN:
            if .Down not_in ctx.mouse_middle {
                ctx.mouse_middle += {.Pressed}
            }
            ctx.mouse_middle += {.Down}

        case win32.WM_MBUTTONUP:
            ctx.mouse_middle -= {.Down}
            ctx.mouse_middle += {.Released}

        case win32.WM_MBUTTONDBLCLK:
            ctx.mouse_middle += {.Double_Click}

        case win32.WM_MOUSEMOVE:
            cr := client_rect(ctx)

            params := transmute([4]i16)l_param
            ctx.mouse_pos.x = int(params[0])
            ctx.mouse_pos.y = int(-params[1]) + cr.h

        case win32.WM_MOUSEWHEEL:
            WHEEL_DELTA :: 120
            amount := i16(w_param >> 16) / WHEEL_DELTA
            ctx.mouse_wheel = int(amount)

        case win32.WM_CHAR:
            r := rune(w_param)
            if !unicode.is_control(r) {
                io.write_rune(ctx.text_input, r)
            }
            
        case:
            result = win32.DefWindowProcW(window, message, w_param, l_param)
            
    }

    return result
}

foreign import user32 "system:User32.lib"

@(default_calling_convention="system")
foreign user32 {
    GetDpiForSystem :: proc() -> win32.UINT ---
    ShowCursor :: proc(bShow: win32.BOOL) -> i32 ---
    GetCursor :: proc() -> win32.HCURSOR ---
    SetCursor :: proc(hCursor: win32.HCURSOR) -> win32.HCURSOR ---
}

_win32_client_rect_to_window_rect :: proc(ctx: ^Context, client_rect: Rect, style, ex_style: u32) -> (window_rect: Rect) {
    win32_rect := win32.RECT{i32(client_rect.x), i32(client_rect.y), i32(client_rect.x + client_rect.w), i32(client_rect.y + client_rect.h)}
    
    res := win32.AdjustWindowRectExForDpi(&win32_rect, style, false, ex_style, u32(ctx.dpi))
    fmt.assertf(res == true, "Failed to adjust window rectangle. %v", _win32_last_error_message())

    window_rect = Rect {
        x = int(win32_rect.left),
        y = int(win32_rect.top),
        w = int(win32_rect.right - win32_rect.left),
        h = int(win32_rect.bottom - win32_rect.top),
    }

    return
}

_win32_window_properties :: proc(ctx: ^Context, window_mode: Window_Mode) -> (window_rect: Rect, style, ex_style: u32) {
    switch wm in window_mode {
        case Window_Mode_Windowed:
            rect := Rect(wm)

            // TODO: This doesn't really belong here. Move this into a cross-platform procedure.
            if rect.w == 0 && rect.h == 0 {
                rect.w = ctx.screen.w / 2
                rect.h = ctx.screen.h / 2
            } else if rect.w > 0 && rect.h == 0 {
                rect.h = rect.w*ctx.screen.h / ctx.screen.w
            } else if rect.w == 0 && rect.h > 0 {
                rect.w = rect.h*ctx.screen.w / ctx.screen.h
            }
            if rect.x == 0 {
                rect.x = (ctx.screen.w - rect.w) / 2
            }
            if rect.y == 0 {
                rect.y = (ctx.screen.h - rect.h) / 2
            }
            ctx.window_mode = Window_Mode_Windowed(rect)

            style = win32.WS_CAPTION | win32.WS_SYSMENU
            ex_style = 0

            window_rect = _win32_client_rect_to_window_rect(ctx, 
                client_rect = rect, 
                style = style, 
                ex_style = ex_style)

        case Window_Mode_Fullscreen:
            window_rect.w = ctx.screen.w
            window_rect.h = ctx.screen.h
            style = win32.WS_POPUP
            ex_style = 0
            if wm.topmost {
                ex_style |= win32.WS_EX_TOPMOST
            }

        case:
            panic("unknown window mode")
    }
    return
}

_init :: proc(ctx: ^Context) {
    // cursor
    ctx.win32_cursor = GetCursor()
    
    // dpi
    if win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
        ctx.win32_dpi_aware = true
    }
    ctx.dpi = int(GetDpiForSystem())

    // instance
    ctx.win32_instance = win32.HINSTANCE(win32.GetModuleHandleW(nil))
    fmt.assertf(ctx.win32_instance != nil, "Failed to get module handle. %v", _win32_last_error_message())

    // window class
    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        lpfnWndProc = _win32_event_proc,
        hInstance = win32.HANDLE(ctx.win32_instance),
        lpszClassName = L("app_class"),
    }
    {
        res := win32.RegisterClassExW(&window_class)
        fmt.assertf(res != 0, "Failed to register window class. %v", _win32_last_error_message())
    }
    
    // screen dimensions
    {
        monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
        monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
        res := win32.GetMonitorInfoW(monitor, &monitor_info)
        fmt.assertf(res == true, "Failed to get monitor info. %v", _win32_last_error_message())
        ctx.screen.w = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
        ctx.screen.h = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
    }
    
    // window
    {
        window_rect, window_style, window_ex_style := _win32_window_properties(ctx, ctx.window_mode)

        ctx.win32_window = win32.CreateWindowExW(
            window_ex_style, 
            window_class.lpszClassName, 
            win32.utf8_to_wstring(ctx.title),
            window_style, 
            i32(window_rect.x), 
            i32(window_rect.y), 
            i32(window_rect.w), 
            i32(window_rect.h), 
            nil, 
            nil,
            win32.HANDLE(ctx.win32_instance), 
            nil)
        fmt.assertf(ctx.win32_window != nil, "Failed to create window. %v", _win32_last_error_message())
        
        ctx.window_rect = window_rect
        ctx.win32_window_style = window_style
        ctx.win32_window_ex_style = window_ex_style
    }

    // set event callback user data
    win32.SetWindowLongPtrW(ctx.win32_window, win32.GWLP_USERDATA, transmute(win32.LONG_PTR)ctx)

    // get window device context
    {
        ctx.win32_hdc = win32.GetDC(ctx.win32_window)
        assert(ctx.win32_hdc != nil, "Failed to get window device context.")
    }
    
    {
        dev_mode := win32.DEVMODEW{dmSize = size_of(win32.DEVMODEW)}
        res := win32.EnumDisplaySettingsW(nil, win32.ENUM_CURRENT_SETTINGS, &dev_mode)
        assert(res == true, "Failed to enumerate display settings.")
        ctx.refresh_rate = int(dev_mode.dmDisplayFrequency)
    }
}

_run :: proc(ctx: ^Context) {
    if ctx.win32_window_ready == -1 {
        ctx.win32_window_ready += 1
    } else if ctx.win32_window_ready == 0 {
        ctx.win32_window_ready += 1
        win32.ShowWindow(ctx.win32_window, win32.SW_SHOW)
    }
    for {
        message: win32.MSG
        if win32.PeekMessageW(&message, ctx.win32_window, 0, 0, win32.PM_REMOVE) {
            win32.TranslateMessage(&message)
            win32.DispatchMessageW(&message)
            continue
        }
        break
    }
}

_cpu_swap_buffers :: proc(ctx: ^Context, buf: []u32, buf_w, buf_h: int) {
    cr := client_rect(ctx)

    src_w := i32(buf_w) if buf_w != 0 else i32(cr.w)
    src_h := i32(buf_h) if buf_h != 0 else i32(cr.h)
    dest_w := i32(cr.w)
    dest_h := i32(cr.h)

    bitmap_info: win32.BITMAPINFO
    bitmap_info.bmiHeader = win32.BITMAPINFOHEADER{
        biSize = size_of(win32.BITMAPINFOHEADER),
        biWidth = src_w,
        biHeight = src_h,
        biPlanes = 1,
        biBitCount = 32,
        biCompression = win32.BI_RGB,
    }
    res := win32.StretchDIBits(ctx.win32_hdc, 0, 0, dest_w, dest_h, 0, 0, src_w, src_h, raw_data(buf), &bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY)
    assert(res != 0, "Failed to render bitmap.")
}

_toggle_cursor :: proc "contextless" (ctx: ^Context, toggle: bool) {
    if toggle {
        SetCursor(ctx.win32_cursor)
    } else {
        SetCursor(nil)
    }
}

_set_title :: proc(ctx: ^Context) {
    title := ctx.title
    wstring := win32.utf8_to_wstring(title)
    res := win32.SetWindowTextW(ctx.win32_window, wstring)
    fmt.assertf(res == true, "Failed to set window title to %v. %v", title, _win32_last_error_message())
}

_set_window_mode :: proc(ctx: ^Context) {
    window_mode := ctx.window_mode
    window_rect, window_style, window_ex_style := _win32_window_properties(ctx, window_mode)

    // set window flags
    if window_style != ctx.win32_window_style {
        win32.SetWindowLongPtrW(ctx.win32_window, win32.GWL_STYLE, int(window_style))
        ctx.win32_window_style = window_style
    }
    
    // set window extended flags
    if window_ex_style != ctx.win32_window_ex_style {
        win32.SetWindowLongPtrW(ctx.win32_window, win32.GWL_EXSTYLE, int(window_ex_style))
        ctx.win32_window_ex_style = window_ex_style
    }
    
    // set window dimensions
    if window_rect != ctx.window_rect {
        res := win32.SetWindowPos(ctx.win32_window, nil, 
            i32(window_rect.x), i32(window_rect.y), i32(window_rect.w), i32(window_rect.h), 
            win32.SWP_SHOWWINDOW | win32.SWP_FRAMECHANGED)
        fmt.assertf(res == true, "Failed to set window pos. %v", _win32_last_error_message())
        ctx.window_rect = window_rect
    }
}

_win32_last_error_message :: proc() -> (string, runtime.Allocator_Error) #optional_allocator_error {
    error := win32.GetLastError()
    buf: [512]u16 = ---
    win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
    res, err := win32.wstring_to_utf8(raw_data(buf[:]), -1)
    return strings.trim_suffix(res, "\n"), err
}

_win32_hresult_message :: proc(hr: win32.HRESULT) -> (string, runtime.Allocator_Error) #optional_allocator_error {
    buf: [512]u16 = ---
    win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, u32(hr), 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
    res, err := win32.wstring_to_utf8(raw_data(buf[:]), -1)
    return strings.trim_suffix(res, "\n"), err
}