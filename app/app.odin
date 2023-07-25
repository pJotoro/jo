package app

import win32 "core:sys/windows"
import "core:intrinsics"
import "core:runtime"
import "xinput"

@(private)
L :: intrinsics.constant_utf16_cstring

@(private)
Context :: struct {
    should_close: bool,
    visible: bool,
    window: win32.HWND,
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
@(private)
ctx: Context

window :: proc "contextless" () -> rawptr {
    return ctx.window
}

// NOTE(pJotoro): The event callback provides direct access to the OS events. In other words, the events don't get pushed into an "event queue" before being "sent" to the user. Instead, the callback is called directly inside of the OS event callback.

Event_Key_Down :: struct {
    key: Keyboard_Key,
    repeat_count: u16,
    oem_scan_code: u8,
    already_down: bool,
}

Event_Key_Up :: struct {
    key: Keyboard_Key,
    oem_scan_code: u8,
}

Event :: union {
    Event_Key_Down,
    Event_Key_Up,
}

Event_Callback :: #type proc(event: Event)

@(private)
window_proc :: proc "stdcall" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    result := win32.LRESULT(0)
    
    switch message {
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
                ctx.event_callback(event)
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
                ctx.event_callback(event)
            }

        case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
            ctx.should_close = true

        case:
            result = win32.DefWindowProcW(window, message, w_param, l_param)
    }

    return result
}

@(private)
panic :: proc(loc := #caller_location) {
    when !ODIN_DISABLE_ASSERT {
        error := win32.GetLastError()
        buf: [1024]u16 = ---
        win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), size_of(buf), nil)
        message, _ := win32.wstring_to_utf8(raw_data(buf[:]), len(buf))
        runtime.panic(message, loc)
    }
}

@(private)
init_windowed :: proc(title := "", width := 0, height := 0, fps := 0, loc := #caller_location) {
    wtitle := win32.utf8_to_wstring(title)

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        lpfnWndProc = window_proc,
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do panic(loc)

    window_flags := win32.WS_CAPTION | win32.WS_SYSMENU
    ctx.window = win32.CreateWindowExW(0, window_class.lpszClassName, wtitle, window_flags, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, nil, nil)
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
    win32.AdjustWindowRect(&window_rect, window_flags, false)

    window_width := window_rect.right - window_rect.left
    window_height := window_rect.bottom - window_rect.top
    window_x := (monitor_width - window_width) / 2
    window_y := (monitor_height - window_height) / 2

    win32.SetWindowPos(ctx.window, nil, window_x, window_y, window_width, window_height, 0)
}

@(private)
init_fullscreen :: proc(fps := 0, loc := #caller_location) {
    ctx.fullscreen = true

    window_class := win32.WNDCLASSEXW{
        cbSize = size_of(win32.WNDCLASSEXW),
        lpfnWndProc = window_proc,
        lpszClassName = L("app_class_name"),
    }
    if win32.RegisterClassExW(&window_class) == 0 do panic(loc)

    window_flags := win32.WS_CAPTION | win32.WS_POPUP
    ctx.window = win32.CreateWindowExW(0, window_class.lpszClassName, nil, window_flags, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, nil, nil, nil, nil)
    if ctx.window == nil do panic(loc)

    // NOTE(pJotoro): There's no reason to panic for the rest of this procedure since it isn't necessary to make the library run at all.

    monitor := win32.MonitorFromWindow(ctx.window, .MONITOR_DEFAULTTOPRIMARY)
    monitor_info: win32.MONITORINFO
    monitor_info.cbSize = size_of(win32.MONITORINFO)
    win32.GetMonitorInfoW(monitor, &monitor_info)
    monitor_width := monitor_info.rcMonitor.right - monitor_info.rcMonitor.left
    monitor_height := monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top

    window_rect := win32.RECT{monitor_info.rcMonitor.left, monitor_info.rcMonitor.top, monitor_width, monitor_height}
    win32.AdjustWindowRect(&window_rect, window_flags, false)

    win32.SetWindowPos(ctx.window, nil, window_rect.left, window_rect.top, window_rect.right - window_rect.left, window_rect.bottom - window_rect.top, 0)

    rect: win32.RECT = ---
    win32.GetClientRect(ctx.window, &rect)
    ctx.width = int(rect.right - rect.left)
    ctx.height = int(rect.bottom - rect.top)
}

MODE :: #config(APP_MODE, 0) // 0 is automatic, 1 is windowed, and 2 is fullscreen.

