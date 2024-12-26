// jo:app is a stupidly easy to use platform layer. 
// If all you want is a window, an OpenGL context, and keyboard or gamepad input, then this is for you. 
// It takes inspiration from the simplicity of Raylib while still being lightweight and fairly low level.
package app

import "core:log"

import "core:text/edit"
import "core:strings"

Fullscreen_Mode :: enum {
    Auto, // windowed in debug mode, fullscreen otherwise
    Off,  // always windowed
    On,   // always fullscreen
}

// You must call this before any other procedure.
// It initializes the library.
//
// It is perfectly reasonable and acceptable to call this without passing any arguments whatsoever. 
// Reasonable defaults will be chosen for you.
//
// Leaving width and height as 0 has different meanings depending on whether fullscreen is on. 
// If fullscreen is off, then the width and height will be automatically set to half the monitor width and height, respectively. 
// If fullscreen is on, then the width and height will be automatically set to the monitor width and height, respectively.
init :: proc(title := "", width := 0, height := 0, 
             fullscreen := Fullscreen_Mode.Auto, resizable: bool = false, minimize_box: bool = false, maximize_box: bool = false, 
             loc := #caller_location) {
    if ctx.app_initialized {
        log.warn("App already initialized.", location = loc)
        return
    }

    if fullscreen == .On {
        if width != 0 || height != 0 {
            log.warn("Width and height are ignored when fullscreen is on.", location = loc)
        }
    } else if !((width == 0 && height == 0) || (width != 0 && height != 0)) {
        log.warn("Width and height must be set or unset together.", location = loc)
    } else {
        ctx.width = width
        ctx.height = height
    }
    
    ctx.title = title
    ctx.fullscreen_mode = fullscreen
    ctx.resizable = resizable
    ctx.minimize_box = minimize_box
    ctx.maximize_box = maximize_box
    ctx.cursor_enabled = true
    ctx.exit_key = .Escape

    if !_init(loc) {
        log.fatal("App failed to initialize.", location = loc)
        return
    }

    if ctx.fullscreen {
        disable_cursor(loc)
    }

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            try_connect_gamepad(gamepad_index, loc)
        }
    }

    edit.init(&ctx.text_input, context.allocator, context.allocator)
    strings.builder_init_len_cap(&ctx.text_input_buf, 0, 4096)
    edit.setup_once(&ctx.text_input, &ctx.text_input_buf)
    ctx.text_input_flags = {.Undo_Redo}

    ctx.app_initialized = true
    ctx.running = true
}

// Call this at the beginning of every frame.
//
// Beyond checking for whether the app is still running, it also gets OS events and updates input.
running :: proc(loc := #caller_location) -> bool {
    if !ctx.app_initialized {
        log.fatal("App not initialized.", location = loc)
        return false
    }

    // ----- sanity checks -----
    assert(!(ctx.width == 0 && !ctx.minimized), "width == 0", loc)
    assert(!(ctx.height == 0 && !ctx.minimized), "height == 0", loc)

    assert(ctx.dpi > 0, "dpi <= 0", loc)
    assert(ctx.refresh_rate > 0, "refresh rate <= 0", loc)

    assert(ctx.window != nil, "window == nil", loc)
    assert(ctx.monitor_width > 0, "monitor width <= 0", loc)
    assert(ctx.monitor_height > 0, "monitor height <= 0", loc)

    assert(!(ctx.fullscreen && ctx.minimized), "fullscreen && minimized", loc)
    assert(!(ctx.fullscreen && ctx.maximized), "fullscreen && maximized", loc)
    assert(!(ctx.minimized && ctx.maximized), "minimized && maximized", loc)

    assert(!(ctx.re_maximize && !ctx.fullscreen), "re-maximize && fullscreen", loc)
    // -------------------------

    if key_pressed(ctx.exit_key) {
        ctx.running = false
        return false
    }

    for &k in ctx.keyboard_keys_pressed { 
        k = false 
    }
    for &k in ctx.keyboard_keys_released { 
        k = false 
    }

    ctx.any_key_pressed = false

    ctx.left_mouse_pressed = false
    ctx.left_mouse_released = false
    ctx.right_mouse_pressed = false
    ctx.right_mouse_released = false
    ctx.middle_mouse_pressed = false
    ctx.middle_mouse_released = false

    ctx.mouse_wheel = 0

    _run(loc)

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            if gamepad_connected(gamepad_index) {
                try_connect_gamepad(gamepad_index, loc)
            }
        }
    }

    return ctx.running
}

