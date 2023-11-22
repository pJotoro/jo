package app

Event_Key_Down :: struct {
    key: Keyboard_Key,
    repeat_count: int,
    already_down: bool,
}

Event_Char :: struct {
    char: rune,
    repeat_count: int,
    already_down: bool,
}

Event_Key_Up :: struct {
    key: Keyboard_Key,
}

Event_Left_Mouse_Down :: struct {
    x, y: int,
}

Event_Left_Mouse_Up :: struct {
    x, y: int,
}

Event_Left_Mouse_Double_Click :: struct {
    x, y: int,
}

Event_Right_Mouse_Down :: struct {
    x, y: int,
}

Event_Right_Mouse_Up :: struct {
    x, y: int,
}

Event_Right_Mouse_Double_Click :: struct {
    x, y: int,
}

Event_Middle_Mouse_Down :: struct {
    x, y: int,
}

Event_Middle_Mouse_Up :: struct {
    x, y: int,
}

Event_Middle_Mouse_Double_Click :: struct {
    x, y: int,
}

Event_Mouse_Wheel :: struct {
    amount: int,
}

Event :: union {
    Event_Key_Down,
    Event_Char,
    Event_Key_Up,

    Event_Left_Mouse_Down,
    Event_Left_Mouse_Up,
    Event_Left_Mouse_Double_Click,

    Event_Right_Mouse_Down,
    Event_Right_Mouse_Up,
    Event_Right_Mouse_Double_Click,

    Event_Middle_Mouse_Down,
    Event_Middle_Mouse_Up,
    Event_Middle_Mouse_Double_Click,
    
    Event_Mouse_Wheel,
}

Event_Callback :: #type proc(event: Event, user_data: rawptr)