#+ private
package app

import "core:strings"
import "core:time"

Context :: struct {
    // ----- init -----
    title: string,
    width, height: int,

    dpi: int,
    refresh_rate: int,
    vsync: bool,

    screen_width, screen_height: int,

    app_initialized: bool,
    gl_initialized: bool,
    // ----------------

    // ----- running -----
    running: bool,
    window_mode: Window_Mode,
    open: bool, // literally, whether the user has the app openend, AKA focused

    update_proc: proc(dt: f64, user_data: rawptr),
    update_proc_user_data: rawptr,
    // -------------------
    
    // ----- keyboard -----
    keys: [Key]bool,
    keys_pressed: [Key]bool,
    keys_released: [Key]bool,

    any_key_down: bool,
    any_key_pressed: bool,
    any_key_released: bool,

    exit_key: Key,
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

    mouse_wheel: int,
    // -----------------

    // ----- cursor -----
    cursor_enabled: bool,
    // ------------------

    // ----- gamepad -----
    gamepad_debug_flags: Gamepad_Debug_Flags,
    gamepads: [4]Gamepad_Desc,
    // -------------------

    // ----- text input -----
    text_input: strings.Builder,
    // ----------------------

    using os_specific: OS_Specific,
}
ctx: Context