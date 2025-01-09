// jo:app is a stupidly easy to use platform layer. 
// If all you want is a window, an OpenGL context, and keyboard or gamepad input, then this is for you. 
// It takes inspiration from the simplicity of Raylib while still being lightweight and fairly low level.
package app

import "core:log"
import "core:strings"
import "core:time"

Window_Mode_Free_Flag :: enum {
    Minimize_Box,
    Maximize_Box,
    Resizable,
}
Window_Mode_Free_Flags :: distinct bit_set[Window_Mode_Free_Flag]

Window_Mode_Free :: struct {
    x, y, width, height: int,
    flags: Window_Mode_Free_Flags,
}

Window_Mode_Maximized :: struct {}

Window_Mode_Fullscreen_Flag :: enum {
    Topmost,
}
Window_Mode_Fullscreen_Flags :: distinct bit_set[Window_Mode_Fullscreen_Flag]

Window_Mode_Fullscreen :: struct {
    flags: Window_Mode_Fullscreen_Flags,
}

Window_Mode :: union {
    Window_Mode_Free,
    Window_Mode_Maximized,
    Window_Mode_Fullscreen,
}

// You must call this before any other procedure.
// It initializes the library.
init :: proc(title := "", window_mode: Window_Mode = nil, loc := #caller_location) {
    if ctx.app_initialized {
        log.warn("App already initialized.", location = loc)
        return
    }

    ctx.title = title

    when ODIN_OS == .JS /* || other platforms where there is no window */ {
        if window_mode != nil {
            log.warnf("window_mode ignored on %v.", ODIN_OS_STRING)
        }
    } else {
        if window_mode != nil {
            ctx.window_mode = window_mode
        } else {
            when ODIN_DEBUG {
                ctx.window_mode = Window_Mode_Free{}
            } else {
                ctx.window_mode = Window_Mode_Fullscreen{}
            }
        }
    }

    if !_init(loc) {
        log.fatal("App failed to initialize.", location = loc)
        return
    }

    if _, ok := window_mode.(Window_Mode_Fullscreen); ok {
        disable_cursor(loc)
    }

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            try_connect_gamepad(gamepad_index, loc)
        }
    }

    strings.builder_init_len_cap(&ctx.text_input, 0, 4096)

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
    // assert(!(ctx.width == 0 && !ctx.minimized), "width == 0", loc)
    // assert(!(ctx.height == 0 && !ctx.minimized), "height == 0", loc)

    // assert(ctx.dpi > 0, "dpi <= 0", loc)
    // assert(ctx.refresh_rate > 0, "refresh rate <= 0", loc)

    // assert(ctx.window != nil, "window == nil", loc)
    // assert(ctx.screen_width > 0, "screen width <= 0", loc)
    // assert(ctx.screen_height > 0, "screen height <= 0", loc)
    // -------------------------

    if key_pressed(ctx.exit_key) {
        ctx.running = false
        return false
    }

    for &k in ctx.keys_pressed { 
        k = false 
    }
    for &k in ctx.keys_released { 
        k = false 
    }

    ctx.any_key_pressed = false

    ctx.left_mouse_pressed = false
    ctx.left_mouse_released = false
    ctx.left_mouse_double_click = false

    ctx.right_mouse_pressed = false
    ctx.right_mouse_released = false
    ctx.right_mouse_double_click = false

    ctx.middle_mouse_pressed = false
    ctx.middle_mouse_released = false
    ctx.middle_mouse_double_click = false

    ctx.mouse_wheel = 0

    strings.builder_reset(&ctx.text_input)

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

// Experimental new way to do game loop. Calculates delta time for you.
run :: proc(update_proc: proc(dt: f64, user_data: rawptr), user_data: rawptr, loc := #caller_location) {
    ctx.update_proc = update_proc
    ctx.update_proc_user_data = user_data
    
    when ODIN_OS != .JS {
        dt := f64(ctx.refresh_rate) / f64(time.Second)
        for running(loc) {
            start_tick := time.tick_now()
            defer {
                end_tick := time.tick_now()
                dt_dur := time.tick_diff(start_tick, end_tick)
                dt = f64(dt_dur)/f64(time.Second)
            }
            ctx.update_proc(dt, ctx.update_proc_user_data)
        }
    }
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

    if ctx.width == 0 || ctx.height == 0 {
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

// By client width or height, I mean the part of the window that you can actually draw into, not the entire window.

// Returns the client width in pixels.
width :: proc "contextless" () -> int {
    return ctx.width
}

// Returns the client height in pixels.
height :: proc "contextless" () -> int {
    return ctx.height
}

// Returns the screen width in pixels.
screen_width :: proc "contextless" () -> int {
    return ctx.screen_width
}

// Returns the screen height in pixels.
screen_height :: proc "contextless" () -> int {
    return ctx.screen_height
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

set_window_mode :: proc(window_mode: Window_Mode, loc := #caller_location) {
    if window_mode == ctx.window_mode {
        log.warn("Identical window mode already set.", location = loc)
        return
    }

    _set_window_mode(window_mode, loc)


    _, ok := window_mode.(Window_Mode_Fullscreen)
    if ok {
        disable_cursor()
    } else {
        enable_cursor()
    }
}

window_mode :: proc "contextless" () -> Window_Mode {
    return ctx.window_mode
}

open :: proc "contextless" () -> bool {
    return ctx.open
}