init :: proc(title := "", width := 0, height := 0, fps := 0, event_callback: Event_Callback = nil, loc := #caller_location) {
    when MODE == 0 {
        when ODIN_DEBUG do init_windowed(title, width, height, fps, loc)
        else do init_fullscreen(fps, loc)
    } else when MODE == 1 {
        init_windowed(title, width, height, fps, loc)
    } else when MODE == 2 {
        init_fullscreen(fps, loc)
    } else do #assert(false)

    ctx.event_callback = event_callback

    ctx.xinput_enabled = xinput.init()
    ctx.next_gamepad_id = 4
    for gamepad in &ctx.gamepads {
        gamepad.id = INVALID_GAMEPAD
    }

    assert(condition = ctx.xinput_enabled, loc = loc)
}

should_close :: proc() -> bool {
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

render :: proc(bitmap: []u32, loc := #caller_location) {
    hdc := win32.GetDC(ctx.window)
    assert(condition = hdc != nil, loc = loc)
    bitmap_info: win32.BITMAPINFO
    bitmap_info.bmiHeader = win32.BITMAPINFOHEADER{
        biSize = size_of(win32.BITMAPINFOHEADER),
        biWidth = i32(ctx.width),
        biHeight = i32(ctx.height),
        biPlanes = 1,
        biBitCount = 32,
        biCompression = win32.BI_RGB,
    }
    assert(condition = win32.StretchDIBits(hdc, 0, 0, i32(ctx.width), i32(ctx.height), 0, 0, i32(ctx.width), i32(ctx.height), &bitmap[0], &bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY) != 0, loc = loc)
    assert(condition = win32.ReleaseDC(ctx.window, hdc) != 0, loc = loc)
}

width :: proc "contextless" () -> int {
    return ctx.width
}

height :: proc "contextless" () -> int {
    return ctx.height
}

Keyboard_Key :: enum rune {
    Left_Mouse = win32.VK_LBUTTON,
    Right_Mouse = win32.VK_RBUTTON,
    Cancel = win32.VK_CANCEL,
    Middle_Mouse = win32.VK_MBUTTON,
    X1_Mouse = win32.VK_XBUTTON1,
    X2_Mouse = win32.VK_XBUTTON2,

    Backspace = win32.VK_BACK,
    Tab = win32.VK_TAB,
    Clear = win32.VK_CLEAR,
    Enter = win32.VK_RETURN,
    Shift = win32.VK_SHIFT,
    Control = win32.VK_CONTROL,
    Alt = win32.VK_MENU,
    Pause = win32.VK_PAUSE,
    Caps_Lock = win32.VK_CAPITAL,

    IME_Kana_Mode = win32.VK_KANA,
    IME_Hangul_Mode = win32.VK_HANGUL,
    IME_On = win32.VK_IME_ON,
    IME_Junja_Mode = win32.VK_JUNJA,
    IME_Final_Mode = win32.VK_FINAL,
    IME_Hanja_Mode = win32.VK_HANJA,
    IME_Kanji_Mode = win32.VK_KANJI,
    IME_Off = win32.VK_IME_OFF,

    Escape = win32.VK_ESCAPE,

    IME_Convert = win32.VK_CONVERT,
    IME_Nonconvert = win32.VK_NONCONVERT,
    IME_Accept = win32.VK_ACCEPT,
    IME_Mode_Change_Request = win32.VK_MODECHANGE,

    Space = win32.VK_SPACE,
    Page_Up = win32.VK_PRIOR,
    Page_Down = win32.VK_NEXT,
    End = win32.VK_END,
    Home = win32.VK_HOME,

    Left = win32.VK_LEFT,
    Up = win32.VK_UP,
    Right = win32.VK_RIGHT,
    Down = win32.VK_DOWN,

    Select = win32.VK_SELECT,
    Print = win32.VK_PRINT,
    Execute = win32.VK_EXECUTE,
    Print_Screen = win32.VK_SNAPSHOT,
    Insert = win32.VK_INSERT,
    Delete = win32.VK_DELETE,
    Help = win32.VK_HELP,

    Left_Logo_Key = win32.VK_LWIN,
    Right_Logo_Key = win32.VK_RWIN,
    Applications_Key = win32.VK_APPS,

    Sleep = win32.VK_SLEEP,

    Numpad0 = win32.VK_NUMPAD0,
    Numpad1 = win32.VK_NUMPAD1,
    Numpad2 = win32.VK_NUMPAD2,
    Numpad3 = win32.VK_NUMPAD3,
    Numpad4 = win32.VK_NUMPAD4,
    Numpad5 = win32.VK_NUMPAD5,
    Numpad6 = win32.VK_NUMPAD6,
    Numpad7 = win32.VK_NUMPAD7,
    Numpad8 = win32.VK_NUMPAD8,
    Numpad9 = win32.VK_NUMPAD9,

    Multiply = win32.VK_MULTIPLY,
    Add = win32.VK_ADD,
    Separator = win32.VK_SEPARATOR,
    Subtract = win32.VK_SUBTRACT,
    Decimal = win32.VK_DECIMAL,
    Divide = win32.VK_DIVIDE,

    F1 = win32.VK_F1,
    F2 = win32.VK_F2,
    F3 = win32.VK_F3,
    F4 = win32.VK_F4,
    F5 = win32.VK_F5,
    F6 = win32.VK_F6,
    F7 = win32.VK_F7,
    F8 = win32.VK_F8,
    F9 = win32.VK_F9,
    F10 = win32.VK_F10,
    F11 = win32.VK_F11,
    F12 = win32.VK_F12,
    F13 = win32.VK_F13,
    F14 = win32.VK_F14,
    F15 = win32.VK_F15,
    F16 = win32.VK_F16,
    F17 = win32.VK_F17,
    F18 = win32.VK_F18,
    F19 = win32.VK_F19,
    F20 = win32.VK_F20,
    F21 = win32.VK_F21,
    F22 = win32.VK_F22,
    F23 = win32.VK_F23,
    F24 = win32.VK_F24,

    Numlock = win32.VK_NUMLOCK,
    Scroll = win32.VK_SCROLL,

    Left_Shift = win32.VK_LSHIFT,
    Right_Shift = win32.VK_RSHIFT,
    Left_Control = win32.VK_LCONTROL,
    Right_Control = win32.VK_RCONTROL,
    Left_Alt = win32.VK_LMENU,
    Right_Alt = win32.VK_RMENU,

    Browser_Back = win32.VK_BROWSER_BACK,
    Browser_Forward = win32.VK_BROWSER_FORWARD,
    Browser_Refresh = win32.VK_BROWSER_REFRESH,
    Browser_Stop = win32.VK_BROWSER_STOP,
    Browser_Search = win32.VK_BROWSER_SEARCH,
    Browser_Favorites = win32.VK_BROWSER_FAVORITES,
    Browser_Home = win32.VK_BROWSER_HOME,

    Volume_Mute = win32.VK_VOLUME_MUTE,
    Volume_Down = win32.VK_VOLUME_DOWN,
    Volume_Up = win32.VK_VOLUME_UP,

    Next_Media = win32.VK_MEDIA_NEXT_TRACK,
    Prev_Media = win32.VK_MEDIA_PREV_TRACK,
    Stop_Media = win32.VK_MEDIA_STOP,
    Play_Pause_Media = win32.VK_MEDIA_PLAY_PAUSE,
    Start_Mail = win32.VK_LAUNCH_MAIL,
    Select_Media = win32.VK_LAUNCH_MEDIA_SELECT,

    Start_Application_1 = win32.VK_LAUNCH_APP1,
    Start_Application_2 = win32.VK_LAUNCH_APP2,

    Oem_1 = win32.VK_OEM_1,
    Oem_Plus = win32.VK_OEM_PLUS,
    Oem_Comma = win32.VK_OEM_COMMA,
    Oem_Minus = win32.VK_OEM_MINUS,
    Oem_Period = win32.VK_OEM_PERIOD,
    Oem_2 = win32.VK_OEM_2,
    Oem_3 = win32.VK_OEM_3,
    Oem_4 = win32.VK_OEM_4,
    Oem_5 = win32.VK_OEM_5,
    Oem_6 = win32.VK_OEM_6,
    Oem_7 = win32.VK_OEM_7,
    Oem_8 = win32.VK_OEM_8,
    Oem_102 = win32.VK_OEM_102,

    IME_Process = win32.VK_PROCESSKEY,

    Packet = win32.VK_PACKET,

    Attn = win32.VK_ATTN,
    Crsel = win32.VK_CRSEL,
    Exsel = win32.VK_EXSEL,
    Erase_EOF = win32.VK_EREOF,
    Play = win32.VK_PLAY,
    Zoom = win32.VK_ZOOM,
    Pa1 = win32.VK_PA1,
    Oem_Clear = win32.VK_OEM_CLEAR,
}

@(private)
key_down_enum :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys[key]
}

@(private)
key_down_rune :: proc "contextless" (key: rune) -> bool {
    key := key >= 'a' && key <= 'z' ? key - ('a' - 'A') : key
    return ctx.keyboard_keys[Keyboard_Key(key)]
}

key_down :: proc{key_down_enum, key_down_rune}

@(private)
key_pressed_enum :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys_pressed[key]
}

@(private)
key_pressed_rune :: proc "contextless" (key: rune) -> bool {
    key := key >= 'a' && key <= 'z' ? key - ('a' - 'A') : key
    return ctx.keyboard_keys_pressed[Keyboard_Key(key)]
}

key_pressed :: proc{key_pressed_enum, key_pressed_rune}

@(private)
key_released_enum :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys_released[key]
}

@(private)
key_released_rune :: proc "contextless" (key: rune) -> bool {
    key := key >= 'a' && key <= 'z' ? key - ('a' - 'A') : key
    return ctx.keyboard_keys_released[Keyboard_Key(key)]
}

key_released :: proc{key_released_enum, key_released_rune}