// Call this at the end of every frame to blit a new framebuffer from the CPU.
//
// Only use this if you are doing CPU rendering, not GPU rendering. 
// So, if you are using OpenGL, Direct3D, or Vulkan, do NOT use this.
//
// This does not clear the buffer for you, so if you want it to be cleared after being blitted, you must do it yourself. 
// It is as easy as writing mem.zero_slice(buffer). 
// That said, clearing the entire buffer every frame is expensive, so it is recommended to not do this.
// The exception is if the buffer is only a small fraction of the window width, which is generally the case in a pixel art game.
swap_buffers :: proc(buffer: []u32, buffer_width := 0, buffer_height := 0, loc := #caller_location) {
    ok := true

    if !ctx.app_initialized {
        log.fatal("App not initialized.", location = loc)
        ok = false
    }
    if ctx.gl_initialized {
        log.fatal("Cannot mix software rendering with OpenGL.", location = loc)
        ctx.running = false
        ok = false
    }

    if ctx.width == 0 || ctx.height == 0 || ctx.minimized {
        ok = false
    }

    if buffer == nil {
        log.fatal("Buffer == nil.", location = loc)
        ctx.running = false
        ok = false
    }

    if !ok {
        return
    }

    _swap_buffers(buffer, buffer_width, buffer_height, loc)
}

// Returns the native window handle.
window :: proc "contextless" () -> rawptr {
    return ctx.window
}

// By client width or height, I mean the part of the window that you can actually draw into, not the entire window.

// Returns the client width in pixels.
width :: proc "contextless" () -> int {
    return ctx.width
}

// Returns the client height in pixels.
height :: proc "contextless" () -> int {
    return ctx.height
}

// Returns the monitor width in pixels.
monitor_width :: proc "contextless" () -> int {
    return ctx.monitor_width
}

// Returns the monitor height in pixels.
monitor_height :: proc "contextless" () -> int {
    return ctx.monitor_height
}

dpi :: proc "contextless" () -> int {
    return ctx.dpi
}

refresh_rate :: proc "contextless" () -> int {
    return ctx.refresh_rate
}

title :: proc "contextless" () -> string {
    return ctx.title
}

set_title :: proc(title: string, loc := #caller_location) {
    _set_title(title, loc)
}

set_position :: proc(x, y: int, loc := #caller_location) {
    if ctx.fullscreen {
        log.error("Cannot set position in fullscreen.", location = loc)
        return
    }

    _set_position(x, y, loc)
}

fullscreen :: proc "contextless" () -> bool {
    return ctx.fullscreen
}

set_windowed :: proc(loc := #caller_location) {
    if !ctx.fullscreen {
        log.warn("Already windowed.", location = loc)
        return
    }

    if !_set_windowed(loc) {
        log.error("Failed to set windowed.", location = loc)
    } else {
        log.debug("Succeeded to set windowed.", location = loc)

        ctx.fullscreen = false

        enable_cursor(loc)

        if ctx.re_maximize {
            ctx.re_maximize = false
            maximize(loc)
        }
    }
}

set_fullscreen :: proc(loc := #caller_location) {
    if ctx.fullscreen {
        log.warn("Already fullscreen.", location = loc)
        return
    }

    re_maximize := false
    if ctx.maximized {
        restore(loc)
        re_maximize = true
    }

    if !_set_fullscreen(loc) {
        log.error("Failed to set fullscreen.", location = loc)
    } else {
        log.debug("Succeeded to set fullscreen.", location = loc)

        ctx.fullscreen = true

        ctx.width = ctx.monitor_width
        ctx.height = ctx.monitor_height

        disable_cursor(loc)

        ctx.re_maximize = re_maximize
    }
}

