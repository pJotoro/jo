//+private
package app

import win32 "core:sys/windows"
import "xinput"
import "core:log"

_try_connect_gamepad :: proc(gamepad_index: int) -> bool {
	state: xinput.STATE = ---
	result := xinput.GetState(win32.DWORD(gamepad_index), &state)
	if result != win32.ERROR_SUCCESS {
		log.infof("Gamepad %v disconnected.", gamepad_index)
		ctx.gamepads[gamepad_index].active = false
		return false
	}
	if !ctx.gamepads[gamepad_index].active {
		log.infof("Gamepad %v connected.", gamepad_index)
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
	
	return true

	get_input :: proc "contextless" (gamepad: ^Gamepad_Desc, xinput_gamepad: xinput.GAMEPAD) {
		xinput_gamepad := xinput_gamepad
		cut_deadzones(&xinput_gamepad)
	
		@static TRIGGER_MAX := f32(max(win32.BYTE) - win32.BYTE(xinput.GAMEPAD_TRIGGER_THRESHOLD))
		@static LEFT_THUMB_MAX := f32(max(win32.SHORT) - xinput.GAMEPAD_LEFT_THUMB_DEADZONE)
		@static RIGHT_THUMB_MAX := f32(max(win32.SHORT) - xinput.GAMEPAD_RIGHT_THUMB_DEADZONE)
	
		gamepad.buttons_previous = gamepad.buttons
		gamepad.buttons = transmute(Gamepad_Buttons)xinput_gamepad.wButtons
	
		gamepad.left_trigger = f32(xinput_gamepad.bLeftTrigger) / TRIGGER_MAX
		gamepad.right_trigger = f32(xinput_gamepad.bRightTrigger) / TRIGGER_MAX
		gamepad.left_stick.x = f32(xinput_gamepad.sThumbLX) / LEFT_THUMB_MAX
		gamepad.left_stick.y = f32(xinput_gamepad.sThumbLY) / LEFT_THUMB_MAX
		gamepad.right_stick.x = f32(xinput_gamepad.sThumbRX) / RIGHT_THUMB_MAX
		gamepad.right_stick.y = f32(xinput_gamepad.sThumbRY) / RIGHT_THUMB_MAX

		cut_deadzones :: proc "contextless" (xinput_gamepad: ^xinput.GAMEPAD) {
			xinput_gamepad.bLeftTrigger -= xinput_gamepad.bLeftTrigger >= win32.BYTE(xinput.GAMEPAD_TRIGGER_THRESHOLD) ? win32.BYTE(xinput.GAMEPAD_TRIGGER_THRESHOLD) : xinput_gamepad.bLeftTrigger
			xinput_gamepad.bRightTrigger -= xinput_gamepad.bRightTrigger >= win32.BYTE(xinput.GAMEPAD_TRIGGER_THRESHOLD) ? win32.BYTE(xinput.GAMEPAD_TRIGGER_THRESHOLD) : xinput_gamepad.bRightTrigger
	
			if xinput_gamepad.sThumbLX < xinput.GAMEPAD_LEFT_THUMB_DEADZONE && xinput_gamepad.sThumbLX > -xinput.GAMEPAD_LEFT_THUMB_DEADZONE { 
				xinput_gamepad.sThumbLX = 0 
			} else if xinput_gamepad.sThumbLX > 0 { 
				xinput_gamepad.sThumbLX -= xinput.GAMEPAD_LEFT_THUMB_DEADZONE 
			} else if xinput_gamepad.sThumbLX < 0 {
				xinput_gamepad.sThumbLX += xinput.GAMEPAD_LEFT_THUMB_DEADZONE
			}
	
			if xinput_gamepad.sThumbLY < xinput.GAMEPAD_LEFT_THUMB_DEADZONE && xinput_gamepad.sThumbLY > -xinput.GAMEPAD_LEFT_THUMB_DEADZONE {
				xinput_gamepad.sThumbLY = 0
			} else if xinput_gamepad.sThumbLY > 0 {
				xinput_gamepad.sThumbLY -= xinput.GAMEPAD_LEFT_THUMB_DEADZONE
			} else if xinput_gamepad.sThumbLY < 0 {
				xinput_gamepad.sThumbLY += xinput.GAMEPAD_LEFT_THUMB_DEADZONE
			}
	
			if xinput_gamepad.sThumbRX < xinput.GAMEPAD_RIGHT_THUMB_DEADZONE && xinput_gamepad.sThumbRX > -xinput.GAMEPAD_RIGHT_THUMB_DEADZONE {
				xinput_gamepad.sThumbRX = 0
			} else if xinput_gamepad.sThumbRX > 0 {
				xinput_gamepad.sThumbRX -= xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
			} else if xinput_gamepad.sThumbRX < 0 {
				xinput_gamepad.sThumbRX += xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
			}

			if xinput_gamepad.sThumbRY < xinput.GAMEPAD_RIGHT_THUMB_DEADZONE && xinput_gamepad.sThumbRY > -xinput.GAMEPAD_RIGHT_THUMB_DEADZONE {
				xinput_gamepad.sThumbRY = 0
			} else if xinput_gamepad.sThumbRY > 0 {
				xinput_gamepad.sThumbRY -= xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
			} else if xinput_gamepad.sThumbRY < 0 {
				xinput_gamepad.sThumbRY += xinput.GAMEPAD_RIGHT_THUMB_DEADZONE
			}
		}
	}
}

_gamepad_set_vibration :: proc(gamepad_index: int, left_motor, right_motor: f32) {
	if !ctx.gamepads[gamepad_index].active {
		return
	}

	xinput_vibration: xinput.VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	result := xinput.SetState(win32.DWORD(gamepad_index), &xinput_vibration)
	if result != win32.ERROR_SUCCESS {
		log.errorf("Failed to set vibration for gamepad %v.", gamepad_index)
	} else { 
		log.debugf("Succeeded to set vibration for gamepad %v.", gamepad_index)
	}
}