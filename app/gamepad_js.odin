package app

import "core:sys/wasm/js"

import "core:log"

// TODO: WASM makes an event when a gamepad is connected or disconnected. Make use of this?
_try_connect_gamepad :: proc(gamepad_index: int, loc := #caller_location) -> bool {
	gamepad_state: js.Gamepad_State
	if !js.get_gamepad_state(gamepad_index, &gamepad_state) {
		return false
	}
	if !gamepad_state.connected {
		return false
	}
	log.info(gamepad_state)
	return true
}

_gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f32, loc := #caller_location) {
	unimplemented()
}

_gamepad_battery_level :: proc(gamepad_index: int, loc := #caller_location) -> (battery_level: Gamepad_Battery_Level, has_battery: bool) {
	unimplemented()
}

_gamepad_capabilities :: proc(gamepad_index: int, loc := #caller_location) -> (capabilities: Gamepad_Capabilities, ok: bool) {
	unimplemented()
}