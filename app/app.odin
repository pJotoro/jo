package app

import "core:log"

@(private)
Context :: struct {
    // ----- init -----
    name: string,
    width, height: int,
    fullscreen_mode: Fullscreen_Mode,
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

    mouse_wheel: int,
    // -----------------

    // ----- gamepad -----
    can_connect_gamepad: bool,
    gamepad_debug_flags: Gamepad_Debug_Flags,
    // -------------------

    // ----- events -----
    events: [dynamic]Event,
    event_index: int,
    // ------------------

    using os_specific: OS_Specific,
}
@(private)
ctx: Context

Fullscreen_Mode :: enum {
    Auto,
    Off,
    On,
}

init :: proc(title := "", width := 0, height := 0, fullscreen := Fullscreen_Mode.Auto, allocator := context.allocator) {
    if !((width == 0 && height == 0) || (width != 0 && height != 0)) {
        log.warn("Width and height must be set or unset together.")
    } else {
        ctx.width = width
        ctx.height = height
    }

    ctx.name = title
    ctx.fullscreen_mode = fullscreen

    ctx.events = make([dynamic]Event, allocator)

    _init()

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            try_connect_gamepad(gamepad_index)
        }
    }
}

should_close :: proc() -> bool {
    for &k in ctx.keyboard_keys_pressed do k = false
    for &k in ctx.keyboard_keys_released do k = false

    ctx.left_mouse_pressed = false
    ctx.left_mouse_released = false
    ctx.right_mouse_pressed = false
    ctx.right_mouse_released = false
    ctx.middle_mouse_pressed = false
    ctx.middle_mouse_released = false

    ctx.mouse_wheel = 0

    clear(&ctx.events)
    ctx.event_index = 0

    if !_should_close() {
        if can_connect_gamepad() {
            for gamepad_index in 0..<len(ctx.gamepads) {
                if gamepad_connected(gamepad_index) do try_connect_gamepad(gamepad_index)
            }
        }

        return false
    }

    return true
}

render :: proc(bitmap: []u32) {
    // TODO(pJotoro): render should change ctx.width and/or ctx.height if the bitmap is too small.
    if len(bitmap) < width() * height() do log.panic("bitmap too small")
    if len(bitmap) > width() * height() do log.panic("bitmap too big")

    _render(bitmap)
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

mouse_wheel :: proc "contextless" () -> int {
    return ctx.mouse_wheel
}

get_event :: proc "contextless" () -> (event: Event, ok: bool) {
    if ctx.event_index >= len(ctx.events) do return
    event = ctx.events[ctx.event_index]
    ctx.event_index += 1
    ok = true
    return
}