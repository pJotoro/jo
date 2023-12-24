package app

import "core:log"
import "core:mem"
import "core:prof/spall"

SPALL :: #config(JO_SPALL, false)

@(private)
Context :: struct {
    // ----- init -----
    title: string,
    width, height: int,
    fullscreen_mode: Fullscreen_Mode,

    dpi: int,
    refresh_rate: int,

    windowed_x, windowed_y: int,
    windowed_width, windowed_height: int,
    monitor_width, monitor_height: int,

    minimized: bool,
    maximized: bool,
    focused: bool,

    app_initialized: bool,
    gl_initialized: bool,
    // ----------------

    // ----- running -----
    visible: int, // -1 and 0 mean invisible at first, 1 means visible, and 2 means invisible
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

    // ----- profiling -----
    spall_ctx: ^spall.Context,
    spall_buffer: ^spall.Buffer,
    // ---------------------

    using os_specific: OS_Specific,
}
@(private)
ctx: Context

Fullscreen_Mode :: enum {
    Auto,
    Off,
    On,
}

init :: proc(title := "", width := 0, height := 0, fullscreen := Fullscreen_Mode.Auto, spall_ctx: ^spall.Context = nil, spall_buffer: ^spall.Buffer = nil, allocator := context.allocator) {
    when SPALL {
        if spall_ctx == nil || spall_buffer == nil {
            // NOTE(pJotoro): Assertions are typically turned off when profiling, so it wouldn't make any sense for this to be log.panic.
            log.fatal("When Spall is enabled, must set spall_ctx and spall_buffer.")
            return
        }
        ctx.spall_ctx = spall_ctx
        ctx.spall_buffer = spall_buffer

        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    context.allocator = allocator

    if ctx.app_initialized {
        log.panic("App already initialized.")
    }

    if !((width == 0 && height == 0) || (width != 0 && height != 0)) {
        log.warn("Width and height must be set or unset together.")
    } else {
        ctx.width = width
        ctx.height = height
    }

    ctx.title = title
    ctx.fullscreen_mode = fullscreen

    ctx.events = make([dynamic]Event)

    _init()

    if !ctx.fullscreen {
        ctx.windowed_width = ctx.width
        ctx.windowed_height = ctx.height
    } else {
        ctx.windowed_width = ctx.width / 2
        ctx.windowed_height = ctx.height / 2
    }

    if can_connect_gamepad() {
        for gamepad_index in 0..<len(ctx.gamepads) {
            try_connect_gamepad(gamepad_index)
        }
    }

    ctx.app_initialized = true
}

should_close :: proc() -> bool {
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    if !ctx.app_initialized {
        log.panic("App not initialized.")
    }

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
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    if !ctx.app_initialized {
        log.panic("App not initialized.")
    }
    if ctx.gl_initialized {
        log.panic("Cannot mix software rendering with OpenGL.")
    }

    // TODO(pJotoro): render should change ctx.width and/or ctx.height if the bitmap is too small.
    if len(bitmap) < width() * height() do log.panic("bitmap too small")
    if len(bitmap) > width() * height() do log.panic("bitmap too big")

    _render(bitmap)

    // _render modifies the bitmap anyway (rgba -> bgr), so we might as well zero it out here.
    mem.zero_slice(bitmap)
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

monitor_width :: proc "contextless" () -> int {
    return ctx.monitor_width
}

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
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    if !ctx.fullscreen {
        log.warn("Already windowed.")
        return
    }
    
    if !_set_windowed() {
        log.error("Failed to set windowed.")
    } else {
        log.debug("Succeeded to set windowed.")
        ctx.fullscreen = false
        ctx.width = ctx.windowed_width
        ctx.height = ctx.windowed_height
    }
}

set_fullscreen :: proc() {
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

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
    }
}

toggle_fullscreen :: proc() {
    if !ctx.fullscreen do set_fullscreen()
    else do set_windowed()
}

visible :: proc "contextless" () -> bool {
    return ctx.visible == 1 ? true : false
}

hide :: proc() {
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

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
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

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

minimize :: proc() {
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

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
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    if ctx.maximized {
        log.warn("Already maximized.")
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
    when SPALL {
        spall.SCOPED_EVENT(ctx.spall_ctx, ctx.spall_buffer, #procedure)
    }

    return _cursor_position()
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