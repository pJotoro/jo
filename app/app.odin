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
             allocator := context.allocator) {
    context.allocator = allocator

    if ctx.app_initialized {
        log.warn("App already initialized.")
        return
    }

    when SPALL_ENABLED {
        if spall_ctx == nil || spall_buffer == nil {
            log.fatal("Must set spall_ctx and spall_buffer when spall is enabled.")
            return
        }
        ctx.spall_ctx = spall_ctx
        ctx.spall_buffer = spall_buffer
    }

    if fullscreen == .On {
        if width != 0 || height != 0 {
            log.warn("Width and height are ignored when fullscreen is on.")
        }
    } else if !((width == 0 && height == 0) || (width != 0 && height != 0)) {
        log.warn("Width and height must be set or unset together.")
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

    if !_init() {
        log.fatal("App failed to initialize.")
        return
    }

    if !ctx.fullscreen {
        ctx.windowed_width = ctx.width
        ctx.windowed_height = ctx.height
    } else {
        ctx.windowed_width = ctx.width / 2
        ctx.windowed_height = ctx.height / 2

        disable_cursor()
    }

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            try_connect_gamepad(gamepad_index)
        }
    }

    ctx.app_initialized = true
    ctx.running = true
}

// Call this at the beginning of every frame.
//
// Beyond checking for whether the app is still running, it also gets OS events and updates input.
running :: proc() -> bool {
    if !ctx.app_initialized {
        log.fatal("App not initialized.")
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

    _run()

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            if gamepad_connected(gamepad_index) {
                try_connect_gamepad(gamepad_index)
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
swap_buffers :: proc(buffer: []u32) {
    ok := true

    if !ctx.app_initialized {
        log.fatal("App not initialized.")
        ok = false
    }
    if ctx.gl_initialized {
        log.fatal("Cannot mix software rendering with OpenGL.")
        ctx.running = false
        ok = false
    }

    if width() == 0 || height() == 0 || ctx.minimized {
        ok = false
    }

    if buffer == nil {
        log.fatal("Buffer == nil.")
        ctx.running = false
        ok = false
    }
    if len(buffer) < width() * height() {
        log.fatalf("Buffer with length %v too small for window with dimensions %v by %v = %v.", len(buffer), width(), height(), width() * height())
        ctx.running = false
        ok = false
    }
    if len(buffer) > width() * height() {
        log.fatalf("Buffer with length %v too big for window with dimensions %v by %v = %v.", len(buffer), width(), height(), width() * height())
        ctx.running = false
        ok = false
    }

    if !ok {
        return
    }

    _swap_buffers(buffer)
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

set_title :: proc(title: string) {
    _set_title(title)
}

set_position :: proc(x, y: int) {
    if ctx.fullscreen {
        log.error("Cannot set position in fullscreen.")
        return
    }

    if !_set_position(x, y) {
        log.error("Failed to set position.")
    } else {
        log.debug("Succeeded to set position.")
    }
}

fullscreen :: proc "contextless" () -> bool {
    return ctx.fullscreen
}

set_windowed :: proc() {
    if !ctx.fullscreen {
        log.warn("Already windowed.")
        return
    }
    
    if !_set_windowed() {
        log.error("Failed to set windowed.")
        return
    } else {
        log.debug("Succeeded to set windowed.")

        ctx.fullscreen = false
        ctx.width = ctx.windowed_width
        ctx.height = ctx.windowed_height

        enable_cursor()
    }
}

set_fullscreen :: proc() {
    if ctx.fullscreen {
        log.warn("Already fullscreen.")
        return
    }

    if !_set_fullscreen() {
        log.error("Failed to set fullscreen.")
    } else {
        log.debug("Succeeded to set fullscreen.")

        ctx.fullscreen = true
        ctx.width = ctx.monitor_width
        ctx.height = ctx.monitor_height

        disable_cursor()
    }
}

toggle_fullscreen :: proc() {
    if !ctx.fullscreen {
        set_fullscreen()
    } else {
        set_windowed()
    }
}

visible :: proc "contextless" () -> bool {
    return true if ctx.visible == 1 else false
}

hide :: proc() {
    if ctx.visible == 2 {
        log.warn("Already hidden.")
        return
    }

    if !_hide() {
        log.error("Failed to hide.")
    } else {
        log.debug("Succeeded to hide.")
        ctx.visible = 2
    }
}

show :: proc() {
    if ctx.visible == 1 {
        log.warn("Already shown.")
        return
    }

    if !_show() {
        log.error("Failed to show.")
    } else {
        log.debug("Succeeded to show.")
        ctx.visible = 1
    }
}

minimized :: proc "contextless" () -> bool {
    return ctx.minimized
}

maximized :: proc "contextless" () -> bool {
    return ctx.maximized
}

minimize :: proc() {
    if ctx.minimized {
        log.warn("Already minimized.")
        return
    }
    
    if !_minimize() {
        log.error("Failed to minimize.")
    } else {
        log.debug("Succeeded to minimize.")
        ctx.minimized = true
        ctx.maximized = false
    }
}

maximize :: proc() {
    if ctx.maximized {
        log.warn("Already maximized.")
        return
    }
    if ctx.fullscreen {
        log.error("Cannot maximize while fullscreen.")
        return
    }

    if !_maximize() {
        log.error("Failed to maximize.")
    } else {
        log.debug("Succeeded to maximize.")
        ctx.maximized = true
        ctx.minimized = false
    }
}

focused :: proc "contextless" () -> bool {
    return ctx.focused
}

cursor_position :: proc() -> (x, y: int) {
    return _cursor_position()
}

// Actually, this returns whether the cursor is within the bounds of the app.
// That way, it works the same whether fullscreen is on or off.
cursor_on_screen :: proc() -> bool {
    x, y := cursor_position()
    return x >= 0 && x < ctx.width && y >= 0 && y < ctx.height
}

cursor_visible :: proc() -> bool {
    return _cursor_visible()
}

show_cursor :: proc() {
    if cursor_visible() {
        log.warn("Cursor already visible.")
        return
    }
    
    if !_show_cursor() {
        log.error("Failed to show cursor.")
    } else {
        log.debug("Succeeded to show cursor.")
    }
}

hide_cursor :: proc() {
    if !cursor_visible() {
        log.warn("Cursor already hidden.")
        return
    }

    if !_hide_cursor() { 
        log.error("Failed to hide cursor.")
    } else { 
        log.debug("Succeeded to hide cursor.")
    }
}

cursor_enabled :: proc "contextless" () -> bool {
    return _cursor_enabled()
}

enable_cursor :: proc() {
    if ctx.cursor_enabled {
        log.warn("Cursor already enabled.")
        return
    }
    if !_enable_cursor() {
        log.error("Failed to enable cursor.")
    } else {
        log.debug("Succeeded to enable cursor.")
        ctx.cursor_enabled = true
    }
}

disable_cursor :: proc() {
    if !ctx.cursor_enabled {
        log.warn("Cursor already disabled.")
        return
    }
    if !_disable_cursor() {
        log.error("Failed to disable cursor.")
    } else {
        log.debug("Succeeded to disable cursor.")
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