#+ private
package app

import "base:runtime"
import win32 "core:sys/windows"
import "base:intrinsics"
import "core:log"

import "../misc"

import "core:strings"
import "core:unicode"

import "core:time"

OS_Specific :: struct {
    instance: win32.HINSTANCE,
    cursor: win32.HCURSOR,
    dpi_aware: bool,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
    gl_procs_initialized: bool,

    window: win32.HWND,
    window_flags: u32,
    window_ready: int, // 0=no, 1=almost, 2=yes

    dt: f64,
    dt_dur: time.Duration,
}

L :: intrinsics.constant_utf16_cstring

@(private="file")
event_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
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
                ctx.open = false
            } else {
                ctx.open = true
            }

        case win32.WM_SIZE:
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
client_to_window :: proc(x, y, width, height: i32, flags: u32, loc := #caller_location) -> (rect: win32.RECT, ok: bool) {
    rect = win32.RECT{x, y, width, height}
    
    if !win32.AdjustWindowRectExForDpi(&rect, flags, false, 0, u32(ctx.dpi)) {
        log.errorf("Win32: Failed to adjust window rectangle. %v", misc.get_last_error_message(), location = loc)
    } else {
        log.debug("Win32: Succeeded to adjust window rectangle.", location = loc)
        ok = true
    }

    return
}

/*
In windowed mode:
    if width == 0 && height == 0 {
        width = screen_width / 2
        height = screen_height / 2
    } else if width > 0 && height == 0 {
        height = width*screen_height/screen_width
    } else if width == 0 && height > 0 {
        width = height*screen_width/screen_height
    } else if width > 0 && height > 0 {
        use them as is
    }

    x = (screen_width - width) / 2
    y = (screen_height - height) / 2

In maximized mode and fullscreen mode:
    x = 0
    y = 0
    width = screen_width
    height = screen_height
*/

@(private="file")
window_properties :: proc(window_mode: Window_Mode, loc := #caller_location) -> (x, y, width, height: i32, flags: u32) {
    switch wm in window_mode {
        case Window_Mode_Free:
            width = i32(wm.width)
            height = i32(wm.height)
            screen_width := i32(ctx.screen_width)
            screen_height := i32(ctx.screen_height)
            if width == 0 && height == 0 {
                width = screen_width / 2
                height = screen_height / 2
            } else if width > 0 && height == 0 {
                height = width*screen_height / screen_width
            } else if width == 0 && height > 0 {
                width = height*screen_width / screen_height
            }
            x = (screen_width - width) / 2
            y = (screen_height - height) / 2
            flags = win32.WS_CAPTION | win32.WS_SYSMENU
            if .Minimize_Box in wm.flags {
                flags |= win32.WS_MINIMIZEBOX
            }
            if .Maximize_Box in wm.flags {
                flags |= win32.WS_MAXIMIZEBOX
            }
            if .Resizable in wm.flags {
                flags |= win32.WS_SIZEBOX
            }
            rect, ok := client_to_window(x, y, width, height, flags, loc)
            if ok {
                x = rect.left
                y = rect.top
                width = rect.right
                height = rect.bottom 
            }

        case Window_Mode_Maximized:
            width = i32(ctx.screen_width)
            height = i32(ctx.screen_height)
            flags = win32.WS_CAPTION | win32.WS_SYSMENU | win32.WS_MAXIMIZE


        case Window_Mode_Fullscreen:
            width = i32(ctx.screen_width)
            height = i32(ctx.screen_height)
            flags = win32.WS_POPUP 
    }
    return
}

