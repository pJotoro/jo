package app

import "base:runtime"
import "core:log"

@(private)
Window :: struct {
	handle: rawptr,
	flags: u32, // OS specific
	
	title: string,
	x, y, width, height: int,
	resizable: bool,

	updated: bool,
	visible: bool,

	parent_key: runtime.Source_Code_Location,
	child_keys: [dynamic]runtime.Source_Code_Location,
}

ui_begin_window :: proc(title: string, x, y, width, height: int, resizable: bool, loc := #caller_location) -> bool {
	if loc not_in ctx.ui_windows {
		window := Window{
			title = title,
			x = x,
			y = y,
			width = width,
			height = height,
			resizable = resizable,
			visible = true,
			updated = true,
		}
		if _ui_begin_window_create(&window, title, x, y, width, height, resizable, loc) {
			window.child_keys = make([dynamic]runtime.Source_Code_Location)
			ctx.ui_windows[loc] = window
			append(&ctx.ui_parent_window_keys, loc)
			return true
		}
		return false
	} else {
		window := ctx.ui_windows[loc]
		window.updated = true
		_ui_begin_window_update(&window, title, x, y, width, height, resizable, loc)
		ctx.ui_windows[loc] = window
		append(&ctx.ui_parent_window_keys, loc)
		return true
	}
}

ui_end_window :: proc() {
	_, ok := pop_safe(&ctx.ui_parent_window_keys)
	if !ok {
		log.fatal("Failed to pop ui parent window key!")
		ctx.running = false
	}
}

ui_scoped_end_window :: proc(title: string, x, y, width, height: int, resizable: bool, loc := #caller_location, ok: bool) {
	if ok {
		ui_end_window()
	}
}

@(deferred_in_out=ui_scoped_end_window)
ui_window :: proc(title: string, x, y, width, height: int, resizable: bool, loc := #caller_location) -> bool {
	return ui_begin_window(title, x, y, width, height, resizable, loc)
}