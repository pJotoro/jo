#+ private
package app

import "core:text/edit"
import "core:strings"

@(private)
Context :: struct {
    // ----- init -----
    title: string,
    width, height: int,
    fullscreen_mode: Fullscreen_Mode,

    dpi: int,
    refresh_rate: int,

    window: rawptr,
    monitor_width, monitor_height: int,

    resizable: bool,
    minimize_box: bool,
    maximize_box: bool,
    focused: bool,

    re_maximize: bool, // maximize after exiting fullscreen

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

    any_key_down: bool,
    any_key_pressed: bool,
    any_key_released: bool,
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

    mouse_position: [2]int,

    mouse_wheel: f32,
    // -----------------

    // ----- cursor -----
    cursor_enabled: bool,
    // ------------------

    // ----- gamepad -----
    can_connect_gamepad: bool,
    gamepad_debug_flags: Gamepad_Debug_Flags,
    gamepads: [4]Gamepad_Desc,
    // gamepad_events_enabled: bool,
    // -------------------

    // ----- text input -----
    text_input: edit.State,
    text_input_buf: strings.Builder,
    // ----------------------

    using os_specific: OS_Specific,
}
@(private)
ctx: Context