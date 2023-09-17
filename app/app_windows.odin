// +private
package app

import win32 "core:sys/windows"
import "core:intrinsics"
import "core:runtime"
import "core:fmt"
import "xinput"

OS_Specific :: struct {
    visible: int, // -1 and 0 mean invisible, 1 means visible
    window: win32.HWND,
    dpi: u32,
    window_class_flags: u32,
    window_extended_flags: u32,
    window_flags: u32,

    xinput_enabled: bool,
    gamepads: [4]Gamepad_Desc,
    next_gamepad_id: Gamepad,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
}

L :: intrinsics.constant_utf16_cstring

@(private="file")
window_proc :: proc "stdcall" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    result := win32.LRESULT(0)
    
    switch message {
        case win32.WM_ACTIVATE:
            activated := b32(w_param)
            LWA_ALPHA :: 0x00000002
            if activated do win32.SetLayeredWindowAttributes(ctx.window, 0, 255, LWA_ALPHA)
            else do win32.SetLayeredWindowAttributes(ctx.window, 0, 150, LWA_ALPHA)

        /*
        case win32.WM_SIZE:
            ctx.width = int(l_param & 0xFFFF)
            ctx.height = int(l_param >> 16)
            if ctx.event_callback != nil {
                minimized, maximized: bool
                switch w_param {
                    case win32.SIZE_MAXIMIZED:
                        maximized = true
                    case win32.SIZE_MINIMIZED:
                        minimized = true
                }
                event := Event_Size{
                    minimized = minimized,
                    maximized = maximized,
                }
                ctx.event_callback(event, ctx.user_data)
            }
            */

        case win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN:
            key := Keyboard_Key(w_param)
            if !ctx.keyboard_keys[key] do ctx.keyboard_keys_pressed[key] = true
            ctx.keyboard_keys[key] = true

            if ctx.event_callback != nil {
                repeat_count  := (l_param & 0x0000FFFF)
                oem_scan_code := (l_param & 0x00FF0000) >> 16
                already_down  := (l_param & 0x40000000) >> 30
                event := Event_Key_Down{
                    key = key,
                    repeat_count = u16(repeat_count),
                    oem_scan_code = u8(oem_scan_code),
                    already_down = bool(already_down),
                }
                ctx.event_callback(event, ctx.user_data)
            }

        case win32.WM_KEYUP, win32.WM_SYSKEYUP:
            key := Keyboard_Key(w_param)
            ctx.keyboard_keys[key] = false
            ctx.keyboard_keys_released[key] = true

            if ctx.event_callback != nil {
                oem_scan_code := (l_param & 0x00FF0000) >> 16
                event := Event_Key_Up{
                    key = key,
                    oem_scan_code = u8(oem_scan_code),
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

panic :: proc(loc := #caller_location) {
    when !ODIN_DISABLE_ASSERT {
        error := win32.GetLastError()
        buf: [1024]u16 = ---
        win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), size_of(buf), nil)
        message, _ := win32.wstring_to_utf8(raw_data(buf[:]), len(buf))
        runtime.panic(message, loc)
    }
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
        when ODIN_DEBUG {
            ctx.window_class_flags = win32.CS_DROPSHADOW
            ctx.window_extended_flags = win32.WS_EX_LAYERED | win32.WS_EX_TOPMOST
            ctx.window_flags = win32.WS_CAPTION | win32.WS_SYSMENU
            wname = win32.utf8_to_wstring(ctx.name)
        } else {
            ctx.fullscreen = true
            ctx.window_flags = win32.WS_CAPTION | win32.WS_POPUP | win32.WS_MAXIMIZE
        }
    } else if ctx.configuration == .Tool {
        ctx.window_extended_flags = win32.WS_EX_ACCEPTFILES | win32.WS_EX_CLIENTEDGE | win32.WS_EX_WINDOWEDGE
        ctx.window_flags = win32.WS_BORDER | win32.WS_MAXIMIZE | win32.WS_OVERLAPPEDWINDOW
        wname = win32.utf8_to_wstring(ctx.name)
    }

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        style = ctx.window_class_flags,
        lpfnWndProc = window_proc,
        hInstance = win32.HANDLE(win32.GetModuleHandleW(nil)),
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do panic(loc)

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
    if ctx.window == nil do panic(loc)

    monitor := win32.MonitorFromWindow(ctx.window, .MONITOR_DEFAULTTOPRIMARY)
    monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
    ok := win32.GetMonitorInfoW(monitor, &monitor_info)
    assert(ok == true, "failed to get monitor info", loc)

    client_width, client_height, client_left, client_right, client_top, client_bottom: i32

    if ctx.window_flags & win32.WS_POPUP == 0 {
        client_width = ctx.width == 0 ? (monitor_info.rcMonitor.right - monitor_info.rcMonitor.left) / 2 : i32(ctx.width)
        client_height = ctx.height == 0 ? (monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top) / 2 : i32(ctx.height)

        client_left = monitor_info.rcMonitor.left + (client_width / 2)
        client_top = monitor_info.rcMonitor.top + (client_height / 2)
        client_right = monitor_info.rcMonitor.right - (client_width / 2)
        client_bottom = monitor_info.rcMonitor.bottom - (client_height / 2)
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
    if !ok do panic(loc)

    ok = win32.SetWindowPos(ctx.window, nil, window_rect.left, window_rect.top, window_rect.right - window_rect.left, window_rect.bottom - window_rect.top, 0)
    if !ok do panic(loc)

    rect: win32.RECT = ---
    ok = win32.GetClientRect(ctx.window, &rect)
    if !ok do panic(loc)
    if ctx.width != 0 do fmt.assertf(ctx.width == int(rect.right - rect.left), "incorrectly set window width! window_rect = %v, client_rect = %v, ctx.width = %v, ctx.height = %v", window_rect, rect, ctx.width, ctx.height)
    ctx.width = int(rect.right - rect.left)
    if ctx.height != 0 do fmt.assertf(ctx.height == int(rect.bottom - rect.top), "incorrectly set window height! window_rect = %v, client_rect = %v, ctx.width = %v, ctx.height = %v", window_rect, rect, ctx.width, ctx.height)
    ctx.height = int(rect.bottom - rect.top)

    ctx.xinput_enabled = xinput.init()
    ctx.next_gamepad_id = 4
    for gamepad in &ctx.gamepads {
        gamepad.id = INVALID_GAMEPAD
    }
}

_should_close :: proc() -> bool {
    for k in &ctx.keyboard_keys_pressed do k = false
    for k in &ctx.keyboard_keys_released do k = false

    if ctx.visible == -1 do ctx.visible += 1
    else if ctx.visible == 0 {
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

    gamepads_get_input()
    
    return ctx.should_close
}

_render :: proc(bitmap: []u32, loc := #caller_location) {
    if len(bitmap) < ctx.width * ctx.height do runtime.panic("bitmap too small", loc)
    if len(bitmap) > ctx.width * ctx.height do runtime.panic("bitmap too big", loc)
    hdc := win32.GetDC(ctx.window)
    bitmap_info: win32.BITMAPINFO
    bitmap_info.bmiHeader = win32.BITMAPINFOHEADER{
        biSize = size_of(win32.BITMAPINFOHEADER),
        biWidth = i32(ctx.width),
        biHeight = i32(ctx.height),
        biPlanes = 1,
        biBitCount = 32,
        biCompression = win32.BI_RGB,
    }
    win32.StretchDIBits(hdc, 0, 0, i32(ctx.width), i32(ctx.height), 0, 0, i32(ctx.width), i32(ctx.height), raw_data(bitmap), &bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY)
    win32.ReleaseDC(ctx.window, hdc)
}

