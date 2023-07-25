package app

Event_Key_Down :: struct {
    key: Keyboard_Key,
    repeat_count: u16,
    oem_scan_code: u8,
    already_down: bool,
}

Event_Key_Up :: struct {
    key: Keyboard_Key,
    oem_scan_code: u8,
}

Event :: union {
    Event_Key_Down,
    Event_Key_Up,
}

Event_Callback :: #type proc(event: Event)