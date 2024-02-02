// +private
package app

import "base:runtime"
import win32 "core:sys/windows"
import "base:intrinsics"
import "core:log"
import "core:c"

import "xinput"
import "../misc"

/* NOTE(pJotoro): WINDOWED_FLAGS only describes the required flags for a windowed jo application. It does not contain any
 * additional flags required for e.g. being resizable.
 * FULLSCREEN_FLAGS, on the other hand, does describe all flags which may ever be enabled during fullscreen.
 */

WINDOWED_FLAGS :: win32.WS_CAPTION | win32.WS_SYSMENU
FULLSCREEN_FLAGS :: win32.WS_POPUP

OS_Specific :: struct {
    instance: win32.HINSTANCE,
    windowed_flags: u32, // NOTE(pJotoro): Stores flags, both required and additional, for windowed mode.
    fullscreen_rect: win32.RECT,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
}

L :: intrinsics.constant_utf16_cstring

@(private="file")
window_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    context = runtime.default_context()
    result := win32.LRESULT(0)
    
    switch message {
        case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
            ctx.running = false

        case win32.WM_ACTIVATE:
            ctx.focused = !ctx.focused
            if ctx.focused {
                append(&ctx.events, Event_Focus{})
            }
            else {
                append(&ctx.events, Event_Unfocus{})
            }

        case win32.WM_SIZE:
            sizes := transmute([4]u16)l_param
            ctx.width = int(sizes[0])
            ctx.height = int(sizes[1])
            
            event := Event_Size{}
            append(&ctx.events, event)

        case win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN:
            key := Keyboard_Key(w_param)
            if int(key) > len(ctx.keyboard_keys) {
                return result
            }
            if !ctx.keyboard_keys[key] {
                ctx.keyboard_keys_pressed[key] = true
            }
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
            if int(key) > len(ctx.keyboard_keys) {
                return result
            }
            ctx.keyboard_keys[key] = false
            ctx.keyboard_keys_released[key] = true

            event := Event_Key_Up{
                key = key,
            }
            append(&ctx.events, event)

        case win32.WM_LBUTTONDOWN:
            if !ctx.left_mouse_down {
                ctx.left_mouse_pressed = true
            }
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
            if !ctx.right_mouse_down {
                ctx.right_mouse_pressed = true
            }
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
            if !ctx.middle_mouse_down {
                ctx.middle_mouse_pressed = true
            }
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

@(default_calling_convention="system", private="file")
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

@(private="file")
adjust_window_rect :: proc(flags: u32, client_left, client_top, client_right, client_bottom: int) -> (rect: win32.RECT, ok: bool) {
    rect = win32.RECT{i32(client_left), i32(client_top), i32(client_right), i32(client_bottom)}
    if !win32.AdjustWindowRectExForDpi(&rect, flags, false, 0, u32(ctx.dpi)) {
        log.errorf("Failed to adjust window rectangle. %v", misc.get_last_error_message())
    }
    else {
        log.debug("Succeeded to adjust window rectangle.")
        ok = true
    }
    return
}

_init :: proc() {
    ctx.visible = -1

    ctx.windowed_flags = WINDOWED_FLAGS
    if ctx.resizable {
        ctx.windowed_flags |= win32.WS_SIZEBOX
    }
    
    {
        ctx.dpi = int(GetDpiForSystem())
        if !win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
            log.error("Failed to make process DPI aware.")
        } else {
            log.debug("Succeeded to make process DPI aware.")
        }
    }
    
    set_window_rect :: proc() -> (window_rect: win32.RECT, ok: bool) {
        {
            monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
            monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
            if !win32.GetMonitorInfoW(monitor, &monitor_info) {
                log.errorf("Failed to get monitor info. %v", misc.get_last_error_message())
                return
            }
            else {
                log.debug("Succeeded to get monitor info.")
            }

            ctx.monitor_width = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
            ctx.monitor_height = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
        }
    
        {
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
                    else if ctx.width == ctx.monitor_width && ctx.height == ctx.monitor_height {
                        ctx.fullscreen = true
                    } else {
                        ctx.fullscreen = false
                    }
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
        
            {
                client_left := (ctx.monitor_width - ctx.width) / 2
                client_top := (ctx.monitor_height - ctx.height) / 2
                window_rect, ok = adjust_window_rect(ctx.windowed_flags, 
                    client_left, 
                    client_top,
                    client_left + ctx.width, 
                    client_top + ctx.height)
                if !ok {
                    return
                }
        
                ctx.windowed_x = int(window_rect.left)
                ctx.windowed_y = int(window_rect.top)
            }
        
            ok_fullscreen: bool
            ctx.fullscreen_rect, ok_fullscreen = adjust_window_rect(FULLSCREEN_FLAGS, 0, 0, ctx.monitor_width, ctx.monitor_height)
            if ctx.fullscreen {
                if !ok_fullscreen {
                    ctx.fullscreen = false
                    return
                }

                window_rect = ctx.fullscreen_rect
        
                ctx.windowed_x = ctx.monitor_width / 4
                ctx.windowed_y = ctx.monitor_height / 4
            }
        }

        ok = true
        return
    }

    {
        window_rect, window_rect_ok := set_window_rect()

        {
            module_handle := win32.GetModuleHandleW(nil)
            if module_handle == nil {
                log.panicf("Failed to get module handle. %v", misc.get_last_error_message())
            }
            log.debug("Succeeded to get module handle.")
            ctx.instance = win32.HINSTANCE(module_handle)
        }
        
        window_class: win32.WNDCLASSEXW
        {
            window_class = win32.WNDCLASSEXW{
                cbSize = size_of(win32.WNDCLASSEXW),
                lpfnWndProc = window_proc,
                hInstance = win32.HANDLE(ctx.instance),
                lpszClassName = L("app_class_name"),
            }
            if win32.RegisterClassExW(&window_class) == 0 { 
                log.panicf("Failed to register window class. %v", misc.get_last_error_message())
            }
            log.debug("Succeeded to register window class.")
        }
        
        {
            wname := win32.utf8_to_wstring(ctx.title)
            flags := ctx.windowed_flags if !ctx.fullscreen else FULLSCREEN_FLAGS
            if window_rect_ok {
                ctx.window = win32.CreateWindowExW(
                    0, 
                    window_class.lpszClassName, 
                    !ctx.fullscreen ? wname : nil,
                    flags, 
                    window_rect.left, 
                    window_rect.top, 
                    window_rect.right - window_rect.left, 
                    window_rect.bottom - window_rect.top, 
                    nil, 
                    nil, 
                    window_class.hInstance, 
                    nil)
            } else {
                ctx.window = win32.CreateWindowExW(
                    0, 
                    window_class.lpszClassName, 
                    !ctx.fullscreen ? wname : nil,
                    flags,
                    win32.CW_USEDEFAULT, 
                    win32.CW_USEDEFAULT, 
                    win32.CW_USEDEFAULT, 
                    win32.CW_USEDEFAULT, 
                    nil, 
                    nil, 
                    window_class.hInstance, 
                    nil)
            }
            
            if ctx.window == nil {
                log.panicf("Failed to create window. %v", misc.get_last_error_message())
            }
            log.debug("Succeeded to create window.")
        }
    }

    {
        dev_mode := win32.DEVMODEW{dmSize = size_of(win32.DEVMODEW)}
        if !win32.EnumDisplaySettingsW(nil, win32.ENUM_CURRENT_SETTINGS, &dev_mode) {
            log.error("Failed to enumerate display settings.")
        } else {
            log.debug("Succeeded to enumerate display settings.")
            ctx.refresh_rate = int(dev_mode.dmDisplayFrequency)
            log.infof("Monitor refresh rate: %v.", ctx.refresh_rate)
        }
    }

    {
        ctx.can_connect_gamepad = xinput.init()
    }
}

