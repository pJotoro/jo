package app

import "base:runtime"
import "core:log"

Gamepad_Button :: enum u16 {
	Dpad_Up,
	Dpad_Down,
	Dpad_Left,
	Dpad_Right,
	Menu_Left,
	Menu_Right,
	Left_Stick,
	Right_Stick,
	Left_Bumper,
	Right_Bumper,
	A = 12,
	B,
	X,
	Y,
}

Gamepad_Buttons :: distinct bit_set[Gamepad_Button; u16]

@(private)
Gamepad_Input :: struct {
	buttons: Gamepad_Buttons,

	left_trigger: f64,
	right_trigger: f64,
	left_stick: [2]f64,
	right_stick: [2]f64,
}

@(private)
Gamepad_Desc :: struct {
	using gamepad_input: Gamepad_Input,

	buttons_previous: Gamepad_Buttons,

	left_trigger_delta: f64,
	right_trigger_delta: f64,
	left_stick_delta: [2]f64,
	right_stick_delta: [2]f64,

	packet_number: u32, // TODO(pJotoro): Do other platforms have a similar concept? I'm assuming they do.
	active: bool,
}

// Called for every possible gamepad by app.init().
// Called again by app.running() for every gamepad which is still connected.
//
// If the user already has their gamepad connected at initialization time and never disconnects it, then you'll never have to call this.
// In practice, it is very common for people to plug their gamepad in *after* opening a game, which means you will have to call this.
// The way I would recommend would be to make the player open a menu where they have to say they have connected a gamepad.
// Then, call this procedure again.
// If it fails, then the player lied to you. If it succeeds, then as long as their gamepad stays connected, you won't have to call this again.
//
// Depending on the target platform, the player may have to do something with their gamepad before it is detected.
try_connect_gamepad :: proc(gamepad_index: int, loc := #caller_location) -> bool {
	runtime.bounds_check_error_loc(loc, gamepad_index, len(ctx.gamepads))
	log_connected := !ctx.gamepads[gamepad_index].active // Only log connected if gamepad not already connected
	if !_try_connect_gamepad(gamepad_index, loc) {
		log.infof("App: gamepad %v disconnected.", gamepad_index, location = loc)
		return false
	} else {
		if log_connected {
			log.infof("App: gamepad %v connected.", gamepad_index, location = loc)
		}
		return true
	}
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

// Returns left trigger as a normalized floating point value.
gamepad_left_trigger :: proc "contextless" (gamepad_index: int) -> f64 {
	return ctx.gamepads[gamepad_index].left_trigger
}

// Returns right trigger as a normalized floating point value.
gamepad_right_trigger :: proc "contextless" (gamepad_index: int) -> f64 {
	return ctx.gamepads[gamepad_index].right_trigger
}

// Returns left stick as a 2D vector of normalized floating point values.
gamepad_left_stick :: proc "contextless" (gamepad_index: int) -> [2]f64 {
	return ctx.gamepads[gamepad_index].left_stick
}

// Returns right stick as a 2D vector of normalized floating point values.
gamepad_right_stick :: proc "contextless" (gamepad_index: int) -> [2]f64 {
	return ctx.gamepads[gamepad_index].right_stick
}

// left_motor and right_motor must be normalized floating point values.
gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f64, loc := #caller_location) {
	left_motor := left_motor
	right_motor := right_motor
	if !(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1) {
		log.warnf("App: motors must be in range [0.0, 1.0]. Got %v and %v.", left_motor, right_motor, location = loc)
		left_motor = clamp(left_motor, 0.0, 1.0)
		right_motor = clamp(right_motor, 0.0, 1.0)
	}
	if !ctx.gamepads[gamepad_index].active {
		return
	}
	if !_gamepad_set_vibration(gamepad_index, left_motor, right_motor, loc) {
		log.errorf("App: failed to set vibration for gamepad %v.", gamepad_index, location = loc)
	} else {
		log.debugf("App: succeeded to set vibration for gamepad %v.", gamepad_index, location = loc)
	}
}

gamepad_left_trigger_delta :: proc "contextless" (gamepad_index: int) -> f64 {
	return ctx.gamepads[gamepad_index].left_trigger_delta
}

gamepad_right_trigger_delta :: proc "contextless" (gamepad_index: int) -> f64 {
	return ctx.gamepads[gamepad_index].right_trigger_delta
}

gamepad_left_stick_delta :: proc "contextless" (gamepad_index: int) -> [2]f64 {
	return ctx.gamepads[gamepad_index].left_stick_delta
}

gamepad_right_stick_delta :: proc "contextless" (gamepad_index: int) -> [2]f64 {
	return ctx.gamepads[gamepad_index].right_stick_delta
}

// Returns the battery level of a gamepad as a normalized float. 1=full, 0=empty.
gamepad_battery_level :: proc(gamepad_index: int, loc := #caller_location) -> (battery_level: f64, has_battery: bool) {
	if !ctx.gamepads[gamepad_index].active {
		return
	}
	battery_level, has_battery = _gamepad_battery_level(gamepad_index, loc)
	if !has_battery {
		log.errorf("App: failed to get battery level for gamepad %v.", gamepad_index, location = loc)
	} else {
		log.debugf("App: succeeded to get vattery level for gamepad %v.", gamepad_index, location = loc)
	}
	return
}

Gamepad_Type :: enum {
	Unknown,
	Gamepad,
	Wheel,
	Arcade_Stick,
	Flight_Stick,
	Dance_Pad,
	Guitar,
	Drum_Kit,
}

Gamepad_Flag :: enum {
	Voice,
	Wireless,
	Navigation,
}
Gamepad_Flags :: distinct bit_set[Gamepad_Flag]

Gamepad_Capabilities :: struct {
	using gamepad_input: Gamepad_Input,
	left_motor, right_motor: f64,
	type: Gamepad_Type,
	flags: Gamepad_Flags,
}

gamepad_capabilities :: proc(gamepad_index: int, loc := #caller_location) -> (capabilities: Gamepad_Capabilities, ok: bool) {
	if !ctx.gamepads[gamepad_index].active {
		return
	}
	capabilities, ok = _gamepad_capabilities(gamepad_index, loc)
	if !ok {
		log.errorf("App: failed to get capabilities for gamepad %v.", gamepad_index, location = loc)
	} else {
		log.debugf("App: succeeded to get capabilities for gamepad %v.", gamepad_index, location = loc)
	}
	return
}