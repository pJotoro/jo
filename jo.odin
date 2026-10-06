package jo

import "base:runtime"
import "core:io"
import "core:time"

JO_DEBUG :: #config(JO_DEBUG, ODIN_DEBUG)
JO_FULLSCREEN :: #config(JO_FULLSCREEN, !JO_DEBUG)
JO_TOPMOST :: #config(JO_TOPMOST, JO_FULLSCREEN)

JO_GL :: #config(JO_GL, true)
JO_D3D11 :: #config(JO_D3D11, true)

/*
- Input handling
    - Should we allow keyboard input to be queried directly? Or should we always treat it as if the player is using a controller? What about mouse input?
        - The user should be able to query keyboard and mouse input directly.
    - Should we switch over to Microsoft's new API for gamepad input? Should we use both that and XInput? How much does it change things either way?
        We should switch over to using GameInput, and only that, not XInput. They are different enough that supporting both we be beyond the scope of this project.
    - Should we allow the user to handle events themselves, or should they always just be handled by the engine?
        - They should always just be handled by the engine. Wherever this becomes an issue, we can just solve the problem at that point.
    - How should text input be handled? Should we make the engine always be recording a text input buffer for convenience?
        - Honestly, I don't think this really matters. Eventually, we could do things like automatically record a text input buffer and feed that to MicroUI, but for now, I could care less.
    - When it comes to gamepad input, should we make the user use the gamepad's index directly? Or should we make the user request a gamepad handle, which then gets mapped to an actual gamepad index?
        This doesn't apply anymore, because GameInput doesn't require you to query which device is being used.
- Graphics
    - Should we automatically select the graphics API? If so, how? What are our priorities?
        - We should just use Vulkan.
    - Should we implement different graphics APIs, or just use one? Obviously, I want to just use Vulkan, but maybe not everyone has that.
        - We should just use Vulkan. In general, I wouldn't support just ignoring other graphics APIs like that, but for this project, I think it's fine. Maybe we could eventually bring back OpenGL in the future if we have time?
    - Should we allow the user to draw sprites themselves directly? Or should it all be done through LDtk?
        - We should not let the user draw sprites themselves. I want this to be a tiny, easy to use engine that either does exactly what you want, or it doesn't.
- Audio
    - Should we even bother with this? If so, would it make sense to just use miniaudio?
        - Let's just use miniaudio.
*/

/*
Tasks (for now):

- Make keyboard and mouse input work how it used to.
- Remove text input.
- Replace XInput with GameInput.
- Port over code from Legacy Fantasy (especially Vulkan and LDtk stuff).
*/

Context :: struct {
    initialized: bool,

    graphics_api_initialized: bool,
    graphics_api: Graphics_Api,
    gpu_swapped_buffers: bool,

    title: string,
    dpi: int,
    refresh_rate: int,
    monitor: struct {w, h: int},

    running: bool,

    // gamepads: [4]Gamepad,

    user_data: rawptr,

    using os_specific: OS_Specific,
}
ctx: Context

title :: proc "contextless" () -> string {
    return ctx.title
}

dpi :: proc "contextless" () -> int {
    return ctx.dpi
}

refresh_rate :: proc "contextless" () -> int {
    return ctx.refresh_rate
}

Update_Proc :: #type proc(dt: f32, user_data: rawptr)

Graphics_Api :: enum {
    Software,
    OpenGL,
    D3D11,
}

/*
Input_Kind :: enum u8 {
    Down,
    Pressed,
    Released,
    // Repeat, TODO
    Double_Click,
    Exit, // exits the program when pressed
}
Input :: distinct bit_set[Input_Kind; u8]
*/

// You must call this before any other procedure.
// It initializes the library.
init :: proc(title: string, update_proc, fixed_update_proc: Update_Proc, ldtk_file := "", user_data: rawptr = nil) {
    assert(!ctx.initialized, "jo already initialized.")

    ctx.title = title
    _init()

    when JO_FULLSCREEN {
        _toggle_cursor(false)
    }

    /*
    for gamepad_index in 0..<len(ctx.gamepads) {
        try_connect_gamepad(gamepad_index)
    }
    */

    ctx.initialized = true
    ctx.running = true

    last_tick := time.tick_now()
    dt: f32

    for ctx.running {
        /*
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
        */

        /*
        for g_idx in 0..<len(ctx.gamepads) {
            if ctx.gamepads[g_idx].connected {
                try_connect_gamepad(g_idx)
            }
        }
        */

        _update()

        if update_proc != nil {
            tick := time.tick_now()
            dt_dur := time.tick_diff(last_tick, tick)
            last_tick = tick
            dt = f32(dt_dur)/f32(time.Second)

            update_proc(dt, user_data)

            // TODO: How should swapping buffers be handled?
        }
    }
}

Rect :: struct {
    x, y, w, h: int,
}

width :: proc "contextless" () -> int {
    when !JO_FULLSCREEN {
        return ctx.monitor.w/2
    } else {
        return ctx.monitor.w
    }
}

height :: proc "contextless" () -> int {
    when !JO_FULLSCREEN {
        return ctx.monitor.h/2
    } else {
        return ctx.monitor.h
    }
}