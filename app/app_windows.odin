// +private
package app

import "core:runtime"
import win32 "core:sys/windows"
import "core:intrinsics"
import "core:log"
import "core:c"

import "xinput"
import "../misc"

OS_Specific :: struct {
    instance: win32.HINSTANCE,
    window: win32.HWND,
    window_class_flags: u32,
    window_extended_flags: u32,
    window_flags: u32,
    fullscreen_rect: win32.RECT,

    gamepads: [4]Gamepad_Desc,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
}

L :: intrinsics.constant_utf16_cstring

@(private="file")
window_proc :: proc "stdcall" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    context = runtime.default_context()
    result := win32.LRESULT(0)
    
    switch message {
        case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
            ctx.should_close = true

        case win32.WM_ACTIVATE:
            ctx.focused = !ctx.focused
            if ctx.focused do append(&ctx.events, Event_Focus{})
            else do append(&ctx.events, Event_Unfocus{})

        case win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN:
            key := Keyboard_Key(w_param)
            if int(key) > len(ctx.keyboard_keys) do return result
            if !ctx.keyboard_keys[key] do ctx.keyboard_keys_pressed[key] = true
            ctx.keyboard_keys[key] = true

            repeat_count  := (l_param & 0x0000FFFF)
            already_down  := (l_param & 0x40000000) >> 30
            event := Event_Key_Down{
                key = key,
                repeat_count = repeat_count,
                already_down = bool(already_down),
            }
            append(&ctx.events, event)

        case win32.WM_CHAR:
            char := rune(w_param)

            repeat_count  := (l_param & 0x0000FFFF)
            already_down  := (l_param & 0x40000000) >> 30
            event := Event_Char{
                char = char,
                repeat_count = repeat_count,
                already_down = bool(already_down),
            }
            append(&ctx.events, event)

        case win32.WM_KEYUP, win32.WM_SYSKEYUP:
            key := Keyboard_Key(w_param)
            if int(key) > len(ctx.keyboard_keys) do return result
            ctx.keyboard_keys[key] = false
            ctx.keyboard_keys_released[key] = true

            event := Event_Key_Up{
                key = key,
            }
            append(&ctx.events, event)

        case win32.WM_LBUTTONDOWN:
            if !ctx.left_mouse_down do ctx.left_mouse_pressed = true
            ctx.left_mouse_down = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Left_Mouse_Down{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)
            
        case win32.WM_LBUTTONUP:
            ctx.left_mouse_down= false
            ctx.left_mouse_released = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Left_Mouse_Up{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)
            
        case win32.WM_LBUTTONDBLCLK:
            ctx.left_mouse_double_click = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Left_Mouse_Up{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_RBUTTONDOWN:
            if !ctx.right_mouse_down do ctx.right_mouse_pressed = true
            ctx.right_mouse_down = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Right_Mouse_Down{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_RBUTTONUP:
            ctx.right_mouse_down = false
            ctx.right_mouse_released = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Right_Mouse_Up{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_RBUTTONDBLCLK:
            ctx.right_mouse_double_click = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Right_Mouse_Up{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_MBUTTONDOWN:
            if !ctx.middle_mouse_down do ctx.middle_mouse_pressed = true
            ctx.middle_mouse_down = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Middle_Mouse_Down{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_MBUTTONUP:
            ctx.middle_mouse_down = false
            ctx.middle_mouse_released = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Middle_Mouse_Up{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_MBUTTONDBLCLK:
            ctx.middle_mouse_double_click = true

            x := i16(l_param & 0xFFFF)
            y := i16(l_param >> 16)
            event := Event_Middle_Mouse_Up{
                x = int(x),
                y = -int(y) + ctx.height,
            }
            append(&ctx.events, event)

        case win32.WM_MOUSEWHEEL:
            amount := i32(w_param >> 32)
            ctx.mouse_wheel += int(amount) * win32.WHEEL_DELTA

            event := Event_Mouse_Wheel{
                amount = int(amount) * win32.WHEEL_DELTA,
            }
            append(&ctx.events, event)

        case:
            result = win32.DefWindowProcW(window, message, w_param, l_param)
    }

    return result
}

foreign import user32 "system:User32.lib"

@(default_calling_convention="stdcall", private="file")
foreign user32 {
    GetDpiForSystem :: proc() -> win32.UINT ---
    ShowCursor :: proc(bShow: win32.BOOL) -> c.int ---
    GetCursorInfo :: proc(pci: ^CURSORINFO) -> win32.BOOL ---
}

@(private="file")
CURSORINFO :: struct {
    cbSize: win32.DWORD,
    flags: win32.DWORD,
    hCursor: win32.HCURSOR,
    ptScreenPos: win32.POINT,
}

_init :: proc() {
    ctx.visible = -1
    
    {
        ctx.dpi = int(GetDpiForSystem())
        if !win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
            log.error("Failed to make process DPI aware.")
        } else {
            log.debug("Succeeded to make process DPI aware.")
        }
    }
    
    {
        monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
        monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
        ok := win32.GetMonitorInfoW(monitor, &monitor_info)
        if !ok do log.panicf("Failed to get monitor info. %v", misc.get_last_error_message()) // TODO(pJotoro): Does this have to panic?
        else do log.debug("Succeeded to get monitor info.")

        ctx.monitor_width = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
        ctx.monitor_height = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
    }

    switch ctx.fullscreen_mode {
        case .Auto:
            if ctx.width == 0 && ctx.height == 0 {
                when ODIN_DEBUG {
                    ctx.width = ctx.monitor_width / 2
                    ctx.height = ctx.monitor_height / 2
                    ctx.fullscreen = false
                } else {
                    ctx.width = ctx.monitor_width
                    ctx.height = ctx.monitor_height
                    ctx.fullscreen = true
                }
            }
            else if ctx.width == ctx.monitor_width && ctx.height == ctx.monitor_height do ctx.fullscreen = true
            else do ctx.fullscreen = false
        case .Off:
            if ctx.width == 0 && ctx.height == 0 {
                ctx.width = ctx.monitor_width / 2
                ctx.height = ctx.monitor_height / 2
            } else if ctx.width == ctx.monitor_width && ctx.height == ctx.monitor_height {
                log.warnf("Fullscreen is set to off, yet the window is fullscreen-sized: %v by %v. Shrinking window to %v by %v.", ctx.width, ctx.height, ctx.monitor_width / 2, ctx.monitor_height / 2)
                ctx.width = ctx.monitor_width / 2
                ctx.height = ctx.monitor_height / 2
            }
            ctx.fullscreen = false 
        case .On:
            ctx.width = ctx.monitor_width
            ctx.height = ctx.monitor_height
            ctx.fullscreen = true
    }

    window_flags: u32
    window_rect: win32.RECT

    ok: bool

    if !ctx.fullscreen {
        window_flags = win32.WS_CAPTION | win32.WS_SYSMENU

        client_left := (ctx.monitor_width - ctx.width) / 2
        client_top := (ctx.monitor_height - ctx.height) / 2
        window_rect = adjust_window_rect(window_flags, 
            client_left, 
            client_top,
            client_left + ctx.width, 
            client_top + ctx.height)

        ctx.windowed_x = int(window_rect.left)
        ctx.windowed_y = int(window_rect.top)
    }

    ctx.fullscreen_rect = adjust_window_rect(win32.WS_POPUP, 0, 0, ctx.monitor_width, ctx.monitor_height)
    if ctx.fullscreen {
        window_flags = win32.WS_POPUP

        window_rect = ctx.fullscreen_rect

        ctx.windowed_x = ctx.monitor_width / 4
        ctx.windowed_y = ctx.monitor_height / 4
    }

    {
        module_handle := win32.HANDLE(win32.GetModuleHandleW(nil))
        if module_handle == nil do log.panicf("Failed to get module handle. %v", misc.get_last_error_message())
        log.debug("Succeeded to get module handle.")
        ctx.instance = module_handle

        window_class := win32.WNDCLASSEXW{
            cbSize = size_of(win32.WNDCLASSEXW),
            lpfnWndProc = window_proc,
            hInstance = module_handle,
            lpszClassName = L("app_class_name"),
        }
        if win32.RegisterClassExW(&window_class) == 0 do log.panicf("Failed to register window class. %v", misc.get_last_error_message())
        log.debug("Succeeded to register window class.")

        wname := win32.utf8_to_wstring(ctx.title)
        ctx.window = win32.CreateWindowExW(
            0, 
            window_class.lpszClassName, 
            !ctx.fullscreen ? wname : nil,
            window_flags, 
            window_rect.left, 
            window_rect.top, 
            window_rect.right - window_rect.left, 
            window_rect.bottom - window_rect.top, 
            nil, 
            nil, 
            window_class.hInstance, 
            nil)
        if ctx.window == nil do log.panicf("Failed to create window. %v", misc.get_last_error_message())
        log.debug("Succeeded to create window.")
    }

    {
        dev_mode := win32.DEVMODEW{dmSize = size_of(win32.DEVMODEW)}
        if !win32.EnumDisplaySettingsW(nil, win32.ENUM_CURRENT_SETTINGS, &dev_mode) {
            log.error("Failed to enumerate display settings.")
        } else {
            log.debug("Succeeded to enumerate display settings.")
            ctx.refresh_rate = int(dev_mode.dmDisplayFrequency)
            log.infof("Refresh rate: %v.", ctx.refresh_rate)
        }
    }

    ctx.can_connect_gamepad = xinput.init()
}

_should_close :: proc() -> bool {
    if ctx.visible == -1 do ctx.visible += 1
    else if ctx.visible == 0 {
        ctx.visible += 1
        win32.ShowWindow(ctx.window, win32.SW_SHOW)
        log.info("Window shown.")
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

_cursor_position :: proc() -> (x, y: int) {
    @static point: win32.POINT
    p := point
    ok := win32.GetCursorPos(&point)
    if !ok {
        log.error("Failed to get cursor position. Returning last cursor position instead.")
        point = p
        return int(point.x), -int(point.y) + height()
    }
    ok = win32.ScreenToClient(ctx.window, &point)
    if !ok {
        log.error("Failed to convert cursor screen position to client position. Returning last cursor position instead.")
        point = p
        return int(point.x), -int(point.y) + height()
    }
    return int(point.x), -int(point.y) + height()
}

@(private="file")
CURSOR_SHOWING : win32.DWORD : 0x00000001

_cursor_visible :: proc() -> bool {
    info := CURSORINFO{cbSize = size_of(CURSORINFO)}
    if !GetCursorInfo(&info) {
        log.errorf("Failed to get cursor info. %v", misc.get_last_error_message())
        return false
    }
    return (info.flags & CURSOR_SHOWING) != 0
}

_show_cursor :: proc() -> bool {
    /*
    https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showcursor

    This function sets an internal display counter that determines whether the cursor should be displayed. 
    The cursor is displayed only if the display count is greater than or equal to 0. 
    If a mouse is installed, the initial display count is 0. 
    If no mouse is installed, the display count is –1.
    */

    // NOTE(pJotoro): I can't believe Microsoft actually designed it this way. Why isn't there a function called SetCursorDisplayCounter? 
    // If there is something like this, please do a pull request and use that instead of this nonsense.

    display_counter := ShowCursor(true)
    if display_counter >= 0 do return true
    if display_counter == -1 {
        display_counter = ShowCursor(true)
        if display_counter == -1 {
            log.error("Cannot show cursor until mouse is installed.")
            return false
        }
    }
    for display_counter < 0 do display_counter = ShowCursor(true)
    return true
}

_hide_cursor :: proc() -> bool {
    // NOTE(pJotoro): Horrible for the same reason _show_cursor is horrible.
    display_counter: c.int
    for display_counter >= 0 do display_counter = ShowCursor(false)
    return true
}

_set_title :: proc(title: string) {
    wstring := win32.utf8_to_wstring(title)
    if !win32.SetWindowTextW(ctx.window, wstring) {
        log.errorf("Failed to set window title to %v. %v", title, misc.get_last_error_message())
    } else {
        log.debugf("Succeeded to set window title to %v.", title)
    }
}

@(private)
adjust_window_rect :: proc(flags: u32, client_left, client_top, client_right, client_bottom: int) -> (rect: win32.RECT) {
    rect = win32.RECT{i32(client_left), i32(client_top), i32(client_right), i32(client_bottom)}
    if !win32.AdjustWindowRectExForDpi(&rect, flags, false, 0, u32(ctx.dpi)) {
        // TODO(pJotoro): Could I make this not panic? It is super important that this procedure call succeeds.
        log.panicf("Failed to adjust window rectangle. %v", misc.get_last_error_message())
    }
    else {
        log.debug("Succeeded to adjust window rectangle.")
    }
    return
}

_set_position :: proc(x, y: int) -> bool {
    rect := adjust_window_rect(win32.WS_CAPTION | win32.WS_SYSMENU, x, y, x + ctx.width, y + ctx.height)
    if !win32.SetWindowPos(ctx.window, nil, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, 0) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message())
        return false
    }
    return true
}

_set_windowed :: proc() -> bool {
    if win32.SetWindowLongPtrW(ctx.window, win32.GWL_STYLE, int(win32.WS_CAPTION | win32.WS_SYSMENU)) == 0 {
        log.errorf("Failed to set window long pointer. %v", misc.get_last_error_message())
        return false
    }
    if !win32.SetWindowPos(ctx.window, nil, 
        i32(ctx.windowed_x), i32(ctx.windowed_y), i32(ctx.windowed_width), i32(ctx.windowed_height), 
        win32.SWP_SHOWWINDOW) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message())
        return false
    }

    return true
}

_set_fullscreen :: proc() -> bool {
    // It's not the end of the world if we don't get the window rectangle. It just means next time we enter windowed mode, the size and
    // position of the window won't be the same as last time.
    rect: win32.RECT = ---
    if !win32.GetWindowRect(ctx.window, &rect) do log.errorf("Failed to get window rectangle. %v", misc.get_last_error_message())
    else {
        ctx.windowed_x = int(rect.left)
        ctx.windowed_y = int(rect.top)
        ctx.windowed_width = int(rect.right - rect.left)
        ctx.windowed_height = int(rect.bottom - rect.top)
    }

    if win32.SetWindowLongPtrW(ctx.window, win32.GWL_STYLE, int(win32.WS_POPUP)) == 0 {
        log.errorf("Failed to set window long pointer. %v", misc.get_last_error_message())
        return false
    }
    if !win32.SetWindowPos(ctx.window, nil, 
        ctx.fullscreen_rect.left,
        ctx.fullscreen_rect.top,
        ctx.fullscreen_rect.right - ctx.fullscreen_rect.left,
        ctx.fullscreen_rect.bottom - ctx.fullscreen_rect.top, 
        win32.SWP_SHOWWINDOW) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message())
        return false
    }

    return true
}

_hide :: proc "contextless" () -> bool {
    win32.ShowWindow(ctx.window, win32.SW_HIDE)
    return true
}

_show :: proc "contextless" () -> bool {
    win32.ShowWindow(ctx.window, win32.SW_SHOW)
    return true
}

_minimize :: proc "contextless" () -> bool {
    win32.ShowWindow(ctx.window, win32.SW_MINIMIZE)
    return true
}

_maximize :: proc "contextless" () -> bool {
    win32.ShowWindow(ctx.window, win32.SW_MAXIMIZE)
    return true
}