_running :: proc() -> bool {
    if ctx.visible == -1 {
        ctx.visible += 1
    } else if ctx.visible == 0 {
        ctx.visible += 1
        win32.ShowWindow(win32.HWND(ctx.window), win32.SW_SHOW)
        log.info("Window shown.")
    }
    for {
        message: win32.MSG
        if win32.PeekMessageW(&message, win32.HWND(ctx.window), 0, 0, win32.PM_REMOVE) {
            win32.TranslateMessage(&message)
            win32.DispatchMessageW(&message)
            continue
        }
        break
    }

    return ctx.running
}

_swap_buffers :: proc(buffer: []u32) {
    hdc := win32.GetDC(win32.HWND(ctx.window))
    if hdc == nil {
        log.panic("Failed to get window device context.")
    }
    bitmap_info: win32.BITMAPINFO
    bitmap_info.bmiHeader = win32.BITMAPINFOHEADER{
        biSize = size_of(win32.BITMAPINFOHEADER),
        biWidth = i32(ctx.width),
        biHeight = i32(ctx.height),
        biPlanes = 1,
        biBitCount = 32,
        biCompression = win32.BI_RGB,
    }
    result := win32.StretchDIBits(hdc, 0, 0, i32(ctx.width), i32(ctx.height), 0, 0, i32(ctx.width), i32(ctx.height), raw_data(buffer), &bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY)
    if result == 0 {
        log.panic("Failed to render bitmap.")
    }
    result = win32.ReleaseDC(win32.HWND(ctx.window), hdc)
    if result == 0 {
        log.panic("Failed to release window device context.")
    }
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
    ok = win32.ScreenToClient(win32.HWND(ctx.window), &point)
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
    if display_counter >= 0 {
        return true
    }
    if display_counter == -1 {
        display_counter = ShowCursor(true)
        if display_counter == -1 {
            log.error("Cannot show cursor until mouse is installed.")
            return false
        }
    }
    for display_counter < 0 {
        display_counter = ShowCursor(true)
    }
    return true
}

