// +private
package app

import win32 "core:sys/windows"
import "core:intrinsics"
import "core:log"

import "xinput"
import "../misc"

OS_Specific :: struct {
    visible: int, // -1 and 0 mean invisible, 1 means visible
    window: win32.HWND,
    dpi: u32,
    window_class_flags: u32,
    window_extended_flags: u32,
    window_flags: u32,

    gamepads: [4]Gamepad_Desc,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
}

L :: intrinsics.constant_utf16_cstring

@(private="file")
window_proc :: proc "stdcall" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    result := win32.LRESULT(0)
    
    switch message {
        case win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN:
            key := Keyboard_Key(w_param)
            if int(key) > len(ctx.keyboard_keys) do return result
            if !ctx.keyboard_keys[key] do ctx.keyboard_keys_pressed[key] = true
            ctx.keyboard_keys[key] = true

            if ctx.event_callback != nil {
                repeat_count  := (l_param & 0x0000FFFF)
                already_down  := (l_param & 0x40000000) >> 30
                event := Event_Key_Down{
                    key = key,
                    repeat_count = repeat_count,
                    already_down = bool(already_down),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_CHAR:
            char := rune(w_param)

            if ctx.event_callback != nil {
                repeat_count  := (l_param & 0x0000FFFF)
                already_down  := (l_param & 0x40000000) >> 30
                event := Event_Char{
                    char = char,
                    repeat_count = repeat_count,
                    already_down = bool(already_down),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_KEYUP, win32.WM_SYSKEYUP:
            key := Keyboard_Key(w_param)
            if int(key) > len(ctx.keyboard_keys) do return result
            ctx.keyboard_keys[key] = false
            ctx.keyboard_keys_released[key] = true

            if ctx.event_callback != nil {
                event := Event_Key_Up{
                    key = key,
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_LBUTTONDOWN:
            if !ctx.left_mouse_down do ctx.left_mouse_pressed = true
            ctx.left_mouse_down = true

            if ctx.event_callback != nil {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Left_Mouse_Down{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }
            
        case win32.WM_LBUTTONUP:
            ctx.left_mouse_down= false
            ctx.left_mouse_released = true

            if ctx.event_callback != nil {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Left_Mouse_Up{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }
            
        case win32.WM_LBUTTONDBLCLK:
            ctx.left_mouse_double_click = true

            if ctx.event_callback != nil {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Left_Mouse_Up{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_RBUTTONDOWN:
            if !ctx.right_mouse_down do ctx.right_mouse_pressed = true
            ctx.right_mouse_down = true

            if ctx.event_callback != nil {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Right_Mouse_Down{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_RBUTTONUP:
            ctx.right_mouse_down = false
            ctx.right_mouse_released = true

            if ctx.event_callback != nil  {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Right_Mouse_Up{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_RBUTTONDBLCLK:
            ctx.right_mouse_double_click = true

            if ctx.event_callback != nil  {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Right_Mouse_Up{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_MBUTTONDOWN:
            if !ctx.middle_mouse_down do ctx.middle_mouse_pressed = true
            ctx.middle_mouse_down = true

            if ctx.event_callback != nil  {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Middle_Mouse_Down{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_MBUTTONUP:
            ctx.middle_mouse_down = false
            ctx.middle_mouse_released = true

            if ctx.event_callback != nil  {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Middle_Mouse_Up{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_MBUTTONDBLCLK:
            ctx.middle_mouse_double_click = true

            if ctx.event_callback != nil  {
                x := i32(l_param & 0xFFFFFFFF)
                y := i32(l_param >> 32)
                event := Event_Middle_Mouse_Up{
                    x = int(x),
                    y = int(y),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_MOUSEWHEEL:
            amount := i32(w_param >> 32)
            ctx.mouse_wheel += int(amount) * win32.WHEEL_DELTA

            if ctx.event_callback != nil  {
                event := Event_Mouse_Wheel{
                    amount = int(amount) * win32.WHEEL_DELTA,
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
            ctx.should_close = true

        case:
            result = win32.DefWindowProcW(window, message, w_param, l_param)
    }

    return result
}

foreign import user32 "system:User32.lib"

@(default_calling_convention="stdcall")
foreign user32 {
    GetDpiForSystem :: proc() -> win32.UINT ---
}

_init :: proc(loc := #caller_location) {
    ctx.visible = -1
    ctx.dpi = GetDpiForSystem()

    wname: win32.LPWSTR

    if ctx.configuration == .Game {
        if ODIN_DEBUG || ctx.width != 0 || ctx.height != 0 {
            ctx.window_flags = win32.WS_CAPTION | win32.WS_SYSMENU
            wname = win32.utf8_to_wstring(ctx.name)
        } else {
            ctx.fullscreen = true
            ctx.window_flags = win32.WS_POPUP
        }
    } else if ctx.configuration == .Tool {
        ctx.window_extended_flags = win32.WS_EX_ACCEPTFILES | win32.WS_EX_CLIENTEDGE | win32.WS_EX_WINDOWEDGE
        ctx.window_flags = win32.WS_BORDER | win32.WS_MAXIMIZE | win32.WS_OVERLAPPEDWINDOW
        wname = win32.utf8_to_wstring(ctx.name)
    }

    module_handle := win32.HANDLE(win32.GetModuleHandleW(nil))
    if module_handle == nil do log.panicf("Failed to get module handle. %v", misc.get_last_error_message())
    log.info("Succeeded to get module handle.")

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        style = ctx.window_class_flags,
        lpfnWndProc = window_proc,
        hInstance = module_handle,
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do log.panicf("Failed to register window class. %v", misc.get_last_error_message())
    log.info("Succeeded to register window class.")

    ctx.window = win32.CreateWindowExW(
        ctx.window_extended_flags, 
        window_class.lpszClassName, 
        wname, 
        ctx.window_flags, 
        win32.CW_USEDEFAULT, 
        win32.CW_USEDEFAULT, 
        win32.CW_USEDEFAULT, 
        win32.CW_USEDEFAULT, 
        nil, 
        nil, 
        window_class.hInstance, 
        nil)
    if ctx.window == nil do log.panicf("Failed to create window. %v", misc.get_last_error_message())
    log.info("Succeeded to create window.")

    monitor := win32.MonitorFromWindow(ctx.window, .MONITOR_DEFAULTTOPRIMARY)
    monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
    ok := win32.GetMonitorInfoW(monitor, &monitor_info)
    if !ok do log.errorf("Failed to get monitor info. %v", misc.get_last_error_message())
    else {
        log.info("Succeeded to get monitor info.")

        client_width, client_height, client_left, client_right, client_top, client_bottom: i32

        if ctx.window_flags & win32.WS_POPUP == 0 {
            client_width = ctx.width == 0 ? (monitor_info.rcMonitor.right - monitor_info.rcMonitor.left) / 2 : i32(ctx.width)
            client_height = ctx.height == 0 ? (monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top) / 2 : i32(ctx.height)

            client_left = monitor_info.rcMonitor.left + (client_width / 2)
            client_top = monitor_info.rcMonitor.top + (client_height / 2)
            client_right = client_left + client_width
            client_bottom = client_top + client_height
        } else {
            client_width = ctx.width == 0 ? (monitor_info.rcMonitor.right - monitor_info.rcMonitor.left) : i32(ctx.width)
            client_height = ctx.height == 0 ? (monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top) : i32(ctx.height)

            client_left = 0
            client_top = 0
            client_right = client_width
            client_bottom = client_height
        }

        window_rect := win32.RECT{client_left, client_top, client_right, client_bottom}
        ok = win32.AdjustWindowRectExForDpi(&window_rect, ctx.window_flags, false, ctx.window_extended_flags, ctx.dpi)
        if !ok do log.errorf("Failed to adjust window rectangle. %v", misc.get_last_error_message())
        else {
            log.info("Succeeded to adjust window rectangle.")

            ok = win32.SetWindowPos(ctx.window, nil, window_rect.left, window_rect.top, window_rect.right - window_rect.left, window_rect.bottom - window_rect.top, 0)
            if !ok do log.errorf("Failed to set window position. %v", misc.get_last_error_message())
            else {
                log.info("Succeeded to set window position.")

                rect: win32.RECT = ---
                ok = win32.GetClientRect(ctx.window, &rect)
                if !ok do log.errorf("Failed to get client rectangle. %v", misc.get_last_error_message())
                else {
                    log.info("Succeeded to get client rectangle.")
                    ctx.width = int(rect.right - rect.left)
                    ctx.height = int(rect.bottom - rect.top)
                }
            }
        }
    }

    ctx.can_connect_gamepad = xinput.init()
}

_should_close :: proc() -> bool {
    if ctx.visible == -1 do ctx.visible += 1
    else if ctx.visible == 0 {
        log.info("Window shown.")
        ctx.visible += 1
        win32.ShowWindow(ctx.window, win32.SW_SHOW)
    }
    for {
        message: win32.MSG
        if win32.PeekMessageW(&message, ctx.window, 0, 0, win32.PM_REMOVE) {
            win32.TranslateMessage(&message)
            win32.DispatchMessageW(&message)
            continue
        }
        break
    }

    return ctx.should_close
}

_render :: proc(bitmap: []u32) {
    // TODO(pJotoro): find a more efficient way to do this.
    for &pixel in bitmap {
        if pixel != 0 do pixel = rgba_to_bgr(pixel)
    }
    hdc := win32.GetDC(ctx.window)
    if hdc == nil do log.panic("Failed to get window device context.")
    bitmap_info: win32.BITMAPINFO
    bitmap_info.bmiHeader = win32.BITMAPINFOHEADER{
        biSize = size_of(win32.BITMAPINFOHEADER),
        biWidth = i32(ctx.width),
        biHeight = i32(ctx.height),
        biPlanes = 1,
        biBitCount = 32,
        biCompression = win32.BI_RGB,
    }
    result := win32.StretchDIBits(hdc, 0, 0, i32(ctx.width), i32(ctx.height), 0, 0, i32(ctx.width), i32(ctx.height), raw_data(bitmap), &bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY)
    if result == 0 do log.panic("Failed to render bitmap.")
    result = win32.ReleaseDC(ctx.window, hdc)
    if result == 0 do log.panic("Failed to release window device context.")

    rgba_to_bgr_u8 :: #force_inline proc "contextless" (r, g, b, a: u8) -> (bgr: u32) {
        src_r := r != 0 ? f32(r) / 255 : 0
        src_g := g != 0 ? f32(g) / 255 : 0
        src_b := b != 0 ? f32(b) / 255 : 0
        src_a := a != 0 ? f32(a) / 255 : 0
    
        /*
        Target.R = 1 - Source.A + (Source.A * Source.R)
        Target.G = 1 - Source.A + (Source.A * Source.G)
        Target.B = 1 - Source.A + (Source.A * Source.B)
        */
    
        dst_r := 1 - src_a + (src_a * src_r)
        dst_g := 1 - src_a + (src_a * src_g)
        dst_b := 1 - src_a + (src_a * src_b)
    
        dst_r_u32 := u32(dst_r * 255)
        dst_g_u32 := u32(dst_g * 255)
        dst_b_u32 := u32(dst_b * 255)
    
        bgr = (dst_r_u32 << 16) | (dst_g_u32 << 8) | (dst_b_u32)
        return
    }
    
    rgba_to_bgr_u32 :: #force_inline proc "contextless" (rgba: u32) -> (bgr: u32) {
        r := u8((rgba & 0x000000FF) >> 0)
        g := u8((rgba & 0x0000FF00) >> 8)
        b := u8((rgba & 0x00FF0000) >> 16)
        a := u8((rgba & 0xFF000000) >> 24)
        bgr = rgba_to_bgr_u8(r, g, b, a)
        return
    }
    
    rgba_to_bgr :: proc{rgba_to_bgr_u8, rgba_to_bgr_u32}
}

_mouse_position :: proc(loc := #caller_location) -> (x, y: int) {
    @static point: win32.POINT
    p := point
    ok := win32.GetCursorPos(&point)
    if !ok {
        log.error("Failed to get cursor position. Returning last cursor position instead.")
        return int(p.x), -int(p.y) + height()
    }
    ok = win32.ScreenToClient(ctx.window, &point)
    if !ok {
        log.error("Failed to convert cursor screen position to client position. Returning last cursor position instead.")
        return int(p.x), -int(p.y) + height()
    }
    return int(point.x), -int(point.y) + height() // TODO(pJotoro): Do the same for the events which return a y-position on the window
}