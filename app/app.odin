package app

import "core:runtime"

Configuration :: enum {
    Game,
    Tool,
}

@(private)
Context :: struct {
    allocator: runtime.Allocator,

    // ----- init -----
    name: string,
    width, height: int,
    user_data: rawptr,
    configuration: Configuration,
    event_callback: Event_Callback,

    can_connect_gamepad: bool,
    // ----------------

    // ----- running -----
    should_close: bool,
    fullscreen: bool,
    // -------------------
    
    // ----- keyboard -----
    keyboard_keys: #sparse [Keyboard_Key]bool,
    keyboard_keys_pressed: #sparse [Keyboard_Key]bool,
    keyboard_keys_released: #sparse [Keyboard_Key]bool,
    // --------------------

    // ----- mouse -----
    left_mouse_down: bool,
    left_mouse_pressed: bool,
    left_mouse_released: bool,
    left_mouse_double_click: bool,

    right_mouse_down: bool,
    right_mouse_pressed: bool,
    right_mouse_released: bool,
    right_mouse_double_click: bool,

    middle_mouse_down: bool,
    middle_mouse_pressed: bool,
    middle_mouse_released: bool,
    middle_mouse_double_click: bool,

    mouse_wheel_rotation: int,
    // -----------------

    using os_specific: OS_Specific,
}
@(private)
ctx: Context

init :: proc(title := "", width := 0, height := 0, event_callback: Event_Callback = nil, user_data: rawptr = nil, configuration: Configuration = .Game, allocator := context.allocator, loc := #caller_location) {
    assert((width == 0 && height == 0) || (width != 0 && height != 0), "width and height must be set or unset together", loc)
    ctx.allocator = allocator

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

left_mouse_down :: proc "contextless" () -> bool {
    return ctx.left_mouse_down
}

left_mouse_pressed :: proc "contextless" () -> bool {
    return ctx.left_mouse_pressed
}

left_mouse_released :: proc "contextless" () -> bool {
    return ctx.left_mouse_released
}

left_mouse_double_click :: proc "contextless" () -> bool {
    return ctx.left_mouse_double_click
}

right_mouse_down :: proc "contextless" () -> bool {
    return ctx.right_mouse_down
}

right_mouse_pressed :: proc "contextless" () -> bool {
    return ctx.right_mouse_pressed
}

right_mouse_released :: proc "contextless" () -> bool {
    return ctx.right_mouse_released
}

right_mouse_double_click :: proc "contextless" () -> bool {
    return ctx.right_mouse_double_click
}

middle_mouse_down :: proc "contextless" () -> bool {
    return ctx.middle_mouse_down
}

middle_mouse_pressed :: proc "contextless" () -> bool {
    return ctx.middle_mouse_pressed
}

middle_mouse_released :: proc "contextless" () -> bool {
    return ctx.middle_mouse_released
}

middle_mouse_double_click :: proc "contextless" () -> bool {
    return ctx.middle_mouse_double_click
}

mouse_wheel_rotation :: proc "contextless" () -> int {
    return ctx.mouse_wheel_rotation
}