_hide_cursor :: proc() -> bool {
    // NOTE(pJotoro): Horrible for the same reason _show_cursor is horrible.
    display_counter: c.int
    for display_counter >= 0 {
        display_counter = ShowCursor(false)
    }
    return true
}

_set_title :: proc(title: string) {
    wstring := win32.utf8_to_wstring(title)
    if !win32.SetWindowTextW(win32.HWND(ctx.window), wstring) {
        log.errorf("Failed to set window title to %v. %v", title, misc.get_last_error_message())
    } else {
        log.debugf("Succeeded to set window title to %v.", title)
    }
}

// TODO(pJotoro): This procedure has the y-axis at the top left, at odds with the rest of the library. Change this!
_set_position :: proc(x, y: int) -> bool {
    rect, ok := adjust_window_rect(ctx.windowed_flags, x, y, x + ctx.width, y + ctx.height)
    if !ok {
        return false
    }
    if !win32.SetWindowPos(win32.HWND(ctx.window), nil, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, 0) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message())
        return false
    }
    return true
}

_set_windowed :: proc() -> bool {
    if win32.SetWindowLongPtrW(win32.HWND(ctx.window), win32.GWL_STYLE, int(ctx.windowed_flags)) == 0 {
        log.errorf("Failed to set window long pointer. %v", misc.get_last_error_message())
        return false
    }

    if !win32.SetWindowPos(win32.HWND(ctx.window), nil, 
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
    if !win32.GetWindowRect(win32.HWND(ctx.window), &rect) {
        log.errorf("Failed to get window rectangle. %v", misc.get_last_error_message())
    } else {
        ctx.windowed_x = int(rect.left)
        ctx.windowed_y = int(rect.top)
        ctx.windowed_width = int(rect.right - rect.left)
        ctx.windowed_height = int(rect.bottom - rect.top)
    }

    if win32.SetWindowLongPtrW(win32.HWND(ctx.window), win32.GWL_STYLE, int(FULLSCREEN_FLAGS)) == 0 {
        log.errorf("Failed to set window long pointer. %v", misc.get_last_error_message())
        return false
    }

    if !win32.SetWindowPos(win32.HWND(ctx.window), nil, 
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
    win32.ShowWindow(win32.HWND(ctx.window), win32.SW_HIDE)
    return true
}

_show :: proc "contextless" () -> bool {
    win32.ShowWindow(win32.HWND(ctx.window), win32.SW_SHOW)
    return true
}

_minimize :: proc "contextless" () -> bool {
    win32.ShowWindow(win32.HWND(ctx.window), win32.SW_MINIMIZE)
    return true
}

_maximize :: proc "contextless" () -> bool {
    win32.ShowWindow(win32.HWND(ctx.window), win32.SW_MAXIMIZE)
    return true
}