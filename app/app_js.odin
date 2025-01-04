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
window_proc :: proc(e: js.Event) {
	MOUSE_LEFT :: 0
	MOUSE_MIDDLE :: 1
	MOUSE_RIGHT :: 2

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

        case .Key_Up, .Key_Down, .Key_Press:
        	// fmt.println(e.kind, e.data.key)

        case .Scroll:
        	// fmt.println(e.kind, e.data.scroll)

        case .Wheel:
        	// fmt.println(e.kind, e.data.wheel)

        // TODO: What's the difference between these two events?
        case .Focus, .Focus_In:
        	ctx.focused = true

        case .Focus_Out:
        	ctx.focused = false

        case .Gamepad_Connected, .Gamepad_Disconnected:
        	// fmt.println(e.kind, e.data.gamepad)
	}
}

_init :: proc(loc := #caller_location) -> bool {
	ctx.visible = 1

	// TODO: What should we do with the passed width and height values?
	rect := js.window_get_rect()
	ctx.width = int(rect.width)
	ctx.height = int(rect.height)
	log.infof("App dimensions: %v by %v.", ctx.width, ctx.height, location = loc)

	// TODO
	ctx.dpi = 96
	log.infof("DPI: %v.", ctx.dpi, location = loc)

	// TODO
	ctx.refresh_rate = 60

	for kind in js.Event_Kind {
		js.add_window_event_listener(kind, nil, window_proc)
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
	if !running() {
		return false
	}
	if ctx.update_proc != nil {
		ctx.update_proc(ctx.dt, ctx.update_proc_user_data)
	}
	return true
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