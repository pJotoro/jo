package app

import "base:runtime"
import "core:log"

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

	left_trigger_delta: f32,
	right_trigger_delta: f32,
	left_stick_delta: [2]f32,
	right_stick_delta: [2]f32,

	packet_number: u32, // TODO(pJotoro): Do other platforms have a similar concept? I'm assuming they do.
	active: bool,
}

can_connect_gamepad :: proc "contextless" () -> bool {
	return ctx.can_connect_gamepad
}

try_connect_gamepad :: proc(gamepad_index: int, loc := #caller_location) -> bool {
	runtime.bounds_check_error_loc(loc, gamepad_index, len(ctx.gamepads))
	return _try_connect_gamepad(gamepad_index)
}

gamepad_connected :: proc "contextless" (gamepad_index: int) -> bool {
	return ctx.gamepads[gamepad_index].active
}

gamepad_button_down :: proc "contextless" (gamepad_index: int, button: Gamepad_Button) -> bool {
	return button in ctx.gamepads[gamepad_index].buttons
}

gamepad_buttons_down :: proc "contextless" (gamepad_index: int, buttons: Gamepad_Buttons) -> bool {
	return buttons <= ctx.gamepads[gamepad_index].buttons
}

gamepad_button_pressed :: proc "contextless" (gamepad_index: int, button: Gamepad_Button) -> bool {
	return button in ctx.gamepads[gamepad_index].buttons && button not_in ctx.gamepads[gamepad_index].buttons_previous
}

gamepad_button_released :: proc "contextless" (gamepad_index: int, button: Gamepad_Button) -> bool {
	return button not_in ctx.gamepads[gamepad_index].buttons && button in ctx.gamepads[gamepad_index].buttons_previous
}

gamepad_left_trigger :: proc "contextless" (gamepad_index: int) -> f32 {
	return ctx.gamepads[gamepad_index].left_trigger
}

gamepad_right_trigger :: proc "contextless" (gamepad_index: int) -> f32 {
	return ctx.gamepads[gamepad_index].right_trigger
}

gamepad_left_stick :: proc "contextless" (gamepad_index: int) -> [2]f32 {
	return ctx.gamepads[gamepad_index].left_stick
}

gamepad_right_stick :: proc "contextless" (gamepad_index: int) -> [2]f32 {
	return ctx.gamepads[gamepad_index].right_stick
}

gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f32, loc := #caller_location) {
	runtime.bounds_check_error_loc(loc, gamepad_index, len(ctx.gamepads))
	left_motor := left_motor
	right_motor := right_motor
	if !(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1) {
		log.warnf("Motors must be in range [0.0, 1.0]. Got %v and %v.", left_motor, right_motor)
		left_motor = clamp(left_motor, 0.0, 1.0)
		right_motor = clamp(right_motor, 0.0, 1.0)
	}
	_gamepad_set_vibration(gamepad_index, left_motor, right_motor)
}

gamepad_left_trigger_delta :: proc "contextless" (gamepad_index: int) -> f32 {
	return ctx.gamepads[gamepad_index].left_trigger_delta
}

gamepad_right_trigger_delta :: proc "contextless" (gamepad_index: int) -> f32 {
	return ctx.gamepads[gamepad_index].right_trigger_delta
}

gamepad_left_stick_delta :: proc "contextless" (gamepad_index: int) -> [2]f32 {
	return ctx.gamepads[gamepad_index].left_stick_delta
}

gamepad_right_stick_delta :: proc "contextless" (gamepad_index: int) -> [2]f32 {
	return ctx.gamepads[gamepad_index].right_stick_delta
}

