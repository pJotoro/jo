// +private
package app

import "base:runtime"
import "core:prof/spall"

@(private)
Context :: struct {
    // ----- init -----
    title: string,
    width, height: int,
    fullscreen_mode: Fullscreen_Mode,

    dpi: int,
    refresh_rate: int,

    window: rawptr,
    windowed_x, windowed_y: int,
    windowed_width, windowed_height: int,
    monitor_width, monitor_height: int,

    resizable: bool,
    minimize_box: bool,
    maximize_box: bool,
    focused: bool,

    app_initialized: bool,
    gl_initialized: bool,
    // ----------------

    // ----- running -----
    running: bool,
    visible: int, // -1 and 0 mean invisible at first, 1 means visible, and 2 means invisible
    fullscreen: bool,
    minimized: bool,
    maximized: bool,
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

    // ----- cursor -----
    cursor_enabled: bool,
    // ------------------

    // ----- gamepad -----
    can_connect_gamepad: bool,
    gamepad_debug_flags: Gamepad_Debug_Flags,
    gamepads: [4]Gamepad_Desc,
    // -------------------

    // ----- events -----
    events: [dynamic]Event,
    event_index: int,
    // ------------------

    // ----- ui -----
    /*
    ui_windows: map[runtime.Source_Code_Location]Window, // TODO: Other widgets than just windows?
    ui_parent_window_keys: [dynamic]runtime.Source_Code_Location,
    */
    // --------------

    // ----- profiling -----
    spall_ctx: ^spall.Context,
    spall_buffer: ^spall.Buffer,
    // ---------------------

    using os_specific: OS_Specific,
}
@(private)
ctx: Context