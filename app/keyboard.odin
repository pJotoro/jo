package app

@(private)
key_down_enum :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys[key]
}

@(private)
key_down_rune :: proc "contextless" (key: rune) -> bool {
    key := key >= 'a' && key <= 'z' ? key - ('a' - 'A') : key
    return ctx.keyboard_keys[Keyboard_Key(key)]
}

key_down :: proc{key_down_enum, key_down_rune}

@(private)
key_pressed_enum :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys_pressed[key]
}

@(private)
key_pressed_rune :: proc "contextless" (key: rune) -> bool {
    key := key >= 'a' && key <= 'z' ? key - ('a' - 'A') : key
    return ctx.keyboard_keys_pressed[Keyboard_Key(key)]
}

key_pressed :: proc{key_pressed_enum, key_pressed_rune}

@(private)
key_released_enum :: proc "contextless" (key: Keyboard_Key) -> bool {
    return ctx.keyboard_keys_released[key]
}

@(private)
key_released_rune :: proc "contextless" (key: rune) -> bool {
    key := key >= 'a' && key <= 'z' ? key - ('a' - 'A') : key
    return ctx.keyboard_keys_released[Keyboard_Key(key)]
}

key_released :: proc{key_released_enum, key_released_rune}

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