//+private
package app

import win32 "core:sys/windows"
import "core:intrinsics"
import "core:runtime"
import "xinput"

Context :: struct {
    configuration: Configuration,
    user_data: rawptr,
    name: string,

    should_close: bool,
    visible: bool,
    window: win32.HWND,
    window_extended_flags: u32,
    window_flags: u32,
    width, height: int,
    keyboard_keys: #sparse [Keyboard_Key]bool,
    keyboard_keys_pressed: #sparse [Keyboard_Key]bool,
    keyboard_keys_released: #sparse [Keyboard_Key]bool,
    fullscreen: bool,

    event_callback: Event_Callback,

    xinput_enabled: bool,
    gamepads: [4]Gamepad_Desc,
    next_gamepad_id: Gamepad,

    gl_hdc: win32.HDC,
    gl_vsync: bool,
}
ctx: Context

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

@(private="file")
game_init_windowed :: proc(title := "", width := 0, height := 0, fps := 0, loc := #caller_location) {
    ctx.configuration = .Game

    wtitle := win32.utf8_to_wstring(title)

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        style = win32.CS_DROPSHADOW,
        lpfnWndProc = window_proc,
        hInstance = win32.HANDLE(win32.GetModuleHandleW(nil)),
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do panic(loc)

    ctx.window_extended_flags = win32.WS_EX_LAYERED | win32.WS_EX_TOPMOST
    ctx.window_flags = win32.WS_CAPTION | win32.WS_SYSMENU
    ctx.window = win32.CreateWindowExW(ctx.window_extended_flags, window_class.lpszClassName, wtitle, ctx.window_flags, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, window_class.hInstance, nil)
    if ctx.window == nil do panic(loc)

    // NOTE(pJotoro): There's no reason to panic for the rest of this procedure since it isn't necessary to make the library run at all.

    monitor := win32.MonitorFromWindow(ctx.window, .MONITOR_DEFAULTTOPRIMARY)
    monitor_info: win32.MONITORINFO
    monitor_info.cbSize = size_of(win32.MONITORINFO)
    win32.GetMonitorInfoW(monitor, &monitor_info)
    monitor_width := monitor_info.rcMonitor.right - monitor_info.rcMonitor.left
    monitor_height := monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top

    ctx.width = width != 0 ? width : int(monitor_width/2)
    ctx.height = height != 0 ? height : int(monitor_height/2)

    window_rect := win32.RECT{0, 0, i32(ctx.width), i32(ctx.height)}
    win32.AdjustWindowRect(&window_rect, ctx.window_flags, false)

    window_width := window_rect.right - window_rect.left
    window_height := window_rect.bottom - window_rect.top
    window_x := (monitor_width - window_width) / 2
    window_y := (monitor_height - window_height) / 2

    win32.SetWindowPos(ctx.window, nil, window_x, window_y, window_width, window_height, 0)
}

@(private="file")
game_init_fullscreen :: proc(fps := 0, loc := #caller_location) {
    ctx.configuration = .Game
    ctx.fullscreen = true

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        lpfnWndProc = window_proc,
        hInstance = win32.HANDLE(win32.GetModuleHandleW(nil)),
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do panic(loc)

    ctx.window_flags = win32.WS_POPUP | win32.WS_MAXIMIZE
    ctx.window = win32.CreateWindowExW(0, window_class.lpszClassName, nil, ctx.window_flags, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, window_class.hInstance, nil)
    if ctx.window == nil do panic(loc)

    // NOTE(pJotoro): There's no reason to panic for the rest of this procedure since it isn't necessary to make the library run at all.

    monitor := win32.MonitorFromWindow(ctx.window, .MONITOR_DEFAULTTOPRIMARY)
    monitor_info: win32.MONITORINFO
    monitor_info.cbSize = size_of(win32.MONITORINFO)
    win32.GetMonitorInfoW(monitor, &monitor_info)
    monitor_width := monitor_info.rcMonitor.right - monitor_info.rcMonitor.left
    monitor_height := monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top

    window_rect := win32.RECT{monitor_info.rcMonitor.left, monitor_info.rcMonitor.top, monitor_width, monitor_height}
    win32.AdjustWindowRect(&window_rect, ctx.window_flags, false)

    win32.SetWindowPos(ctx.window, nil, window_rect.left, window_rect.top, window_rect.right - window_rect.left, window_rect.bottom - window_rect.top, 0)

    rect: win32.RECT = ---
    win32.GetClientRect(ctx.window, &rect)
    ctx.width = int(rect.right - rect.left)
    ctx.height = int(rect.bottom - rect.top)
}

@(private="file")
tool_init :: proc(title := "", fps := 0, loc := #caller_location) {
    assert(ctx.event_callback != nil, ".Tool requires event callback", loc)
    ctx.configuration = .Tool

    wtitle := win32.utf8_to_wstring(title)

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        lpfnWndProc = window_proc,
        hInstance = win32.HANDLE(win32.GetModuleHandleW(nil)),
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do panic(loc)

    ctx.window_extended_flags = win32.WS_EX_ACCEPTFILES | win32.WS_EX_CLIENTEDGE | win32.WS_EX_WINDOWEDGE
    ctx.window_flags = win32.WS_BORDER | win32.WS_MAXIMIZE | win32.WS_OVERLAPPEDWINDOW
    ctx.window = win32.CreateWindowExW(ctx.window_extended_flags, window_class.lpszClassName, wtitle, ctx.window_flags, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, window_class.hInstance, nil)
    if ctx.window == nil do panic(loc)

    rect: win32.RECT = ---
    win32.GetClientRect(ctx.window, &rect)
    ctx.width = int(rect.right - rect.left)
    ctx.height = int(rect.bottom - rect.top)
}

_init :: proc(title := "", width := 0, height := 0, fps := 0, event_callback: Event_Callback = nil, user_data: rawptr = nil, configuration: Configuration = .Game, loc := #caller_location) {
    ctx.event_callback = event_callback
    ctx.user_data = user_data
    ctx.name = title

    if configuration == .Game {
        when ODIN_DEBUG do game_init_windowed(title, width, height, fps, loc)
        else do game_init_fullscreen(fps, loc)
    } else if configuration == .Tool {
        tool_init(title, fps, loc)
    }

    ctx.xinput_enabled = xinput.init()
    ctx.next_gamepad_id = 4
    for gamepad in &ctx.gamepads {
        gamepad.id = INVALID_GAMEPAD
    }
}

_should_close :: proc() -> bool {
    for k in &ctx.keyboard_keys_pressed do k = false
    for k in &ctx.keyboard_keys_released do k = false

    if !ctx.visible {
        flags := win32.SW_SHOW
        win32.ShowWindow(ctx.window, flags)
        ctx.visible = true
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

    for gamepad, i in &ctx.gamepads {
        if gamepad.id != INVALID_GAMEPAD {
            state: xinput.STATE = ---
            result := xinput.GetState(win32.DWORD(i), &state)
            if result != win32.ERROR_SUCCESS {
                gamepad.id = INVALID_GAMEPAD
                continue
            }
            gamepad_get_input(&gamepad, state.Gamepad)
        }
    }
    
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

