#+ private
package app

import "core:log"
import "core:fmt"

import "core:sys/wasm/js"
import webgl "vendor:wasm/WebGL"

OS_Specific :: struct {
	using_webgl: bool,
}

// TODO: How to log changes happening in here?
@(private="file")
event_proc :: proc(e: js.Event) {
	MOUSE_LEFT :: 0
	MOUSE_MIDDLE :: 1
	MOUSE_RIGHT :: 2

	get_key :: proc(vk: string) -> Key {
		switch vk {
			case "Cancel": return .Cancel
			case "Backspace": return .Backspace
			case "Tab": return .Tab
			case "Clear": return .Clear
			case "Enter": return .Enter
			case "ShiftLeft", "ShiftRight": return .Shift
			case "ControlLeft", "ControlRight": return .Control
			case "AltLeft", "AltRight": return .Alt
			case "Pause": return .Pause
			case "CapsLock": return .Caps_Lock
			case "Escape": return .Escape
			case "Space": return .Space
			case "PageUp": return .Page_Up
			case "PageDown": return .Page_Down
			case "End": return .End
			case "Home": return .Home
			case "ArrowLeft": return .Left
			case "ArrowRight": return .Right
			case "ArrowDown": return .Down
			case "ArrowUp": return .Up
			case "Select": return .Select
			case "Print": return .Print // TODO?
			case "Execute": return .Execute
			case "PrintScreen": return .Print_Screen
			case "Insert": return .Insert
			case "Delete": return .Delete
			case "Help": return .Help
			case "Digit0": return .Zero
			case "Digit1": return .One
			case "Digit2": return .Two
			case "Digit3": return .Three
			case "Digit4": return .Four
			case "Digit5": return .Five
			case "Digit6": return .Six
			case "Digit7": return .Seven
			case "Digit8": return .Eight
			case "Digit9": return .Nine
			case "KeyA": return .A
			case "KeyB": return .B
			case "KeyC": return .C
			case "KeyD": return .D
			case "KeyE": return .E
			case "KeyF": return .F
			case "KeyG": return .G
			case "KeyH": return .H
			case "KeyI": return .I
			case "KeyJ": return .J
			case "KeyK": return .K
			case "KeyL": return .L
			case "KeyM": return .M
			case "KeyN": return .N
			case "KeyO": return .O
			case "KeyP": return .P
			case "KeyQ": return .Q
			case "KeyR": return .R
			case "KeyS": return .S
			case "KeyT": return .T
			case "KeyU": return .U
			case "KeyV": return .V
			case "KeyW": return .W
			case "KeyX": return .X
			case "KeyY": return .Y
			case "KeyZ": return .Z
			case "MetaLeft": return .Left_Logo
			case "MetaRight": return .Right_Logo
			case "MediaApps": return .Apps
			case "Standby": return .Sleep
			case "Numpad0": return .Numpad0
			case "Numpad1": return .Numpad1
			case "Numpad2": return .Numpad2
			case "Numpad3": return .Numpad3
			case "Numpad4": return .Numpad4
			case "Numpad5": return .Numpad5
			case "Numpad6": return .Numpad6
			case "Numpad7": return .Numpad7
			case "Numpad8": return .Numpad8
			case "Numpad9": return .Numpad9
			case "Multiply": return .Multiply
			case "Add": return .Add
			case "Separator": return .Separator
			case "Subtract": return .Subtract
			case "Decimal": return .Decimal
			case "Divide": return .Divide
			case "F1": return .F1
			case "F2": return .F2
			case "F3": return .F3
			case "F4": return .F4
			case "F5": return .F5
			case "F6": return .F6
			case "F7": return .F7
			case "F8": return .F8
			case "F9": return .F9
			case "F10": return .F10
			case "F11": return .F11
			case "F12": return .F12
			case "F13": return .F13
			case "F14": return .F14
			case "F15": return .F15
			case "F16": return .F16
			case "F17": return .F17
			case "F18": return .F18
			case "F19": return .F19
			case "F20": return .F20
			case "F21": return .F21
			case "F22": return .F22
			case "F23": return .F23
			case "F24": return .F24
			case "NumLock": return .Num_Lock
			case "ScrollLock": return .Scroll
			case "VolumeMute": return .Volume_Mute // TODO?
			case "VolumeDown": return .Volume_Down
			case "VolumeUp": return .Volume_Up
		}

		panic("Unkown key")
	}

	#partial switch e.kind {
		case .Invalid:
			panic("Invalid event")

		case .Error:
			panic("Error")

		case .Resize:
			rect := js.window_get_rect()
			ctx.width = int(rect.width)
			ctx.height = int(rect.height)

		case .Visibility_Change:
			is_visible := e.data.visibility_change.is_visible
			ctx.visible = 1 if is_visible else 2

		// TODO: What does this mean? Are we not in fullscreen by default?
		case .Fullscreen_Change:
		ctx.fullscreen = !ctx.fullscreen

		case .Fullscreen_Error:
			panic("Fullscreen error")

		case .Click:
			mouse := e.data.mouse
			switch mouse.button {
				case MOUSE_LEFT:
					ctx.left_mouse_pressed = true
				case MOUSE_MIDDLE:
					ctx.middle_mouse_pressed = true
				case MOUSE_RIGHT:
					ctx.right_mouse_pressed = true
			}

		case .Double_Click:
			mouse := e.data.mouse
			switch mouse.button {
				case MOUSE_LEFT:
					ctx.left_mouse_double_click = true
				case MOUSE_MIDDLE:
					ctx.middle_mouse_double_click = true
				case MOUSE_RIGHT:
					ctx.right_mouse_double_click = true
			}

		case .Mouse_Up:
			mouse := e.data.mouse
			switch mouse.button {
				case MOUSE_LEFT:
					ctx.left_mouse_released = true
					ctx.left_mouse_down = false
				case MOUSE_MIDDLE:
					ctx.middle_mouse_released = true
					ctx.middle_mouse_down = false
				case MOUSE_RIGHT:
					ctx.right_mouse_released = true
					ctx.right_mouse_down = false
			}

		case .Mouse_Down:
			mouse := e.data.mouse
			switch mouse.button {
				case MOUSE_LEFT:
					ctx.left_mouse_down = true
				case MOUSE_MIDDLE:
					ctx.middle_mouse_down = true
				case MOUSE_RIGHT:
					ctx.right_mouse_down = true
			}

		case .Mouse_Move:
			mouse := e.data.mouse
			ctx.mouse_position.x = int(mouse.client.x)
			ctx.mouse_position.y = int(mouse.client.y)

        case .Key_Down:
        	key_data := e.data.key
        	key := get_key(key_data.code)
        	ctx.keys[key] = true

        case .Key_Press:
        	key_data := e.data.key
        	key := get_key(key_data.code)
        	ctx.keys_pressed[key] = true

        case .Key_Up:
        	key_data := e.data.key
        	key := get_key(key_data.code)
        	ctx.keys_released[key] = true
        	ctx.keys[key] = false

        case .Scroll:


        case .Wheel:
        	wheel := e.data.wheel
        	assert(wheel.delta_mode == .Pixel) // TODO
        	// TODO: x and z directions too
        	if wheel.delta[1] != 0.0 {
        		WHEEL_DELTA :: 102
        		ctx.mouse_wheel = int(wheel.delta[1]) / WHEEL_DELTA
        	}

        // TODO: What's the difference between these two events?
        case .Focus, .Focus_In:
        	ctx.focused = true

        case .Focus_Out:
        	ctx.focused = false

        case .Gamepad_Connected:
        	gamepad_state := e.data.gamepad
        	gamepad := &ctx.gamepads[gamepad_state.index]
        	gamepad.active = true

        case .Gamepad_Disconnected:
        	gamepad_state := e.data.gamepad
        	gamepad := &ctx.gamepads[gamepad_state.index]
        	gamepad.active = false
	}
}

