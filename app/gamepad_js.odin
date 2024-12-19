package app

_try_connect_gamepad :: proc(gamepad_index: int, loc := #caller_location) -> bool {
	unimplemented()
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