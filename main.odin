package jo

import "base:intrinsics"
import "base:runtime"
import "core:time"
import "core:strings"
import "core:math"

import win32 "core:sys/windows"
L :: intrinsics.constant_utf16_cstring

JO_DEBUG :: #config(JO_DEBUG, ODIN_DEBUG)
JO_FULLSCREEN :: #config(JO_FULLSCREEN, !JO_DEBUG)
JO_TOPMOST :: #config(JO_TOPMOST, JO_FULLSCREEN)
VULKAN_DEBUG :: #config(VULKAN_DEBUG, ODIN_DEBUG)

Rect :: struct {
	x, y, w, h: int,
}

width :: proc "contextless" (ctx: Context) -> int {
	when !JO_FULLSCREEN {
		return ctx.monitor.w/2
	} else {
		return ctx.monitor.w
	}
}

height :: proc "contextless" (ctx: Context) -> int {
	when !JO_FULLSCREEN {
		return ctx.monitor.h/2
	} else {
		return ctx.monitor.h
	}
}

Context :: struct {
	running: bool,
	monitor: struct {
		w, h: int,
	},
	gamepads: [4]Gamepad,
}

main :: proc() {
	ctx: Context

	win32_cursor := win32.GetCursor()

	dpi_aware := false
	if win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
		dpi_aware = true
	}
	dpi := win32.GetDpiForSystem()

	win32_instance := win32.HINSTANCE(win32.GetModuleHandleW(nil))
	ensure(win32_instance != nil, win32_last_error_message())

	window_class := win32.WNDCLASSEXW{
	   cbSize = size_of(win32.WNDCLASSEXW),
	   lpfnWndProc = _win32_event_proc,
	   hInstance = win32.HANDLE(win32_instance),
	   lpszClassName = L("jo_class"),
	}
	{
	   res := win32.RegisterClassExW(&window_class)
	   ensure(res != 0, win32_last_error_message())
	}

	// screen dimensions
	{
	   monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
	   monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
	   res := win32.GetMonitorInfoW(monitor, &monitor_info)
	   ensure(res == true, win32_last_error_message())
	   ctx.monitor.w = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
	   ctx.monitor.h = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
	}

	// window
	win32_window: win32.HWND
	title := "jo"
	refresh_rate: int
	{
	   window_style, window_ex_style: u32
	   window_rect: Rect
	   when !JO_FULLSCREEN {
		   window_style = win32.WS_CAPTION | win32.WS_SYSMENU
		   window_ex_style = 0

		   win32_rect := win32.RECT{i32(ctx.monitor.w/4), i32(ctx.monitor.h/4), i32(ctx.monitor.w/4*3), i32(ctx.monitor.h/4*3)}

		   res := win32.AdjustWindowRectExForDpi(&win32_rect, window_style, false, window_ex_style, u32(dpi))
		   ensure(res == true, win32_last_error_message())

		   window_rect = Rect {
			   x = int(win32_rect.left),
			   y = int(win32_rect.top),
			   w = int(win32_rect.right - win32_rect.left),
			   h = int(win32_rect.bottom - win32_rect.top),
		   }
	   } else {
		   window_rect.w = ctx.monitor.w
		   window_rect.h = ctx.monitor.h
		   window_style = win32.WS_POPUP
		   window_ex_style = 0
	   }
	   when JO_TOPMOST {
		   window_ex_style |= win32.WS_EX_TOPMOST
	   }

	   win32_window = win32.CreateWindowExW(
		   window_ex_style, 
		   window_class.lpszClassName, 
		   win32.utf8_to_wstring(title),
		   window_style, 
		   i32(window_rect.x), 
		   i32(window_rect.y), 
		   i32(window_rect.w), 
		   i32(window_rect.h), 
		   nil, 
		   nil,
		   win32.HANDLE(win32_instance), 
		   nil)
	   ensure(win32_window != nil, win32_last_error_message())
	}

	// set event callback user data
	{
		win32.SetLastError(0)
		win32.SetWindowLongPtrW(win32_window, win32.GWLP_USERDATA, transmute(win32.LONG_PTR)&ctx)
		ensure(win32.GetLastError() == 0, win32_last_error_message())
	}

	{
	   dev_mode := win32.DEVMODEW{dmSize = size_of(win32.DEVMODEW)}
	   res := win32.EnumDisplaySettingsW(nil, win32.ENUM_CURRENT_SETTINGS, &dev_mode)
	   ensure(res == true, "Failed to enumerate display settings.")
	   refresh_rate = int(dev_mode.dmDisplayFrequency)
	}

	when JO_FULLSCREEN {
	   win32.SetCursor(nil)
	}

	/*
	for gamepad_index in 0..<len(ctx.gamepads) {
	   try_connect_gamepad(gamepad_index)
	}
	*/


	last_tick := time.tick_now()
	dt: f32

	ctx.running = true
	for ctx.running {
		/*
		INPUT_REMOVE :: Input{.Pressed, .Released, /*.Repeat,*/ .Double_Click}
		for &key in ctx.keys {
			if .Pressed in key && .Exit in key {
			   ctx.running = false
			   return false
			}

			key -= INPUT_REMOVE
		}
		*/

		/*
		for g_idx in 0..<len(ctx.gamepads) {
			if ctx.gamepads[g_idx].connected {
			   try_connect_gamepad(g_idx)
			}
		}
		*/

		@static window_ready := -1
		if window_ready == -1 {
			window_ready += 1
		} else if window_ready == 0 {
			window_ready += 1
			win32.ShowWindow(win32_window, win32.SW_SHOW)
		}

		for {
			message: win32.MSG
			if win32.PeekMessageW(&message, win32_window, 0, 0, win32.PM_REMOVE) {
			   win32.TranslateMessage(&message)
			   win32.DispatchMessageW(&message)
			   continue
			}
			break
		}

		tick := time.tick_now()
		dt_dur := time.tick_diff(last_tick, tick)
		last_tick = tick
		dt = f32(dt_dur)/f32(time.Second)

		// TODO: update
	}

}


