package app

Configuration :: enum {
    Game,
    Tool,
}

init :: proc(title := "", width := 0, height := 0, fps := 0, event_callback: Event_Callback = nil, user_data: rawptr = nil, configuration: Configuration = .Game, loc := #caller_location) {
    _init(title, width, height, fps, event_callback, user_data, configuration, loc)
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

name :: proc "contextless" () -> string {
    return ctx.name
}

fullscreen :: proc "contextless" () -> bool {
    return ctx.fullscreen
}