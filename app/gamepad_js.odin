package app

import "core:sys/wasm/js"

import "core:log"

import "core:fmt"

_try_connect_gamepad :: proc(gamepad_index: int, loc := #caller_location) -> bool {
	gamepad_state: js.Gamepad_State
	if !js.get_gamepad_state(gamepad_index, &gamepad_state) {
		return false
	}
	if !gamepad_state.connected {
		return false
	}
	
	gamepad := &ctx.gamepads[gamepad_index]
	gamepad.active = gamepad_state.connected
	if !gamepad.active {
		return false
	} else {
		gamepad.buttons_previous = gamepad.buttons
		gamepad.buttons = {}

		// TODO: Gamepad assumped to be XInput with standard mapping.

		Gamepad_Button_Name :: enum {
			A,
			B,
			X,
			Y,
			Left_Bumper,
			Right_Bumper,
			Left_Trigger,
			Right_Trigger,
			Menu_Left,
			Menu_Right,
			Left_Stick,
			Right_Stick,
			Dpad_Up,
			Dpad_Down,
			Dpad_Left,
			Dpad_Right
		}

		if gamepad_state.buttons[int(Gamepad_Button_Name.A)].pressed {
			gamepad.buttons += {.A}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.B)].pressed {
			gamepad.buttons += {.B}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.X)].pressed {
			gamepad.buttons += {.X}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Y)].pressed {
			gamepad.buttons += {.Y}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Left_Bumper)].pressed {
			gamepad.buttons += {.Left_Bumper}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Right_Bumper)].pressed {
			gamepad.buttons += {.Right_Bumper}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Left_Trigger)].pressed {
			gamepad.left_trigger = gamepad_state.buttons[int(Gamepad_Button_Name.Left_Trigger)].value
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Right_Trigger)].pressed {
			gamepad.right_trigger = gamepad_state.buttons[int(Gamepad_Button_Name.Right_Trigger)].value
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Menu_Left)].pressed {
			gamepad.buttons += {.Menu_Left}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Menu_Right)].pressed {
			gamepad.buttons += {.Menu_Right}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Left_Stick)].pressed {
			gamepad.buttons += {.Left_Stick}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Right_Stick)].pressed {
			gamepad.buttons += {.Right_Stick}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Dpad_Up)].pressed {
			gamepad.buttons += {.Dpad_Up}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Dpad_Down)].pressed {
			gamepad.buttons += {.Dpad_Down}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Dpad_Left)].pressed {
			gamepad.buttons += {.Dpad_Left}
		}
		if gamepad_state.buttons[int(Gamepad_Button_Name.Dpad_Right)].pressed {
			gamepad.buttons += {.Dpad_Right}
		}

		gamepad_debug(gamepad_index)
	}

	return true
}

_gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f64, loc := #caller_location) -> bool {
	unimplemented()
}

_gamepad_battery_level :: proc(gamepad_index: int, loc := #caller_location) -> (battery_level: Gamepad_Battery_Level, has_battery: bool) {
	unimplemented()
}

_gamepad_capabilities :: proc(gamepad_index: int, loc := #caller_location) -> (capabilities: Gamepad_Capabilities, ok: bool) {
	unimplemented()
}