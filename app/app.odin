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

    mouse_left: bool,
    mouse_left_pressed: bool,
    mouse_left_released: bool,
    mouse_left_double_click: bool,

    mouse_right: bool,
    mouse_right_pressed: bool,
    mouse_right_released: bool,
    mouse_right_double_click: bool,

    mouse_middle: bool,
    mouse_middle_pressed: bool,
    mouse_middle_released: bool,
    mouse_middle_double_click: bool,

    mouse_wheel_rotation: int,

    fullscreen: bool,

    event_callback: Event_Callback,

    using os_specific: OS_Specific,
}
@(private)
ctx: Context

init :: proc(title := "", width := 0, height := 0, event_callback: Event_Callback = nil, user_data: rawptr = nil, configuration: Configuration = .Game, loc := #caller_location) {
    assert((width == 0 && height == 0) || (width != 0 && height != 0), "width and height must be set or unset together", loc)

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

visible :: proc "contextless" () -> bool {
    return ctx.visible == 1 ? true : false
}

mouse_position :: proc() -> (x, y: int) {
    return _mouse_position()
}

mouse_left :: proc "contextless" () -> bool {
    return ctx.mouse_left
}

mouse_left_pressed :: proc "contextless" () -> bool {
    return ctx.mouse_left_pressed
}

mouse_left_released :: proc "contextless" () -> bool {
    return ctx.mouse_left_released
}

mouse_left_double_click :: proc "contextless" () -> bool {
    return ctx.mouse_left_double_click
}

mouse_right :: proc "contextless" () -> bool {
    return ctx.mouse_right
}

mouse_right_pressed :: proc "contextless" () -> bool {
    return ctx.mouse_right_pressed
}

mouse_right_released :: proc "contextless" () -> bool {
    return ctx.mouse_right_released
}

mouse_right_double_click :: proc "contextless" () -> bool {
    return ctx.mouse_right_double_click
}

mouse_middle :: proc "contextless" () -> bool {
    return ctx.mouse_middle
}

mouse_middle_pressed :: proc "contextless" () -> bool {
    return ctx.mouse_middle_pressed
}

mouse_middle_released :: proc "contextless" () -> bool {
    return ctx.mouse_middle_released
}

mouse_middle_double_click :: proc "contextless" () -> bool {
    return ctx.mouse_middle_double_click
}

mouse_wheel_rotation :: proc "contextless" () -> int {
    return ctx.mouse_wheel_rotation
}