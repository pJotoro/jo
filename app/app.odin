// jo:app is a stupidly easy to use platform layer. 
// If all you want is a window, an OpenGL context, and keyboard or gamepad input, then this is for you. 
// It takes inspiration from the simplicity of Raylib while still being lightweight and fairly low level.
package app

import "core:log"

import "core:prof/spall"
SPALL_ENABLED :: #config(SPALL_ENABLED, false)

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
             spall_ctx: ^spall.Context = nil, spall_buffer: ^spall.Buffer = nil,
             loc := #caller_location) {
    if ctx.app_initialized {
        log.warn("App already initialized.", location = loc)
        return
    }

    when SPALL_ENABLED {
        if spall_ctx == nil || spall_buffer == nil {
            log.fatal("Must set spall_ctx and spall_buffer when spall is enabled.", location = loc)
            return
        }
        ctx.spall_ctx = spall_ctx
        ctx.spall_buffer = spall_buffer
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
    ctx.events = make([dynamic]Event)
    ctx.cursor_enabled = true

    if !_init(loc) {
        log.fatal("App failed to initialize.", location = loc)
        return
    }

    if !ctx.fullscreen {
        ctx.windowed_width = ctx.width
        ctx.windowed_height = ctx.height
    } else {
        ctx.windowed_width = ctx.width / 2
        ctx.windowed_height = ctx.height / 2

        disable_cursor(loc)
    }

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            try_connect_gamepad(gamepad_index, loc)
        }
    }

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

    for &k in ctx.keyboard_keys_pressed { 
        k = false 
    }
    for &k in ctx.keyboard_keys_released { 
        k = false 
    }

    ctx.left_mouse_pressed = false
    ctx.left_mouse_released = false
    ctx.right_mouse_pressed = false
    ctx.right_mouse_released = false
    ctx.middle_mouse_pressed = false
    ctx.middle_mouse_released = false

    ctx.mouse_wheel = 0

    clear(&ctx.events)
    ctx.event_index = 0

    _run(loc)

    //_ui_update()

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            if gamepad_connected(gamepad_index) {
                try_connect_gamepad(gamepad_index)
            }
        }

        if ctx.gamepad_events_enabled {
            get_gamepad_events()
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
swap_buffers :: proc(buffer: []u32, loc := #caller_location) {
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

    if width() == 0 || height() == 0 || ctx.minimized {
        ok = false
    }

    if buffer == nil {
        log.fatal("Buffer == nil.", location = loc)
        ctx.running = false
        ok = false
    }
    if len(buffer) < width() * height() {
        log.fatalf("Buffer with length %v too small for window with dimensions %v by %v = %v.", len(buffer), width(), height(), width() * height(), location = loc)
        ctx.running = false
        ok = false
    }
    if len(buffer) > width() * height() {
        log.fatalf("Buffer with length %v too big for window with dimensions %v by %v = %v.", len(buffer), width(), height(), width() * height(), location = loc)
        ctx.running = false
        ok = false
    }

    if !ok {
        return
    }

    _swap_buffers(buffer, loc)
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
    
    if _set_windowed() {
        ctx.fullscreen = false
        ctx.width = ctx.windowed_width
        ctx.height = ctx.windowed_height

        enable_cursor()
    }
}

set_fullscreen :: proc(loc := #caller_location) {
    if ctx.fullscreen {
        log.warn("Already fullscreen.", location = loc)
        return
    }

    if !_set_fullscreen(loc) {
        log.error("Failed to set fullscreen.", location = loc)
    } else {
        log.debug("Succeeded to set fullscreen.", location = loc)

        ctx.fullscreen = true
        ctx.width = ctx.monitor_width
        ctx.height = ctx.monitor_height

        disable_cursor()
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
    
    if !_minimize() {
        log.error("Failed to minimize.", location = loc)
    } else {
        log.debug("Succeeded to minimize.", location = loc)
        ctx.minimized = true
        ctx.maximized = false
    }
}

maximize :: proc(loc := #caller_location) {
    if ctx.maximized {
        log.warn("Already maximized.", location = loc)
        return
    }
    if ctx.fullscreen {
        log.error("Cannot maximize while fullscreen.", location = loc)
        return
    }

    if !_maximize() {
        log.error("Failed to maximize.", location = loc)
    } else {
        log.debug("Succeeded to maximize.", location = loc)
        ctx.maximized = true
        ctx.minimized = false
    }
}

focused :: proc "contextless" () -> bool {
    return ctx.focused
}

cursor_position :: proc(loc := #caller_location) -> (x, y: int) {
    return _cursor_position(loc)
}

// Actually, this returns whether the cursor is within the bounds of the app.
// That way, it works the same whether fullscreen is on or off.
cursor_on_screen :: proc(loc := #caller_location) -> bool {
    x, y := cursor_position(loc)
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

mouse_wheel :: proc "contextless" () -> int {
    return ctx.mouse_wheel
}

/*
You can call this once like this:

if event, ok := app.get_event(); ok {
    // process the event
}

Or you can call this like an iterator:

for event in app.get_event() {
    // process the event
}

Either way works fine.

Every time app.running() is called, the event array is reset, and then filled with whatever OS events have happened since last time app.running() was called.
As a result, you don't have to worry about old events getting returned.
*/
get_event :: proc "contextless" () -> (event: Event, ok: bool) {
    if ctx.event_index >= len(ctx.events) {
        return
    }
    event = ctx.events[ctx.event_index]
    ctx.event_index += 1
    ok = true
    return
}