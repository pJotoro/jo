#+ private
package app

import "core:log"

import "core:sys/wasm/js"
import "vendor:wasm/WebGL"

import "core:fmt"

OS_Specific :: struct {

}

// TODO: How to log changes happening in here?
@(private="file")
window_proc :: proc(e: js.Event) {
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

		case .Click, .Double_Click, .Mouse_Move, .Mouse_Up, .Mouse_Down:
			fmt.println(e.kind, e.data.mouse)

        case .Key_Up, .Key_Down, .Key_Press:
        	fmt.println(e.kind, e.data.key)

        case .Scroll:
        	fmt.println(e.kind, e.data.scroll)

        case .Wheel:
        	fmt.println(e.kind, e.data.wheel)

        // TODO: What's the difference between these two events?
        case .Focus, .Focus_In:
        	ctx.focused = true

        case .Focus_Out:
        	ctx.focused = false

        case .Gamepad_Connected, .Gamepad_Disconnected:
        	fmt.println(e.kind, e.data.gamepad)
	}
}

_init :: proc(loc := #caller_location) -> bool {
	ctx.visible = 1

	// TODO: What should we do with the passed width and height values?
	rect := js.window_get_rect()
	ctx.width = int(rect.width)
	ctx.height = int(rect.height)
	log.infof("App dimensions: %v by %v.", ctx.width, ctx.height, location = loc)

	ctx.dpi = int(js.device_pixel_ratio())
	log.infof("DPI: %v.", ctx.dpi, location = loc)

	// TODO
	ctx.refresh_rate = 60

	for kind in js.Event_Kind {
		js.add_window_event_listener(kind, nil, window_proc)
	}

	return true
}

_run :: proc(loc := #caller_location) {
	unimplemented()
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
	unimplemented()
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