_init :: proc(loc := #caller_location) -> bool {
    ctx.cursor_enabled = true
    ctx.exit_key = .Escape

    // Get cursor
    ctx.cursor = GetCursor()
    
    // Get DPI
    if !win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
        log.errorf("Win32: Failed to make process DPI aware. %v", misc.get_last_error_message(), location = loc)
    } else {
        log.debug("Win32: Succeeded to make process DPI aware.", location = loc)
        ctx.dpi_aware = true
    }
    ctx.dpi = int(GetDpiForSystem())
    log.infof("DPI: %v.", ctx.dpi, location = loc)

    // Get module handle
    ctx.instance = win32.HINSTANCE(win32.GetModuleHandleW(nil))
    if ctx.instance == nil {
        log.fatalf("Failed to get module handle. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to get module handle.", location = loc)
        
    // Register window class
    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        lpfnWndProc = event_proc,
        hInstance = win32.HANDLE(ctx.instance),
        lpszClassName = L("app_class"),
    }
    if win32.RegisterClassExW(&window_class) == 0 { 
        log.fatalf("Failed to register window class. %v", misc.get_last_error_message(), location = loc)
        return false
    }
    log.debug("Succeeded to register window class.", location = loc)

    // Get screen dimensions
    {
        monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
        monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
        if !win32.GetMonitorInfoW(monitor, &monitor_info) {
            log.fatalf("Win32: Failed to get monitor info. %v", misc.get_last_error_message(), location = loc)
            return false
        }
        else {
            log.debug("Win32: Succeeded to get monitor info.", location = loc)
        }
        ctx.screen_width = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
        ctx.screen_height = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
        log.infof("Screen dimensions: %v by %v.", ctx.screen_width, ctx.screen_height, location = loc)  
    }
    
    // Create window
    {
        x, y, width, height, flags := window_properties(ctx.window_mode, loc)

        ctx.window = win32.CreateWindowExW(
            0, 
            window_class.lpszClassName, 
            win32.utf8_to_wstring(ctx.title),
            flags, 
            x, 
            y, 
            width, 
            height, 
            nil, 
            nil,
            win32.HANDLE(ctx.instance), 
            nil)
        
        if ctx.window == nil {
            log.fatalf("Failed to create window. %v", misc.get_last_error_message(), location = loc)
            return false
        }
        log.debug("Succeeded to create window.", location = loc)
        ctx.width = int(width)
        ctx.height = int(height)
        ctx.window_flags = flags
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

    return true
}

_run :: proc(loc := #caller_location) {
    if ctx.window_ready == -1 {
        ctx.window_ready += 1
    } else if ctx.window_ready == 0 {
        ctx.window_ready += 1
        win32.ShowWindow(ctx.window, win32.SW_SHOW)
        log.info("Window shown.", location = loc)
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
}

_swap_buffers :: proc(buffer: []u32, buffer_width, buffer_height: int, loc := #caller_location) {
    hdc := win32.GetDC(ctx.window)
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

    if win32.ReleaseDC(ctx.window, hdc) == 0 {
        log.error("Failed to release window device context.", location = loc)
    }
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
    if !win32.SetWindowTextW(ctx.window, wstring) {
        log.errorf("Win32: Failed to set window title to %v. %v", title, misc.get_last_error_message(), location = loc)
    } else {
        log.debugf("Win32: Succeeded to set window title to %v.", title, location = loc)
        ctx.title = title
    }
}

_set_window_mode :: proc(window_mode: Window_Mode, loc := #caller_location) -> bool {
    x, y, width, height, flags := window_properties(window_mode, loc)
    if flags != ctx.window_flags {
        if win32.SetWindowLongPtrW(ctx.window, win32.GWL_STYLE, int(flags)) == 0 {
            log.errorf("Win32: Failed to set window flags. %v", misc.get_last_error_message(), location = loc)
            return false
        }
        log.debug("Win32: Succeeded to set window flags.", location = loc)
    }
    if width != i32(ctx.width) || height != i32(ctx.height) {
        if !win32.SetWindowPos(ctx.window, nil, 
             x, y, width, height, 
            win32.SWP_SHOWWINDOW) {
            log.errorf("Win32: Failed to set window dimensions. %v", misc.get_last_error_message(), location = loc)
            return false
        }
        log.debug("Win32: Succeeded to set window dimensions.", location = loc)
    }
    ctx.width = int(width)
    ctx.height = int(height)
    return true
}