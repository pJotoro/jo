//+private
package app

import win32 "core:sys/windows"
import "xinput"

_try_connect_gamepad :: proc "contextless" (gamepad_index: int, loc := #caller_location) -> bool {
	state: xinput.STATE = ---
	result := xinput.GetState(win32.DWORD(gamepad_index), &state)
	if result != win32.ERROR_SUCCESS {
		ctx.gamepads[gamepad_index].active = false
		return false
	}
	ctx.gamepads[gamepad_index].active = true
	get_input(&ctx.gamepads[gamepad_index], state.Gamepad)
	return true

	get_input :: proc "contextless" (gamepad: ^Gamepad_Desc, xinput_gamepad: xinput.GAMEPAD) {
		xinput_gamepad := xinput_gamepad
		cut_deadzones(&xinput_gamepad)
	
		TRIGGER_MAX := f32(max(win32.BYTE) - win32.BYTE(xinput.GAMEPAD_TRIGGER_THRESHOLD))
		LEFT_THUMB_MAX := f32(max(win32.SHORT) - xinput.GAMEPAD_LEFT_THUMB_DEADZONE)
		RIGHT_THUMB_MAX := f32(max(win32.SHORT) - xinput.GAMEPAD_RIGHT_THUMB_DEADZONE)
	
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
	}
}

_gamepad_set_vibration :: proc "contextless" (gamepad_index: int, left_motor, right_motor: f32, loc := #caller_location) {
	if !ctx.gamepads[gamepad_index].active do return

	xinput_vibration: xinput.VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	xinput.SetState(win32.DWORD(gamepad_index), &xinput_vibration)
}