toggle_fullscreen :: proc(loc := #caller_location) {
    if !ctx.fullscreen {
        set_fullscreen(loc)
    } else {
        set_windowed(loc)
    }
}

visible :: proc "contextless" () -> bool {
    return true if ctx.visible == 1 else false
}

hide :: proc(loc := #caller_location) {
    if ctx.visible == 2 {
        log.warn("Already hidden.", location = loc)
        return
    }

    if !_hide() {
        log.error("Failed to hide.", location = loc)
    } else {
        log.debug("Succeeded to hide.", location = loc)
        ctx.visible = 2
    }
}

show :: proc(loc := #caller_location) {
    if ctx.visible == 1 {
        log.warn("Already shown.", location = loc)
        return
    }

    if !_show() {
        log.error("Failed to show.", location = loc)
    } else {
        log.debug("Succeeded to show.", location = loc)
        ctx.visible = 1
    }
}

minimized :: proc "contextless" () -> bool {
    return ctx.minimized
}

maximized :: proc "contextless" () -> bool {
    return ctx.maximized
}

minimize :: proc(loc := #caller_location) {
    if ctx.minimized {
        log.warn("Already minimized.", location = loc)
        return
    }
    if ctx.fullscreen {
        set_windowed(loc)
    }
    
    if !_minimize() {
        log.error("Failed to minimize.", location = loc)
    } else {
        log.debug("Succeeded to minimize.", location = loc)
        ctx.minimized = true
        ctx.maximized = false
        ctx.re_maximize = false
    }
}

maximize :: proc(loc := #caller_location) {
    if ctx.maximized {
        log.warn("Already maximized.", location = loc)
        return
    }
    if ctx.fullscreen {
        set_windowed(loc)
    }

    if !_maximize() {
        log.error("Failed to maximize.", location = loc)
    } else {
        log.debug("Succeeded to maximize.", location = loc)
        ctx.maximized = true
        ctx.minimized = false
        ctx.re_maximize = false
    }
}

// un-minimize and un-maximize
restore :: proc(loc := #caller_location) {
    if !ctx.minimized && !ctx.maximized {
        log.warn("Already restored.", location = loc)
        return
    }
    if ctx.fullscreen {
        set_windowed(loc)
    }

    if !_restore() {
        log.error("Failed to restore.", location = loc)
    } else {
        log.debug("Succeeded to restore.", location = loc)
        ctx.minimized = false
        ctx.maximized = false
        ctx.re_maximize = false
    }
}

focused :: proc "contextless" () -> bool {
    return ctx.focused
}

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

cursor_visible :: proc(loc := #caller_location) -> bool {
    return _cursor_visible(loc)
}

show_cursor :: proc(loc := #caller_location) {
    if cursor_visible(loc) {
        log.warn("Cursor already visible.", location = loc)
        return
    }
    
    if !_show_cursor(loc) {
        log.error("Failed to show cursor.", location = loc)
    } else {
        log.debug("Succeeded to show cursor.", location = loc)
    }
}

hide_cursor :: proc(loc := #caller_location) {
    if !cursor_visible(loc) {
        log.warn("Cursor already hidden.", location = loc)
        return
    }

    if !_hide_cursor() { 
        log.error("Failed to hide cursor.", location = loc)
    } else { 
        log.debug("Succeeded to hide cursor.", location = loc)
    }
}

cursor_enabled :: proc "contextless" () -> bool {
    return _cursor_enabled()
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
mouse_wheel :: proc "contextless" () -> f32 {
    return ctx.mouse_wheel
}

@(require_results)
text_input :: proc() -> string {
    return strings.clone_from(string(ctx.text_input_buf.buf[:]))
}

text_input_clear :: proc() {
    edit.clear_all(&ctx.text_input)
}

text_input_state :: proc "contextless" () -> edit.State {
    return ctx.text_input
}

set_text_input_state :: proc "contextless" (state: edit.State) {
    ctx.text_input = state
}

Text_Input_Flag :: enum  {
    Undo_Redo,
}
Text_Input_Flags :: distinct bit_set[Text_Input_Flag]

set_text_input_flags :: proc "contextless" (flags: Text_Input_Flags) {
    ctx.text_input_flags = flags
}