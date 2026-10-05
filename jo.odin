package jo

import "base:runtime"
import "core:io"
import "core:time"

JO_DEBUG :: #config(JO_DEBUG, ODIN_DEBUG)
JO_FULLSCREEN :: #config(JO_FULLSCREEN, !JO_DEBUG)

JO_GL :: #config(JO_GL, true)
JO_D3D11 :: #config(JO_D3D11, true)

// TADALA: The whole "get set" thing was some dumb idea you had when you were like 19.
// You thought that it would be a good idea to let the user of the library directly access
// variables instead of using get/set procedures. In reality, it is not, because then you
// have to all of a sudden pass this ctx struct everywhere, which is annoying and unecessary.
// Therefore, add all the get/set procedures back.

// TADALA: Another dumb idea I had was that you shouldn't handle events by just looping through
// every event. Instead, you should handle input by just accessing an array and also a text input
// buffer. This is really dumb. Just put *all* the events in an array, no matter what they are,
// and let the user figure out what to do with them.

// TADALA: There was a time where I was trying to add support for webassembly. Now, I still think that eventually adding support for other libraries would be great, but for now, it would be better to focus on Windows only. Therefore, remove any reference to other platforms.

Context :: struct {
    initialized: bool,

    graphics_api_initialized: bool,
    graphics_api: Graphics_Api,
    gpu_swapped_buffers: bool,

    title,
    dpi: int,
    refresh_rate: int,
    screen: struct {w, h: int},

    running: bool,
    open: bool,

    gamepads: [4]Gamepad,

    user_data: rawptr,

    using os_specific: OS_Specific,
}
ctx: Context

Jo_Update_Proc :: #type proc(dt: f32, user_data: rawptr)
Jo_Fixed_Update_Proc :: #type proc(dt: f32, user_data: rawptr)

Graphics_Api :: enum {
    Software,
    OpenGL,
    D3D11,
}

Input_Kind :: enum u8 {
    Down,
    Pressed,
    Released,
    // Repeat, TODO
    Double_Click,
    Exit, // exits the program when pressed
}
Input :: distinct bit_set[Input_Kind; u8]

// You must call this before any other procedure.
// It initializes the library.
init :: proc(title: string, update_proc: Jo_Update_Proc, fixed_update_proc: Jo_Fixed_Update_Proc, user_data: rawptr) {
    assert(!ctx.initialized, "jo already initialized.")

    _init()

    when JO_FULLSCREEN {
        _toggle_cursor(false)
    }

    for gamepad_index in 0..<len(ctx.gamepads) {
        try_connect_gamepad(gamepad_index)
    }

    ctx.initialized = true
    ctx.running = true

    for ctx.running {
        INPUT_REMOVE :: Input{.Pressed, .Released, /*.Repeat,*/ .Double_Click}
        for &key in ctx.keys {
            if .Pressed in key && .Exit in key {
                ctx.running = false
                return false
            }

            key -= INPUT_REMOVE
        }
        ctx.mouse.left -= INPUT_REMOVE
        ctx.mouse.right -= INPUT_REMOVE
        ctx.mouse.middle -= INPUT_REMOVE
        ctx.mouse.wheel = 0

        for g_idx in 0..<len(ctx.gamepads) {
            if ctx.gamepads[g_idx].connected {
                try_connect_gamepad(g_idx)
            }
        }

        if ctx.window_mode != ctx._window_mode {
            _set_window_mode()
            ctx._window_mode = ctx.window_mode 
            _, ok := ctx.window_mode.(Window_Mode_Fullscreen)
            if ok {
                _toggle_cursor(false)
            } else {
                _toggle_cursor(true)
            }
        }

        _running()
    }
}

toggle_fullscreen :: proc() {
    if !ctx.fullscreen {

    }
}

// A different way to do the game loop. Calculates delta time for you.
// run :: proc(update_proc: proc(dt: f64)) {
//     ctx.update_proc = update_proc
    
//     when ODIN_OS != .JS {
//         last_tick := time.tick_now()
//         dt: f64
//         for running() {
//             tick := time.tick_now()
//             dt_dur := time.tick_diff(last_tick, tick)
//             last_tick = tick
//             dt = f64(dt_dur)/f64(time.Second)
//             ctx.update_proc(dt)
//             if ctx.graphics_api_initialized && !ctx.gpu_swapped_buffers {
//                 panic("forgot to call _xxx_swap_buffers")
//             }
//             ctx.gpu_swapped_buffers = false
//         }
//     }
// }

Rect :: struct {
    x, y, w, h: int,
}