#+ private
package app

import "jo:misc"

import win32 "core:sys/windows"
import "core:log"

_try_connect_gamepad :: proc(gamepad_index: int, loc := #caller_location) -> bool {
	state: win32.XINPUT_STATE = ---
	
	result := win32.XInputGetState(win32.XUSER(gamepad_index), &state)
	if result != .SUCCESS {
		log.infof("Gamepad %v disconnected.", gamepad_index, location = loc)
		ctx.gamepads[gamepad_index].active = false
		return false
	}
	if !ctx.gamepads[gamepad_index].active {
		log.infof("Gamepad %v connected.", gamepad_index, location = loc)
	}
	ctx.gamepads[gamepad_index].active = true
	if ctx.gamepads[gamepad_index].packet_number != state.dwPacketNumber {
		// TODO(pJotoro): We could make gamepad input delta be in the crossplatform code, considering that it doesn't use any Windows procedures. I might do that eventually. The only reason
		// I haven't is because I'm not sure if other gamepad input APIs already calculate the input delta for you.

		left_trigger_previous := ctx.gamepads[gamepad_index].left_trigger
		right_trigger_previous := ctx.gamepads[gamepad_index].right_trigger
		left_stick_previous := ctx.gamepads[gamepad_index].left_stick
		right_stick_previous := ctx.gamepads[gamepad_index].right_stick

		get_input(&ctx.gamepads[gamepad_index], state.Gamepad)

		ctx.gamepads[gamepad_index].left_trigger_delta = ctx.gamepads[gamepad_index].left_trigger - left_trigger_previous
		ctx.gamepads[gamepad_index].right_trigger_delta = ctx.gamepads[gamepad_index].right_trigger - right_trigger_previous
		ctx.gamepads[gamepad_index].left_stick_delta = ctx.gamepads[gamepad_index].left_stick - left_stick_previous
		ctx.gamepads[gamepad_index].right_stick_delta = ctx.gamepads[gamepad_index].right_stick - right_stick_previous

		// NOTE(pJotoro): If the gamepad's state hasn't changed at all, debug info about it doesn't get outputted. This is nice because it prevents the console from getting flooded. The only
		// issue is if you press buttons not enabled for debug output, debug output will still happen anyway. I don't think it's worth it to fix this.
		gamepad_debug(gamepad_index)
	} else {
		ctx.gamepads[gamepad_index].buttons_previous = ctx.gamepads[gamepad_index].buttons
		
		ctx.gamepads[gamepad_index].left_trigger_delta = 0.0
		ctx.gamepads[gamepad_index].right_trigger_delta = 0.0
		ctx.gamepads[gamepad_index].left_stick_delta = {0.0, 0.0}
		ctx.gamepads[gamepad_index].right_stick_delta = {0.0, 0.0}
	}
	ctx.gamepads[gamepad_index].packet_number = state.dwPacketNumber

	get_input :: proc "contextless" (gamepad: ^Gamepad_Desc, xinput_gamepad: win32.XINPUT_GAMEPAD) {
		xinput_gamepad := xinput_gamepad
		cut_deadzones(&xinput_gamepad)
	
		@static TRIGGER_MAX := f64(max(win32.BYTE) - win32.BYTE(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD))
		@static LEFT_THUMB_MAX := f64(max(win32.SHORT) - win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)
		@static RIGHT_THUMB_MAX := f64(max(win32.SHORT) - win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)
	
		gamepad.buttons_previous = gamepad.buttons
		gamepad.buttons = transmute(Gamepad_Buttons)xinput_gamepad.wButtons
	
		gamepad.left_trigger = f64(xinput_gamepad.bLeftTrigger) / TRIGGER_MAX
		gamepad.right_trigger = f64(xinput_gamepad.bRightTrigger) / TRIGGER_MAX
		gamepad.left_stick.x = f64(xinput_gamepad.sThumbLX) / LEFT_THUMB_MAX
		gamepad.left_stick.y = f64(xinput_gamepad.sThumbLY) / LEFT_THUMB_MAX
		gamepad.right_stick.x = f64(xinput_gamepad.sThumbRX) / RIGHT_THUMB_MAX
		gamepad.right_stick.y = f64(xinput_gamepad.sThumbRY) / RIGHT_THUMB_MAX

		// NOTE(pJotoro): In theory, this shouldn't be necessary.
		// The above code should already normalize all the values.
		// But, some gamepads have more or less threshold than others,
		// so the input can actually go above 1.0 or below -1.0 (like
		// my controller). That said, the amount shouldn't be that high.
		gamepad.left_trigger = clamp(gamepad.left_trigger, -1.0, 1.0)
		gamepad.right_trigger = clamp(gamepad.right_trigger, -1.0, 1.0)
		gamepad.left_stick.x = clamp(gamepad.left_stick.x, -1.0, 1.0)
		gamepad.left_stick.y = clamp(gamepad.left_stick.y, -1.0, 1.0)
		gamepad.right_stick.x = clamp(gamepad.right_stick.x, -1.0, 1.0)
		gamepad.right_stick.y = clamp(gamepad.right_stick.y, -1.0, 1.0)
	
		cut_deadzones :: proc "contextless" (xinput_gamepad: ^win32.XINPUT_GAMEPAD) {
			xinput_gamepad.bLeftTrigger -= win32.BYTE(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD) if xinput_gamepad.bLeftTrigger >= win32.BYTE(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD) else xinput_gamepad.bLeftTrigger
			xinput_gamepad.bRightTrigger -= win32.BYTE(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD) if xinput_gamepad.bRightTrigger >= win32.BYTE(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD) else xinput_gamepad.bRightTrigger
	
			if xinput_gamepad.sThumbLX < win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE && xinput_gamepad.sThumbLX > -win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE { 
				xinput_gamepad.sThumbLX = 0 
			} else if xinput_gamepad.sThumbLX > 0 { 
				xinput_gamepad.sThumbLX -= win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE 
			} else if xinput_gamepad.sThumbLX < 0 {
				xinput_gamepad.sThumbLX += win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE
			}
	
			if xinput_gamepad.sThumbLY < win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE && xinput_gamepad.sThumbLY > -win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE {
				xinput_gamepad.sThumbLY = 0
			} else if xinput_gamepad.sThumbLY > 0 {
				xinput_gamepad.sThumbLY -= win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE
			} else if xinput_gamepad.sThumbLY < 0 {
				xinput_gamepad.sThumbLY += win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE
			}
	
			if xinput_gamepad.sThumbRX < win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE && xinput_gamepad.sThumbRX > -win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE {
				xinput_gamepad.sThumbRX = 0
			} else if xinput_gamepad.sThumbRX > 0 {
				xinput_gamepad.sThumbRX -= win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE
			} else if xinput_gamepad.sThumbRX < 0 {
				xinput_gamepad.sThumbRX += win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE
			}
	
			if xinput_gamepad.sThumbRY < win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE && xinput_gamepad.sThumbRY > -win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE {
				xinput_gamepad.sThumbRY = 0
			} else if xinput_gamepad.sThumbRY > 0 {
				xinput_gamepad.sThumbRY -= win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE
			} else if xinput_gamepad.sThumbRY < 0 {
				xinput_gamepad.sThumbRY += win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE
			}
		}
	}
	
	return true
}

_gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f64, loc := #caller_location) {
	xinput_vibration: win32.XINPUT_VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f64(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f64(max(u16)))
	result := win32.XInputSetState(win32.XUSER(gamepad_index), &xinput_vibration)
	if result != .SUCCESS {
		log.errorf("Failed to set vibration for gamepad %v.", gamepad_index, location = loc)
	} else { 
		log.debugf("Succeeded to set vibration for gamepad %v.", gamepad_index, location = loc)
	}
}

_gamepad_battery_level :: proc(gamepad_index: int, loc := #caller_location) -> (battery_level: Gamepad_Battery_Level, has_battery: bool) {
	info: win32.XINPUT_BATTERY_INFORMATION
	res := win32.XInputGetBatteryInformation(win32.XUSER(gamepad_index), {}, &info)
	if res != .SUCCESS {
		log.errorf("Failed to get battery level for gamepad %v.", gamepad_index, location = loc)
		return
	} else {
		log.debugf("Succeeded to get vattery level for gamepad %v.", gamepad_index, location = loc)
	}
	switch info.BatteryType {
		case .DISCONNECTED, .WIRED, .UNKNOWN:
		case .ALKALINE, .NIMH:
			battery_level = Gamepad_Battery_Level(info.BatteryLevel)
			has_battery = true
	}
	return
}

_gamepad_capabilities :: proc(gamepad_index: int, loc := #caller_location) -> (capabilities: Gamepad_Capabilities, ok: bool) {
	c: win32.XINPUT_CAPABILITIES
	res := win32.XInputGetCapabilities(win32.XUSER(gamepad_index), {}, &c)
	if res != .SUCCESS {
		log.errorf("Failed to get capabilities for gamepad %v.", gamepad_index, location = loc)
		return
	} else {
		log.debugf("Succeeded to get capabilities for gamepad %v.", gamepad_index, location = loc)
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