package app

key_down :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys[key]
}

key_pressed :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys_pressed[key]
}

key_released :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys_released[key]
}

get_key_pressed :: proc(shift_down: ^bool = nil) -> (key: Keyboard_Key, ok: bool) {
    keyboard_key_pressed: Keyboard_Key_Pressed
    keyboard_key_pressed, ok = pop_front_safe(&ctx.keyboard_keys_pressed_queue)
    if !ok do return
    if shift_down != nil do shift_down^ = keyboard_key_pressed.shift_down
    key = keyboard_key_pressed.keyboard_key
    return
}

Keyboard_Key :: enum rune {
    Left_Mouse = 0x01,
    Right_Mouse,
    Cancel,
    Middle_Mouse,
    X1_Mouse,
    X2_Mouse,

    Backspace = 0x08,
    Tab,

    Clear = 0x0C,
    Enter,

    Shift = 0x10,
    Control,
    Alt,
    Pause,
    Caps_Lock,

    Escape = 0x1B,

    Space = 0x20,
    Page_Up,
    Page_Down,
    End,
    Home,
    Left,
    Up,
    Right,
    Down,
    Select,
    Print,
    Execute,
    Print_Screen,
    Insert,
    Delete,
    Help,

    Zero = '0',
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,

    A = 'A',
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,

    Left_Logo_Key = 0x5B,
    Right_Logo_Key,
    Applications_Key,

    Sleep = 0x5F,
    Numpad0,
    Numpad1,
    Numpad2,
    Numpad3,
    Numpad4,
    Numpad5,
    Numpad6,
    Numpad7,
    Numpad8,
    Numpad9,
    Multiply,
    Add,
    Separator,
    Subtract,
    Decimal,
    Divide,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    F13,
    F14,
    F15,
    F16,
    F17,
    F18,
    F19,
    F20,
    F21,
    F22,
    F23,
    F24,

    Numlock = 0x90,
    Scroll,

    Volume_Mute = 0xAD,
    Volume_Down,
    Volume_Up,
}