// +private
package app

_try_connect_gamepad :: proc(gamepad_index: int) -> bool {
    unimplemented()
}

_gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f32) {
    unimplemented()
}

_gamepad_battery_level :: proc(gamepad_index: int) -> (battery_level: Gamepad_Battery_Level, has_battery: bool) {
    unimplemented()
}

_gamepad_capabilities :: proc(gamepad_index: int) -> (capabilities: Gamepad_Capabilities, ok: bool) {
    unimplemented()
}