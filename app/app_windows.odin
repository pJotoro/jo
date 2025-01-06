#+ private
package app

import "base:runtime"
import win32 "core:sys/windows"
import "base:intrinsics"
import "core:log"

import "xinput"
import "../misc"

import "core:strings"
import "core:unicode"

/* NOTE(pJotoro): WINDOWED_FLAGS only describes the required flags for a windowed jo application. It does not contain any
 * additional flags required for e.g. being resizable.
 * FULLSCREEN_FLAGS, on the other hand, does describe all flags which may ever be enabled during fullscreen.
 */

WINDOWED_FLAGS :: win32.WS_CAPTION | win32.WS_SYSMENU
FULLSCREEN_FLAGS :: win32.WS_POPUP

OS_Specific :: struct {
    instance: win32.HINSTANCE,
    windowed_flags: u32, 
    fullscreen_rect: win32.RECT,
    cursor: win32.HCURSOR,

    windowed_x, windowed_y: win32.LONG,
    windowed_width, windowed_height: win32.LONG,

    dpi_aware: bool,

    sub_window_class: win32.WNDCLASSEXW,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
    gl_procs_initialized: bool,
}

L :: intrinsics.constant_utf16_cstring

@(private="file")
window_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    context = runtime.default_context()

    result := win32.LRESULT(0)

    get_key :: proc(vk: win32.WPARAM) -> Key {
        switch vk {
            case win32.VK_CANCEL:       return .Cancel
            case win32.VK_BACK:    return .Backspace
            case win32.VK_TAB:          return .Tab
            case win32.VK_CLEAR:        return .Clear
            case win32.VK_RETURN:        return .Enter
            case win32.VK_SHIFT:        return .Shift
            case win32.VK_CONTROL:      return .Control
            case win32.VK_MENU:          return .Alt
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
        }

        panic("Unsupported key")
    }

    switch message {
        case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
            ctx.running = false

        case win32.WM_ACTIVATE:
            w_param := transmute([4]u16)w_param
            if w_param[0] == win32.WA_INACTIVE {
                ctx.focused = false
            } else {
                ctx.focused = true
            }
            if w_param[1] == 0 {
                ctx.minimized = false
            } else {
                ctx.minimized = true
            }

        case win32.WM_SIZE:
            switch w_param {
                case win32.SIZE_MINIMIZED:
                    ctx.minimized = true
                    ctx.maximized = false
                case win32.SIZE_MAXIMIZED:
                    ctx.minimized = false
                    ctx.maximized = true
                case win32.SIZE_RESTORED:
                    ctx.minimized = false
                    ctx.maximized = false
            }

            sizes := transmute([4]i16)l_param
            ctx.width = int(sizes[0])
            ctx.height = int(sizes[1])

        case win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN:
            key := get_key(w_param)
            if !(int(key) > len(ctx.keys)) {
                if !ctx.keys[key] {
                    ctx.keys_pressed[key] = true
                    ctx.any_key_pressed = true
                }
                ctx.keys[key] = true
                ctx.any_key_down = true
            }

        case win32.WM_KEYUP, win32.WM_SYSKEYUP:
            key := get_key(w_param)
            if int(key) < len(ctx.keys) {
                ctx.keys[key] = false
                ctx.keys_released[key] = true
                ctx.any_key_released = true
            }

        case win32.WM_LBUTTONDOWN:
            if !ctx.left_mouse_down {
                ctx.left_mouse_pressed = true
            }
            ctx.left_mouse_down = true
            
        case win32.WM_LBUTTONUP:
            ctx.left_mouse_down = false
            ctx.left_mouse_released = true

        // TODO: Why are mouse double click events not happening
        // Is the mouse not captured by the window?
        case win32.WM_LBUTTONDBLCLK:
            ctx.left_mouse_double_click = true

        case win32.WM_RBUTTONDOWN:
            if !ctx.right_mouse_down {
                ctx.right_mouse_pressed = true
            }
            ctx.right_mouse_down = true

        case win32.WM_RBUTTONUP:
            ctx.right_mouse_down = false
            ctx.right_mouse_released = true

        case win32.WM_RBUTTONDBLCLK:
            ctx.right_mouse_double_click = true

        case win32.WM_MBUTTONDOWN:
            if !ctx.middle_mouse_down {
                ctx.middle_mouse_pressed = true
            }
            ctx.middle_mouse_down = true

        case win32.WM_MBUTTONUP:
            ctx.middle_mouse_down = false
            ctx.middle_mouse_released = true

        case win32.WM_MBUTTONDBLCLK:
            ctx.middle_mouse_double_click = true

        case win32.WM_MOUSEMOVE:
            params := transmute([4]i16)l_param
            ctx.mouse_position.x = int(params[0])
            ctx.mouse_position.y = int(-params[1]) + ctx.height

        case win32.WM_MOUSEWHEEL:
            WHEEL_DELTA :: 120
            amount := i16(w_param >> 16) / WHEEL_DELTA
            ctx.mouse_wheel = int(amount)

        case win32.WM_CHAR:
            // TODO: Add any_key_down and any_key_pressed for this event.
            r := rune(w_param)
            if !unicode.is_control(r) {
                strings.write_rune(&ctx.text_input, r)
            }
            
        case:
            result = win32.DefWindowProcW(window, message, w_param, l_param)
            
    }

    return result
}

