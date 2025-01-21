package app

import win32 "core:sys/windows"
import "core:fmt"

_try_connect_gamepad :: proc(ctx: ^Context, g_idx: int) {
	state: win32.XINPUT_STATE = ---
	
	result := win32.XInputGetState(win32.XUSER(g_idx), &state)
	if result != .SUCCESS {
		ctx.gamepads[g_idx] = {}
		return
	}
	ctx.gamepads[g_idx].connected = true

	xinput_gamepad := state.Gamepad

	ctx.gamepads[g_idx].buttons = transmute(Gamepad_Buttons)xinput_gamepad.wButtons
	
	ctx.gamepads[g_idx].left_trigger = f64(xinput_gamepad.bLeftTrigger)/f64(max(win32.BYTE))
	ctx.gamepads[g_idx].right_trigger = f64(xinput_gamepad.bRightTrigger)/f64(max(win32.BYTE))
	ctx.gamepads[g_idx].left_stick.x = f64(xinput_gamepad.sThumbLX)/f64(max(win32.SHORT))
	ctx.gamepads[g_idx].left_stick.y = f64(xinput_gamepad.sThumbLY)/f64(max(win32.SHORT))
	ctx.gamepads[g_idx].right_stick.x = f64(xinput_gamepad.sThumbRX)/f64(max(win32.SHORT))
	ctx.gamepads[g_idx].right_stick.y = f64(xinput_gamepad.sThumbRY)/f64(max(win32.SHORT))

	// TODO: custom deadzones?

	ctx.gamepads[g_idx].trigger_deadzone = f64(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD)/f64(max(win32.BYTE))
	ctx.gamepads[g_idx].left_stick_deadzone = f64(win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)/f64(max(win32.SHORT))
	ctx.gamepads[g_idx].right_stick_deadzone = f64(win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)/f64(max(win32.SHORT))
}

_gamepad_set_vibration :: proc(ctx: ^Context, g_idx: int, left_motor, right_motor: f64) -> bool {
	xinput_vibration: win32.XINPUT_VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f64(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f64(max(u16)))
	return win32.XInputSetState(win32.XUSER(g_idx), &xinput_vibration) == .SUCCESS
}

_gamepad_battery_level :: proc(ctx: ^Context, g_idx: int) -> (battery_level: f64, has_battery: bool) {
	info: win32.XINPUT_BATTERY_INFORMATION
	res := win32.XInputGetBatteryInformation(win32.XUSER(g_idx), {}, &info)
	fmt.assertf(res == .SUCCESS, "Win32: failed to get battery level information for gamepad %v", g_idx)
	switch info.BatteryType {
		case .DISCONNECTED, .WIRED, .UNKNOWN:
		case .ALKALINE, .NIMH:
			switch info.BatteryLevel {
				case .EMPTY:
					battery_level = 0
				case .LOW:
					battery_level = 1.0/3.0
				case .MEDIUM:
					battery_level = 2.0/3.0
				case .FULL:
					battery_level = 1
			}
			has_battery = true
	}
	return
}

_gamepad_capabilities :: proc(ctx: ^Context, g_idx: int) -> (capabilities: Gamepad_Capabilities, ok: bool) {
	c: win32.XINPUT_CAPABILITIES
	res := win32.XInputGetCapabilities(win32.XUSER(g_idx), {}, &c)
	if res != .SUCCESS {	
		return
	}

	switch c.SubType {
		case .UNKNOWN:
			capabilities.type = .Unknown
		case .GAMEPAD:
			capabilities.type = .Gamepad
		case .WHEEL:
			capabilities.type = .Wheel
		case .ARCADE_STICK, .ARCADE_PAD:
			capabilities.type = .Arcade_Stick
		case .FLIGHT_STICK:
			capabilities.type = .Flight_Stick
		case .DANCE_PAD:
			capabilities.type = .Dance_Pad
		case .DRUM_KIT:
			capabilities.type = .Drum_Kit
		case .GUITAR, .GUITAR_ALTERNATE, .GUITAR_BASS:
			capabilities.type = .Guitar
	}

	if .WIRELESS in c.Flags {
		capabilities.flags += {.Wireless}
	}
	if .VOICE_SUPPORTED in c.Flags {
		capabilities.flags += {.Voice}
	}
	if .NO_NAVIGATION not_in c.Flags {
		capabilities.flags += {.Navigation}
	}

	capabilities.buttons = transmute(Gamepad_Buttons)c.Gamepad.wButtons
	capabilities.left_trigger = f64(c.Gamepad.bLeftTrigger) / f64(max(win32.BYTE))
	capabilities.right_trigger = f64(c.Gamepad.bRightTrigger) / f64(max(win32.BYTE))
	capabilities.left_stick.x = f64(c.Gamepad.sThumbLX) / f64(max(win32.SHORT))
	capabilities.left_stick.y = f64(c.Gamepad.sThumbLY) / f64(max(win32.SHORT))
	capabilities.right_stick.x = f64(c.Gamepad.sThumbRX) / f64(max(win32.SHORT))
	capabilities.right_stick.y = f64(c.Gamepad.sThumbRY) / f64(max(win32.SHORT))
	capabilities.left_motor = f64(c.Vibration.wLeftMotorSpeed) / f64(max(win32.WORD))
	capabilities.right_motor = f64(c.Vibration.wRightMotorSpeed) / f64(max(win32.WORD))

	ok = true
	return
}