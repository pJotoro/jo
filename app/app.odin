package app

import "base:runtime"
import "core:io"
import "core:time"

JO_GL :: #config(JO_GL, true)
JO_D3D11 :: #config(JO_D3D11, true)

Context :: struct {
    // There is no law saying you have to follow what the side comments say.
    // That said, it is highly recommended that you do so.

    initialized: bool,                          // get

    graphics_api_initialized: bool,             // get
    graphics_api: Graphics_Api,                 // get
    gpu_swapped_buffers: bool,                  // get

    title, _title: string,                      // get/set safe
    window_mode, _window_mode: Window_Mode,     // get/set safe
    dpi: int,                                   // get
    refresh_rate: int,                          // get
    screen: struct {w, h: int},                 // get

    running: bool,                              // get/set
    update_proc: proc(ctx: ^Context, dt: f64),  // get/set
    open: bool,                                 // get

    event_callback_context: runtime.Context,    // get/set TODO

    keys: [Key]Input,                           // get
    text_input: io.Writer,                      // get/set

    mouse: struct {
        left: Input,                            // get
        right: Input,                           // get
        middle: Input,                          // get
        pos: [2]int,                            // get
        wheel: int,                             // get
    },

    gamepads: [4]Gamepad,                       // get

    user_data: rawptr,                          // get/set

    using os_specific: OS_Specific,
}

Window_Mode :: union {
    Window_Mode_Windowed,
    Window_Mode_Fullscreen,
}

Window_Mode_Windowed :: distinct Rect

Window_Mode_Fullscreen :: struct {
    topmost: bool,
}

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
init :: proc(ctx: ^Context) {
    assert(!ctx.initialized, "app already initialized.")

    if ctx.window_mode != nil {
        when ODIN_OS == .JS {
            panic("window modes unsupported (for now)")
        }
    } else {
        when ODIN_DEBUG {
            ctx.window_mode = Window_Mode_Windowed{}
        } else {
            ctx.window_mode = Window_Mode_Fullscreen{topmost = true}
        }
    }

    _init(ctx)

    if _, ok := ctx.window_mode.(Window_Mode_Fullscreen); ok {
        _toggle_cursor(ctx, false)
    }

    for gamepad_index in 0..<len(ctx.gamepads) {
        try_connect_gamepad(ctx, gamepad_index)
    }

    ctx.initialized = true
    ctx.running = true
}

// Call this at the beginning of every frame.
//
// Beyond checking for whether the app is still running, it also gets OS events and updates input.
running :: proc(ctx: ^Context) -> bool {
    assert(ctx.initialized, "app not initialized")

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
            try_connect_gamepad(ctx, g_idx)
        }
    }

    if ctx.title != ctx._title {
        _set_title(ctx)
        ctx._title = ctx.title
    }
    if ctx.window_mode != ctx._window_mode {
        _set_window_mode(ctx)
        ctx._window_mode = ctx.window_mode 
        _, ok := ctx.window_mode.(Window_Mode_Fullscreen)
        if ok {
            _toggle_cursor(ctx, false)
        } else {
            _toggle_cursor(ctx, true)
        }
    }

    _running(ctx)

    return ctx.running
}

// A different way to do the game loop. Calculates delta time for you. Required in WASM.
run :: proc(ctx: ^Context, update_proc: proc(ctx: ^Context, dt: f64)) {
    ctx.update_proc = update_proc
    
    when ODIN_OS != .JS {
        last_tick := time.tick_now()
        dt: f64
        for running(ctx) {
            tick := time.tick_now()
            dt_dur := time.tick_diff(last_tick, tick)
            last_tick = tick
            dt = f64(dt_dur)/f64(time.Second)
            ctx.update_proc(ctx, dt)
            if ctx.graphics_api_initialized && !ctx.gpu_swapped_buffers {
                panic("forgot to call _xxx_swap_buffers")
            }
            ctx.gpu_swapped_buffers = false
        }
    }
}

swap_buffers :: proc(ctx: ^Context, buf: []u32, buf_w := 0, buf_h := 0) {
    assert(ctx.graphics_api == .Software)
    assert(buf != nil)
    _swap_buffers(ctx, buf, buf_w, buf_h)
}

Rect :: struct {
    x, y, w, h: int,
}

client_rect :: proc "contextless" (ctx: ^Context) -> (rect: Rect) {
    switch wm in ctx.window_mode {
        case Window_Mode_Windowed:
            rect = Rect(wm)
        case Window_Mode_Fullscreen:
            rect = Rect{x = 0, y = 0, w = ctx.screen.w, h = ctx.screen.h}
    }
    return
}