foreign import user32 "system:User32.lib"

@(default_calling_convention="system", private="file")
foreign user32 {
    GetDpiForSystem :: proc() -> win32.UINT ---
    ShowCursor :: proc(bShow: win32.BOOL) -> i32 ---
    GetCursor :: proc() -> win32.HCURSOR ---
    SetCursor :: proc(hCursor: win32.HCURSOR) -> win32.HCURSOR ---
}

@(private="file")
adjust_window_rect :: proc(flags: u32, client_left, client_top, client_right, client_bottom: int, loc := #caller_location) -> (rect: win32.RECT, ok: bool) {
    rect = win32.RECT{i32(client_left), i32(client_top), i32(client_right - client_left), i32(client_bottom - client_top)}
    
    if !win32.AdjustWindowRectExForDpi(&rect, flags, false, 0, u32(ctx.dpi)) {
        log.errorf("Failed to adjust window rectangle. %v", misc.get_last_error_message(), location = loc)
    } else {
        log.debug("Succeeded to adjust window rectangle.", location = loc)
        ok = true
    }

    rect.right += rect.left
    rect.bottom += rect.top

    return
}

_init :: proc(loc := #caller_location) -> bool {
    ctx.visible = -1

    ctx.windowed_flags = WINDOWED_FLAGS
    if ctx.resizable {
        ctx.windowed_flags |= win32.WS_SIZEBOX
    }
    if ctx.minimize_box {
        ctx.windowed_flags |= win32.WS_MINIMIZEBOX
    }
    if ctx.maximize_box {
        ctx.windowed_flags |= win32.WS_MAXIMIZEBOX
    }

    ctx.cursor = GetCursor()
    
    {
        if !win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
            log.errorf("Failed to make process DPI aware. %v", misc.get_last_error_message(), location = loc)
        } else {
            log.debug("Succeeded to make process DPI aware.", location = loc)
            ctx.dpi_aware = true
        }
        ctx.dpi = int(GetDpiForSystem())
        log.infof("DPI: %v.", ctx.dpi, location = loc)
    }
    
    set_window_rect :: proc(loc := #caller_location) -> (window_rect: win32.RECT, ok: bool) {
        // Get monitor dimensions
        {
            monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
            monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
            if !win32.GetMonitorInfoW(monitor, &monitor_info) {
                log.errorf("Failed to get monitor info. %v", misc.get_last_error_message(), location = loc)
                return
            }
            else {
                log.debug("Succeeded to get monitor info.", location = loc)
            }

            ctx.monitor_width = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
            ctx.monitor_height = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
            log.infof("Monitor dimensions: %v by %v.", ctx.monitor_width, ctx.monitor_height, location = loc)
        }

        // Get window rectangle for fullscreen. NOTE: this is only to be used when switching from windowed to fullscreen, not when starting in fullscreen.
        {
            ctx.fullscreen_rect, ctx.ok_fullscreen = adjust_window_rect(FULLSCREEN_FLAGS, 0, 0, ctx.monitor_width, ctx.monitor_height, loc)
            if !ctx.ok_fullscreen {
                log.error("Cannot enter fullscreen.", location = loc)
                if ctx.fullscreen_mode == .On {
                    ctx.fullscreen_mode = .Auto
                }
            }
        }
    
        {
            switch ctx.fullscreen_mode {
                case .Auto:
                    if ctx.width == 0 && ctx.height == 0 {
                        if ODIN_DEBUG || ctx.resizable || ctx.minimize_box || ctx.maximize_box {
                            ctx.width = ctx.monitor_width / 2
                            ctx.height = ctx.monitor_height / 2
                            ctx.fullscreen = false
                        } else {
                            ctx.width = ctx.monitor_width
                            ctx.height = ctx.monitor_height
                            ctx.fullscreen = true
                        }
                    } else if ctx.width == ctx.monitor_width && ctx.height == ctx.monitor_height {
                        ctx.fullscreen = true
                    } else {
                        ctx.fullscreen = false
                    }
                case .Off:
                    if ctx.width == ctx.monitor_width && ctx.height == ctx.monitor_height {
                        log.warnf("Fullscreen is set to off, yet the window is fullscreen-sized: %v by %v. Shrinking window to %v by %v.", ctx.width, ctx.height, ctx.monitor_width / 2, ctx.monitor_height / 2, location = loc)
                        ctx.width = ctx.monitor_width / 2
                        ctx.height = ctx.monitor_height / 2
                    } else if ctx.width == 0 && ctx.height == 0 {
                        ctx.width = ctx.monitor_width / 2
                        ctx.height = ctx.monitor_height / 2
                    }
                    ctx.fullscreen = false 
                case .On:
                    ctx.width = ctx.monitor_width
                    ctx.height = ctx.monitor_height
                    ctx.fullscreen = true
            }

            log.infof("App dimensions: %v by %v.", ctx.width, ctx.height, location = loc)

            if !ctx.fullscreen {
                client_left := (ctx.monitor_width - ctx.width) / 2
                client_top := (ctx.monitor_height - ctx.height) / 2

                window_rect, ok = adjust_window_rect(ctx.windowed_flags, 
                    client_left, 
                    client_top,
                    client_left + ctx.width, 
                    client_top + ctx.height,
                    loc)
                if !ok {
                    return
                }   
            } else {
                window_rect = ctx.fullscreen_rect
            }
        }

        ok = true
        return
    }

    {
        window_rect, window_rect_ok := set_window_rect(loc)

        {
            module_handle := win32.GetModuleHandleW(nil)
            if module_handle == nil {
                log.fatalf("Failed to get module handle. %v", misc.get_last_error_message(), location = loc)
                return false
            }
            log.debug("Succeeded to get module handle.", location = loc)
            ctx.instance = win32.HINSTANCE(module_handle)
        }
        
        window_class: win32.WNDCLASSEXW
        {
            window_class = win32.WNDCLASSEXW{
                cbSize = size_of(win32.WNDCLASSEXW),
                lpfnWndProc = window_proc,
                hInstance = win32.HANDLE(ctx.instance),
                lpszClassName = L("app_class"),
            }
            if win32.RegisterClassExW(&window_class) == 0 { 
                log.fatalf("Failed to register window class. %v", misc.get_last_error_message(), location = loc)
                return false
            }
            log.debug("Succeeded to register window class.", location = loc)
        }
        
        {
            wname := win32.utf8_to_wstring(ctx.title)
            flags := ctx.windowed_flags if !ctx.fullscreen else FULLSCREEN_FLAGS

            if window_rect_ok {
                ctx.window = win32.CreateWindowExW(
                    0, 
                    window_class.lpszClassName, 
                    wname if !ctx.fullscreen else nil,
                    flags, 
                    window_rect.left, 
                    window_rect.top, 
                    window_rect.right - window_rect.left, 
                    window_rect.bottom - window_rect.top, 
                    nil, 
                    nil,
                    win32.HANDLE(ctx.instance), 
                    nil)
                
            } else {
                ctx.window = win32.CreateWindowExW(
                    0, 
                    window_class.lpszClassName, 
                    wname if !ctx.fullscreen else nil,
                    flags,
                    win32.CW_USEDEFAULT, 
                    win32.CW_USEDEFAULT, 
                    win32.CW_USEDEFAULT, 
                    win32.CW_USEDEFAULT, 
                    nil, 
                    nil, 
                    win32.HANDLE(ctx.instance), 
                    nil)
            }
            
            if ctx.window == nil {
                log.fatalf("Failed to create window. %v", misc.get_last_error_message(), location = loc)
                return false
            }
            log.debug("Succeeded to create window.", location = loc)
        }
    }

    {
        dev_mode := win32.DEVMODEW{dmSize = size_of(win32.DEVMODEW)}
        if !win32.EnumDisplaySettingsW(nil, win32.ENUM_CURRENT_SETTINGS, &dev_mode) {
            log.error("Failed to enumerate display settings.", location = loc)
        } else {
            log.debug("Succeeded to enumerate display settings.", location = loc)
            ctx.refresh_rate = int(dev_mode.dmDisplayFrequency)
            log.infof("Monitor refresh rate: %v.", ctx.refresh_rate, location = loc)
        }
    }

    ctx.can_connect_gamepad = xinput.init(loc)

    return true
}

