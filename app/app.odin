package app

Configuration :: enum {
    Game,
    Tool,
}

@(private)
Context :: struct {
    name: string,
    width, height: int,
    user_data: rawptr,
    configuration: Configuration,

    should_close: bool,
    
    keyboard_keys: #sparse [Keyboard_Key]bool,
    keyboard_keys_pressed: #sparse [Keyboard_Key]bool,
    keyboard_keys_released: #sparse [Keyboard_Key]bool,
    fullscreen: bool,

    event_callback: Event_Callback,

    using os_specific: OS_Specific,
}
@(private)
ctx: Context

init :: proc(title := "", width := 0, height := 0, event_callback: Event_Callback = nil, user_data: rawptr = nil, configuration: Configuration = .Game, loc := #caller_location) {
    ctx.name = title
    ctx.width = width
    ctx.height = height
    ctx.event_callback = event_callback
    ctx.user_data = user_data
    ctx.configuration = configuration

    _init(loc)
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