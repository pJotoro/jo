package app

key_down :: proc "contextless" (key: Key) -> bool {
    return ctx.keys[key]
}

key_pressed :: proc "contextless" (key: Key) -> bool {
    return ctx.keys_pressed[key]
}

key_released :: proc "contextless" (key: Key) -> bool {
    return ctx.keys_released[key]
}

any_key_down :: proc "contextless" () -> bool {
    return ctx.any_key_down
}

any_key_pressed :: proc "contextless" () -> bool {
    return ctx.any_key_pressed
}

any_key_released :: proc "contextless" () -> bool {
    return ctx.any_key_released
}

// When this key is pressed, the program exits.
//
// The default is Escape.
set_exit_key :: proc "contextless" (exit_key: Key) {
    ctx.exit_key = exit_key
}

// TODO: Add all keyboard keys, or as close to that as possible.
Key :: enum u16 {
    Cancel,
    Backspace,
    Tab,
    Clear,
    Enter,

    // TODO: What should we do about the left and right version of these?
    Shift,
    Control,
    Alt,
    
    Pause,
    Caps_Lock,
    Escape,
    Space,
    Page_Up,
    Page_Down,
    End,
    Home,
    Left,
    Right,
    Down,
    Up,
    Select,
    Print,
    Execute,
    Print_Screen,
    Insert,
    Delete,
    Help,
    Zero,
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    A,
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
    Left_Logo,
    Right_Logo,
    Apps,
    Sleep,
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
    Num_Lock,
    Scroll,
    Volume_Mute,
    Volume_Down,
    Volume_Up,
}