_win32_event_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
	context = runtime.default_context()

	// It is possible that the window pointer has not been set yet, because Windows already pushed events before that.
	ctx := transmute(^Context)win32.GetWindowLongPtrW(window, win32.GWLP_USERDATA)
	if ctx == nil {
		return win32.DefWindowProcW(window, message, w_param, l_param)
	}

	result := win32.LRESULT(0)

	switch message {
		case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
			ctx.running = false

/*
		case win32.WM_KEYDOWN:

		case win32.WM_KEYUP:
*/  

		case:
			result = win32.DefWindowProcW(window, message, w_param, l_param)
			
	}

	return result
}

win32_last_error_message :: proc() -> (string, runtime.Allocator_Error) #optional_allocator_error {
	error := win32.GetLastError()
	buf: [512]u16 = ---
	win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
	res, err := win32.wstring_to_utf8(cstring16(raw_data(buf[:])), -1)
	return strings.trim_suffix(res, "\n"), err
}

win32_hresult_message :: proc(hr: win32.HRESULT) -> (string, runtime.Allocator_Error) #optional_allocator_error {
	buf: [512]u16 = ---
	win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, u32(hr), 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
	res, err := win32.wstring_to_utf8(cstring16(raw_data(buf[:])), -1)
	return strings.trim_suffix(res, "\n"), err
}

Gamepad_Button :: enum u16 {
	Dpad_Up,
	Dpad_Down,
	Dpad_Left,
	Dpad_Right,
	Menu_Left,
	Menu_Right,
	Left_Stick,
	Right_Stick,
	Left_Bumper,
	Right_Bumper,
	A = 12,
	B,
	X,
	Y,
}

