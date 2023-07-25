package app

MODE :: #config(APP_MODE, 0) // 0 is automatic, 1 is windowed, and 2 is fullscreen.

init :: proc(title := "", width := 0, height := 0, fps := 0, event_callback: Event_Callback = nil, loc := #caller_location) {
    _init(title, width, height, fps, event_callback, loc)
}

should_close :: proc() -> bool {
    return _should_close()
}

render :: proc(bitmap: []u32, loc := #caller_location) {
    _render(bitmap, loc)
}

window :: proc "contextless" () -> rawptr {
    return ctx.window
}

width :: proc "contextless" () -> int {
    return ctx.width
}

height :: proc "contextless" () -> int {
    return ctx.height
}