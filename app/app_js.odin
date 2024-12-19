#+ private
package app

import "core:sys/wasm/js"

OS_Specific :: struct {

}

_init :: proc(loc := #caller_location) -> bool {
	unimplemented()
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