_run :: proc(loc := #caller_location) {
    if ctx.visible == -1 {
        ctx.visible += 1
    } else if ctx.visible == 0 {
        ctx.visible += 1
        win32.ShowWindow(win32.HWND(ctx.window), win32.SW_SHOW)
        log.info("Window shown.", location = loc)
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
}

_swap_buffers :: proc(buffer: []u32, buffer_width, buffer_height: int, loc := #caller_location) {
    hdc := win32.GetDC(win32.HWND(ctx.window))
    if hdc == nil {
        log.fatal("Failed to get window device context.", location = loc)
        ctx.running = false
        return
    }

    src_width := i32(buffer_width) if buffer_width != 0 else i32(ctx.width)
    src_height := i32(buffer_height) if buffer_height != 0 else i32(ctx.height)

    bitmap_info: win32.BITMAPINFO
    bitmap_info.bmiHeader = win32.BITMAPINFOHEADER{
        biSize = size_of(win32.BITMAPINFOHEADER),
        biWidth = src_width,
        biHeight = src_height,
        biPlanes = 1,
        biBitCount = 32,
        biCompression = win32.BI_RGB,
    }
    if win32.StretchDIBits(hdc, 0, 0, i32(ctx.width), i32(ctx.height), 0, 0, src_width, src_height, raw_data(buffer), &bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY) == 0 {
        log.fatal("Failed to render bitmap.", location = loc)
        ctx.running = false
    }

    if win32.ReleaseDC(win32.HWND(ctx.window), hdc) == 0 {
        log.error("Failed to release window device context.", location = loc)
    }
}

@(private="file")
CURSOR_SHOWING : win32.DWORD : 0x00000001

_cursor_visible :: proc(loc := #caller_location) -> bool {
    info := win32.CURSORINFO{cbSize = size_of(win32.CURSORINFO)}
    if !win32.GetCursorInfo(&info) {
        log.errorf("Failed to get cursor info. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to get cursor info.", location = loc)
    return (info.flags & CURSOR_SHOWING) != 0
}

_show_cursor :: proc(loc := #caller_location) -> bool {
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
            log.error("Cannot show cursor until mouse is installed.", location = loc)
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
    display_counter: i32
    for display_counter >= 0 {
        display_counter = ShowCursor(false)
    }
    return true
}

_cursor_enabled :: proc "contextless" () -> bool {
    return GetCursor() != nil
}

_enable_cursor :: proc() -> bool {
    SetCursor(ctx.cursor)
    return true
}

_disable_cursor :: proc() -> bool {
    SetCursor(nil)
    return true
}

_set_title :: proc(title: string, loc := #caller_location) {
    wstring := win32.utf8_to_wstring(title)
    if !win32.SetWindowTextW(win32.HWND(ctx.window), wstring) {
        log.errorf("Failed to set window title to %v. %v", title, misc.get_last_error_message(), location = loc)
    } else {
        log.debugf("Succeeded to set window title to %v.", title, location = loc)
    }
}

// TODO(pJotoro): This procedure has the y-axis at the top left, at odds with the rest of the library. Change this!
_set_position :: proc(x, y: int, loc := #caller_location) {
    rect, ok := adjust_window_rect(ctx.windowed_flags, x, y, x + ctx.width, y + ctx.height, loc)
    if !ok {
        return
    }
    if !win32.SetWindowPos(win32.HWND(ctx.window), nil, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, 0) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message(), location = loc)
    } else {
        log.debug("Succeeded to set window position.", location = loc)
    }
}