Gamepad_Buttons :: distinct bit_set[Gamepad_Button; u16]

Gamepad :: struct {
	connected: bool,

	buttons: Gamepad_Buttons,

	left_trigger: f32,
	right_trigger: f32,
	left_stick: [2]f32,
	right_stick: [2]f32,

	trigger_deadzone: f32,
	left_stick_deadzone: f32,
	right_stick_deadzone: f32,
}

try_connect_gamepad :: proc "contextless" (ctx: ^Context, g_idx: int) {
	state: win32.XINPUT_STATE = ---
	
	result := win32.XInputGetState(win32.XUSER(g_idx), &state)
	if result != .SUCCESS {
		ctx.gamepads[g_idx] = {}
		return
	}
	xinput_gamepad := state.Gamepad

	g := &ctx.gamepads[g_idx]
	g.connected = true

	g.buttons = transmute(Gamepad_Buttons)xinput_gamepad.wButtons
	
	g.left_trigger = f32(xinput_gamepad.bLeftTrigger)/f32(max(win32.BYTE))
	g.right_trigger = f32(xinput_gamepad.bRightTrigger)/f32(max(win32.BYTE))
	g.left_stick.x = f32(xinput_gamepad.sThumbLX)/f32(max(win32.SHORT))
	g.left_stick.y = f32(xinput_gamepad.sThumbLY)/f32(max(win32.SHORT))
	g.right_stick.x = f32(xinput_gamepad.sThumbRX)/f32(max(win32.SHORT))
	g.right_stick.y = f32(xinput_gamepad.sThumbRY)/f32(max(win32.SHORT))

	g.trigger_deadzone = f32(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD)/f32(max(win32.BYTE))
	g.left_stick_deadzone = f32(win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)/f32(max(win32.SHORT))
	g.right_stick_deadzone = f32(win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)/f32(max(win32.SHORT))

	g.left_trigger = remove_deadzone(g.left_trigger, g.trigger_deadzone)
	g.right_trigger = remove_deadzone(g.right_trigger, g.trigger_deadzone)
	g.left_stick.x = remove_deadzone(g.left_stick.x, g.left_stick_deadzone)
	g.left_stick.y = remove_deadzone(g.left_stick.y, g.left_stick_deadzone)
	g.right_stick.x = remove_deadzone(g.right_stick.x, g.right_stick_deadzone)
	g.right_stick.y = remove_deadzone(g.right_stick.y, g.right_stick_deadzone)

	g.left_stick.x, g.left_stick.y = clamp_magnitude(g.left_stick.x, g.left_stick.y)
	g.right_stick.x, g.right_stick.y = clamp_magnitude(g.right_stick.x, g.right_stick.y)

	remove_deadzone :: proc "contextless" (v, d: f32) -> f32 {
		s := math.sign(v)
		v := abs(v)
		minv := max(v-d, 0)
		maxv := 1-d
		return s*v*minv/maxv
	}

	clamp_magnitude :: proc "contextless" (x0, y0: f32) -> (x1, y1: f32) {
		squared_magnitude := x0*x0 + y0*y0
		if squared_magnitude > 1 {
			scale := 1.0 / math.sqrt(squared_magnitude)
			x1 = x0 * scale
			y1 = y0 * scale
		} else {
			x1 = x0
			y1 = y0 
		}
		return
	}
}

gamepad_set_vibration :: proc(ctx: ^Context, g_idx: int, left_motor, right_motor: f32, loc := #caller_location) {
	left_motor := left_motor
	right_motor := right_motor
	assert(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1, "Motors must be in range [0.0, 1.0].", loc)
	if !ctx.gamepads[g_idx].connected {
		return
	}

	xinput_vibration: win32.XINPUT_VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	res := win32.XInputSetState(win32.XUSER(g_idx), &xinput_vibration) == .SUCCESS

	assert(res, "Failed to set vibration.", loc)
}

