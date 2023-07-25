package app

import "core:runtime"
import win32 "core:sys/windows"
import "xinput"

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

Gamepad_Desc :: struct {
	id: Gamepad,

	buttons: Gamepad_Buttons,
	buttons_previous: Gamepad_Buttons,
	left_trigger: f32,
	right_trigger: f32,
	left_stick: [2]f32,
	right_stick: [2]f32,
}

Gamepad :: distinct int

INVALID_GAMEPAD : Gamepad : -1

gamepad :: proc(index: int, loc := #caller_location) -> (gamepad: Gamepad) {
	runtime.bounds_check_error_loc(loc, index, len(ctx.gamepads))

	state: xinput.STATE = ---
	result := xinput.GetState(win32.DWORD(index), &state)
	if result != win32.ERROR_SUCCESS {
		ctx.gamepads[index].id = INVALID_GAMEPAD
		gamepad = INVALID_GAMEPAD
		return
	}

	if ctx.gamepads[index].id != -1 {
		gamepad = ctx.gamepads[index].id
		return
	}

	gamepad = ctx.next_gamepad_id
	ctx.gamepads[index].id = gamepad
	ctx.next_gamepad_id += 1
	return
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

gamepad_close :: proc(id: Gamepad) {
	i := gamepad_index(id)
	if i == -1 do return // NOTE(pJotoro): If the gamepad you're trying to close doesn't exist, it's OK, nothing will happen.
	ctx.gamepads[i].id = -1
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

/*
NOTE(pJotoro): I was originally going to have a gamepad_buttons_pressed procedure and a gamepad_buttons_released procedure, but decided against it because I didn't think they were useful enough.
*/

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
	assert(condition = left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1, loc = loc)

	i := gamepad_index(id)
	if i == -1 do return

	xinput_vibration: xinput.VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	xinput.SetState(win32.DWORD(i), &xinput_vibration)
}

@(private)
cut_deadzones :: proc(xinput_gamepad: ^xinput.GAMEPAD) {
	xinput_gamepad.bLeftTrigger -= xinput_gamepad.bLeftTrigger >= xinput.GAMEPAD_TRIGGER_THRESHOLD ? xinput.GAMEPAD_TRIGGER_THRESHOLD : xinput_gamepad.bLeftTrigger
	xinput_gamepad.bRightTrigger -= xinput_gamepad.bRightTrigger >= xinput.GAMEPAD_TRIGGER_THRESHOLD ? xinput.GAMEPAD_TRIGGER_THRESHOLD : xinput_gamepad.bRightTrigger

	if xinput_gamepad.sThumbLX < xinput.GAMEPAD_LEFT_THUMB_DEADZONE && xinput_gamepad.sThumbLX > -xinput.GAMEPAD_LEFT_THUMB_DEADZONE do xinput_gamepad.sThumbLX = 0
	else if xinput_gamepad.sThumbLX > 0 do xinput_gamepad.sThumbLX -= xinput.GAMEPAD_LEFT_THUMB_DEADZONE
	else if xinput_gamepad.sThumbLX < 0 do xinput_gamepad.sThumbLX += xinput.GAMEPAD_LEFT_THUMB_DEADZONE

	if xinput_gamepad.sThumbLY < xinput.GAMEPAD_LEFT_THUMB_DEADZONE && xinput_gamepad.sThumbLY > -xinput.GAMEPAD_LEFT_THUMB_DEADZONE do xinput_gamepad.sThumbLY = 0
	else if xinput_gamepad.sThumbLY > 0 do xinput_gamepad.sThumbLY -= xinput.GAMEPAD_LEFT_THUMB_DEADZONE
	else if xinput_gamepad.sThumbLY < 0 do xinput_gamepad.sThumbLY += xinput.GAMEPAD_LEFT_THUMB_DEADZONE

	if xinput_gamepad.sThumbRX < xinput.GAMEPAD_RIGHT_THUMB_DEADZONE && xinput_gamepad.sThumbRX > -xinput.GAMEPAD_RIGHT_THUMB_DEADZONE do xinput_gamepad.sThumbRX = 0
	else if xinput_gamepad.sThumbRX > 0 do xinput_gamepad.sThumbRX -= xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
	else if xinput_gamepad.sThumbRX < 0 do xinput_gamepad.sThumbRX += xinput.GAMEPAD_RIGHT_THUMB_DEADZONE

	if xinput_gamepad.sThumbRY < xinput.GAMEPAD_RIGHT_THUMB_DEADZONE && xinput_gamepad.sThumbRY > -xinput.GAMEPAD_RIGHT_THUMB_DEADZONE do xinput_gamepad.sThumbRY = 0
	else if xinput_gamepad.sThumbRY > 0 do xinput_gamepad.sThumbRY -= xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
	else if xinput_gamepad.sThumbRY < 0 do xinput_gamepad.sThumbRY += xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
}

@(private)
gamepad_get_input :: proc(gamepad: ^Gamepad_Desc, xinput_gamepad: xinput.GAMEPAD) {
	xinput_gamepad := xinput_gamepad
	cut_deadzones(&xinput_gamepad)

	TRIGGER_MAX :: f32(max(win32.BYTE) - xinput.GAMEPAD_TRIGGER_THRESHOLD)
	LEFT_THUMB_MAX :: f32(max(win32.SHORT) - xinput.GAMEPAD_LEFT_THUMB_DEADZONE)
	RIGHT_THUMB_MAX :: f32(max(win32.SHORT) - xinput.GAMEPAD_RIGHT_THUMB_DEADZONE)

	gamepad.buttons_previous = gamepad.buttons
	gamepad.buttons = transmute(Gamepad_Buttons)xinput_gamepad.wButtons

	gamepad.left_trigger = f32(xinput_gamepad.bLeftTrigger) / TRIGGER_MAX
	gamepad.right_trigger = f32(xinput_gamepad.bRightTrigger) / TRIGGER_MAX
	gamepad.left_stick.x = f32(xinput_gamepad.sThumbLX) / LEFT_THUMB_MAX
	gamepad.left_stick.y = f32(xinput_gamepad.sThumbLY) / LEFT_THUMB_MAX
	gamepad.right_stick.x = f32(xinput_gamepad.sThumbRX) / RIGHT_THUMB_MAX
	gamepad.right_stick.y = f32(xinput_gamepad.sThumbRY) / RIGHT_THUMB_MAX
}