_set_windowed :: proc(loc := #caller_location) -> bool {
    if win32.SetWindowLongPtrW(win32.HWND(ctx.window), win32.GWL_STYLE, int(ctx.windowed_flags)) == 0 {
        log.errorf("Failed to set window long pointer. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to set window long pointer.", location = loc)

    if ctx.windowed_x == 0 && ctx.windowed_y == 0 && ctx.windowed_width == 0 && ctx.windowed_height == 0 {
        {
            point := win32.POINT {
                i32(ctx.monitor_width) / 4,
                i32(ctx.monitor_height) / 4,
            }
            if !win32.ClientToScreen(win32.HWND(ctx.window), &point) {
                log.error("Failed to get client to screen.", location = loc)
            } else {
                log.debug("Succeeded to get client to screen.", location = loc)
                ctx.windowed_x = point.x
                ctx.windowed_y = point.y
            }
        }

        {
            point := win32.POINT {
                i32(ctx.monitor_width) / 2,
                i32(ctx.monitor_height) / 2,
            }
            if !win32.ClientToScreen(win32.HWND(ctx.window), &point) {
                log.error("Failed to get client to screen. Setting dummy width and height", location = loc)
                ctx.windowed_width = 100
                ctx.windowed_height = 100
            } else {
                log.debug("Succeeded to get client to screen.", location = loc)
                ctx.windowed_width = point.x
                ctx.windowed_height = point.y
            }
        }
    }

    if !win32.SetWindowPos(win32.HWND(ctx.window), nil, 
        i32(ctx.windowed_x), i32(ctx.windowed_y), i32(ctx.windowed_width), i32(ctx.windowed_height), 
        win32.SWP_SHOWWINDOW) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to set window position.", location = loc)

    rect: win32.RECT = ---
    if !win32.GetClientRect(win32.HWND(ctx.window), &rect) {
        log.errorf("Failed to get client rect. %v", misc.get_last_error_message(), location = loc)
    } else {
        log.debug("Succeeded to get client rect.", location = loc)
        ctx.width = int(rect.right - rect.left)
        ctx.height = int(rect.bottom - rect.top)
    }

    return true
}

_set_fullscreen :: proc(loc := #caller_location) -> bool {
    // It's not the end of the world if we don't get the window rectangle. It just means next time we enter windowed mode, the size and
    // position of the window won't be the same as last time.
    rect: win32.RECT = ---
    if !win32.GetWindowRect(win32.HWND(ctx.window), &rect) {
        log.errorf("Failed to get window rectangle. %v", misc.get_last_error_message(), location = loc)
    } else {
        log.debug("Succeeded to get window rectangle.", location = loc)
        ctx.windowed_x = rect.left
        ctx.windowed_y = rect.top
        ctx.windowed_width = rect.right - rect.left
        ctx.windowed_height = rect.bottom - rect.top
    }

    if win32.SetWindowLongPtrW(win32.HWND(ctx.window), win32.GWL_STYLE, int(FULLSCREEN_FLAGS)) == 0 {
        log.errorf("Failed to set window long pointer. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to get window long pointer.", location = loc)

    if !win32.SetWindowPos(win32.HWND(ctx.window), nil, 
        ctx.fullscreen_rect.left,
        ctx.fullscreen_rect.top,
        ctx.fullscreen_rect.right - ctx.fullscreen_rect.left,
        ctx.fullscreen_rect.bottom - ctx.fullscreen_rect.top, 
        win32.SWP_SHOWWINDOW) {
        log.errorf("Failed to set window position. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to set window position.", location = loc)

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

_restore :: proc "contextless" () -> bool {
    win32.ShowWindow(win32.HWND(ctx.window), win32.SW_RESTORE)
    return true
}