_init :: proc(loc := #caller_location) -> bool {
	ctx.visible = 1

	js.evaluate(fmt.tprintf("const canvas = document.getElementById(\"jo_canvas\"); canvas.width = %v; canvas.height = %v;", f64(ctx.width), f64(ctx.height)))

	ctx.width = int(js.get_element_key_f64("jo_canvas", "width"))
	ctx.height = int(js.get_element_key_f64("jo_canvas", "height"))
	log.infof("App dimensions: %v by %v.", ctx.width, ctx.height, location = loc)

	// TODO
	ctx.dpi = 96
	log.infof("DPI: %v.", ctx.dpi, location = loc)

	// TODO
	ctx.refresh_rate = 60

	for kind in js.Event_Kind {
		js.add_window_event_listener(kind, nil, event_proc)
	}

	// TODO
	ctx.can_connect_gamepad = true

	webgl_init :: proc() -> bool {
		webgl.CreateCurrentContextById("jo_canvas", {}) or_return
		webgl.SetCurrentContextById("jo_canvas") or_return
		return true
	}
	ctx.using_webgl = webgl_init()

	if ctx.title != "" {
		set_title(ctx.title)
	}

	ctx.app_initialized = true
	ctx.running = true

	return true
}

_run :: proc(loc := #caller_location) {
	// TODO: How exactly does visibility work? Since a window is not actually
	// being created, are we visible immediately?
	//
	// Events are already handled by adding window event listeners in _init.
}

@(export)
step :: proc(dt: f64) -> bool {
	ctx.dt = dt
	if ctx.update_proc != nil {
		ctx.update_proc(ctx.dt, ctx.update_proc_user_data)
	}
	return running()
}

_swap_buffers :: proc(buffer: []u32, buffer_width, buffer_height: int, loc := #caller_location) {
	unimplemented()
}

_cursor_visible :: proc(loc := #caller_location) -> bool {
	unimplemented()
}

_show_cursor :: proc(loc := #caller_location) -> bool {
	unimplemented()
}

_hide_cursor :: proc() -> bool {
	unimplemented()
}

_cursor_enabled :: proc "contextless" () -> bool {
	unimplemented_contextless()
}

_enable_cursor :: proc() -> bool {
	unimplemented()
}

_disable_cursor :: proc() -> bool {
	unimplemented()
}

_set_title :: proc(title: string, loc := #caller_location) {
	code := fmt.tprint("document.title = \"", title, "\"")
	js.evaluate(code)
}

_set_position :: proc(x, y: int, loc := #caller_location) {
	unimplemented()
}

_set_windowed :: proc(loc := #caller_location) -> bool {
	unimplemented()
}

_set_fullscreen :: proc(loc := #caller_location) -> bool {
	unimplemented()
}

_hide :: proc "contextless" () -> bool {
	unimplemented_contextless()
}

_show :: proc "contextless" () -> bool {
	unimplemented_contextless()
}

_minimize :: proc "contextless" () -> bool {
	unimplemented_contextless()
}

_maximize :: proc "contextless" () -> bool {
	unimplemented_contextless()
}

_restore :: proc "contextless" () -> bool {
	unimplemented_contextless()
}