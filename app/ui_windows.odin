// +private
package app

import "base:runtime"
import win32 "core:sys/windows"
import "core:log"
import "../misc"

sub_window_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
    return win32.DefWindowProcW(window, message, w_param, l_param)
}

_ui_begin_window_create :: proc(window: ^Window, title: string, x, y, width, height: int, resizable: bool, loc := #caller_location) -> bool {
	wname := win32.utf8_to_wstring(title)
	window.flags = win32.WS_SIZEBOX if resizable else 0
	window.flags |= win32.WS_VISIBLE

	parent_handle := ctx.window
	if parent_key, ok := pop_safe(&ctx.ui_parent_window_keys); ok {
		parent := ctx.ui_windows[parent_key]
		parent_handle = parent.handle
	}

	x := x
	y := y
	point := win32.POINT{i32(x), i32(y)}
	if !win32.ClientToScreen(win32.HWND(parent_handle), &point) {
		log.error("Failed to get client to screen.")
	} else {
		x = int(point.x)
		y = int(point.y)
	}

	rect, ok := adjust_window_rect(window.flags, x, y, x + width, y + height)
	if !ok {
		log.error("Failed to adjust window rectangle. %v", misc.get_last_error_message())
		return false
	}
	log.debug("Succeeded to adjust window rectangle.")

	window.handle = win32.CreateWindowExW(
		0, 
		ctx.sub_window_class.lpszClassName, 
		wname, 
		window.flags, 
		rect.left, 
		rect.top, 
		rect.right - rect.left, 
		rect.bottom - rect.top, 
		win32.HWND(parent_handle),
		nil, 
		ctx.instance, 
		nil)
	if window.handle == nil {
		log.errorf("Failed to create window. %v", misc.get_last_error_message())
		return false
	}
	log.debug("Succeeded to create window.")

	return true
}

_ui_begin_window_update :: proc(window: ^Window, title: string, x, y, width, height: int, resizable: bool, loc := #caller_location) {
	if window.title != title {
		wname := win32.utf8_to_wstring(title)
		if !win32.SetWindowTextW(win32.HWND(window.handle), wname) {
			log.error("Failed to set window title.")
		} else {
			log.debug("Succeeded to set window title.")
			window.title = title
		}
	}
	if window.x != x || window.y != y || window.width != width || window.height != height {
		rect, ok := adjust_window_rect(window.flags, x, y, x + width, y + height)
		if !ok {
			log.errorf("Failed to adjust window rectangle. %v", misc.get_last_error_message())
		} else {
			log.debug("Succeeded to adjust window rectangle.")
			window.x = int(rect.left)
			window.y = int(rect.top)
			window.width = int(rect.right - rect.left)
			window.height = int(rect.bottom - rect.top)
		}
	}
	if window.resizable != resizable {
		flags := window.flags
		if window.resizable {
			flags &= ~win32.WS_SIZEBOX
		} else {
			flags |= win32.WS_SIZEBOX
		}
		if win32.SetWindowLongW(win32.HWND(window.handle), win32.GWL_STYLE, i32(flags)) == 0 {
			log.errorf("Failed to set window long. %v", misc.get_last_error_message())
		} else {
			log.debug("Succeeded to set window long.")
			window.flags = flags
			window.resizable = resizable
		}
	}
}

_ui_update :: proc() {
	for loc, &window in ctx.ui_windows {
    	if !window.updated && window.visible {
    		win32.ShowWindow(win32.HWND(window.handle), win32.SW_HIDE)
    		window.visible = false
    	} else if window.updated && !window.visible {
    		win32.ShowWindow(win32.HWND(window.handle), win32.SW_SHOW)
    		window.visible = true
    	}

    	window.updated = false
	}
}