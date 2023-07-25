package app

Gamepad_Button :: enum u16 {
	Dpad_Up,
	Dpad_Down,
	Dpad_Left,
	Dpad_Right,
	Start,
	Back,
	Left_Thumb,
	Right_Thumb,
	Left_Shoulder,
	Right_Shoulder,
	A = 12,
	B,
	X,
	Y,
}

Gamepad_Buttons :: distinct bit_set[Gamepad_Button; u16]

@(private)
Gamepad_Desc :: struct {
	buttons: Gamepad_Buttons,
	buttons_previous: Gamepad_Buttons,
	left_trigger: f32,
	right_trigger: f32,
	left_stick: [2]f32,
	right_stick: [2]f32,

	id: Gamepad,
}

Gamepad :: distinct int

INVALID_GAMEPAD : Gamepad : -1

gamepad :: proc(index: int, loc := #caller_location) -> Gamepad {
	return _gamepad(index, loc)
}

gamepad_index :: proc(id: Gamepad) -> int {
	for gamepad, i in ctx.gamepads {
		if gamepad.id == id do return i
	}
	return -1
}

gamepad_connected :: proc(id: Gamepad, loc := #caller_location) -> bool {
	i := gamepad_index(id)
	if i == -1 do return false
	assert(condition = ctx.gamepads[i].id != -1, loc = loc)
	return true
}

gamepad_button_down :: proc(id: Gamepad, button: Gamepad_Button) -> bool {
	i := gamepad_index(id)
	if i == -1 do return false

	return button in ctx.gamepads[i].buttons
}

gamepad_buttons_down :: proc(id: Gamepad, buttons: Gamepad_Buttons) -> bool {
	i := gamepad_index(id)
	if i == -1 do return false
	
	return buttons <= ctx.gamepads[i].buttons
}

gamepad_button_pressed :: proc(id: Gamepad, button: Gamepad_Button) -> bool {
	i := gamepad_index(id)
	if i == -1 do return false

	return button in ctx.gamepads[i].buttons && button not_in ctx.gamepads[i].buttons_previous
}

gamepad_button_released :: proc(id: Gamepad, button: Gamepad_Button) -> bool {
	i := gamepad_index(id)
	if i == -1 do return false

	return button not_in ctx.gamepads[i].buttons && button in ctx.gamepads[i].buttons_previous
}

gamepad_left_trigger :: proc(id: Gamepad) -> f32 {
	i := gamepad_index(id)
	if i == -1 do return 0
	return ctx.gamepads[i].left_trigger
}

gamepad_right_trigger :: proc(id: Gamepad) -> f32 {
	i := gamepad_index(id)
	if i == -1 do return 0
	return ctx.gamepads[i].right_trigger
}

gamepad_left_stick :: proc(id: Gamepad) -> [2]f32 {
	i := gamepad_index(id)
	if i == -1 do return {}
	return ctx.gamepads[i].left_stick
}

gamepad_right_stick :: proc(id: Gamepad) -> [2]f32 {
	i := gamepad_index(id)
	if i == -1 do return {}
	return ctx.gamepads[i].right_stick
}

gamepad_set_vibration :: proc(id: Gamepad, left_motor, right_motor: f32, loc := #caller_location) {
	_gamepad_set_vibration(id, left_motor, right_motor, loc)
}