package app

import "core:log"

mouse_x :: proc "contextless" () -> (x: int) {
    return ctx.mouse_position.x
}

mouse_y :: proc "contextless" () -> (y: int) {
    return ctx.mouse_position.y
}

mouse_position :: proc "contextless" () -> (x, y: int) {
    return ctx.mouse_position.x, ctx.mouse_position.y
}

// Actually, this returns whether the mouse is inside the window bounds.
cursor_on_screen :: proc "contextless" () -> bool {
    x, y := mouse_position()
    return x >= 0 && x < ctx.width && y >= 0 && y < ctx.height
}

cursor_enabled :: proc() -> bool {
    return ctx.cursor_enabled
}

enable_cursor :: proc(loc := #caller_location) {
    if ctx.cursor_enabled {
        log.warn("Cursor already enabled.", location = loc)
        return
    }
    if !_enable_cursor() {
        log.error("Failed to enable cursor.", location = loc)
    } else {
        log.debug("Succeeded to enable cursor.", location = loc)
        ctx.cursor_enabled = true
    }
}

disable_cursor :: proc(loc := #caller_location) {
    if !ctx.cursor_enabled {
        log.warn("Cursor already disabled.", location = loc)
        return
    }
    if !_disable_cursor() {
        log.error("Failed to disable cursor.", location = loc)
    } else {
        log.debug("Succeeded to disable cursor.", location = loc)
        ctx.cursor_enabled = false
    }
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

// Returns mouse wheel delta as a normalized floating point value.
mouse_wheel :: proc "contextless" () -> int {
    return ctx.mouse_wheel
}