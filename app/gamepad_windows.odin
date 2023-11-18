//+private
package app

import "core:runtime"
import win32 "core:sys/windows"
import "xinput"

_gamepad :: proc(index: int, loc := #caller_location) -> (gamepad: Gamepad) {
	runtime.bounds_check_error_loc(loc, index, len(ctx.gamepads))

	state: xinput.STATE = ---
	result := xinput.GetState(win32.DWORD(index), &state)
	if result != win32.ERROR_SUCCESS {
		ctx.gamepads[index].id = INVALID_GAMEPAD
		gamepad = INVALID_GAMEPAD
		return
	}

	if ctx.gamepads[index].id != -1 {
		gamepad = ctx.gamepads[index].id
		return
	}

	gamepad = ctx.next_gamepad_id
	ctx.gamepads[index].id = gamepad
	ctx.gamepads[index].type = .Xbox_One // TODO(pJotoro): Find out the actual controller type.
	ctx.next_gamepad_id += 1
	return
}

_gamepad_set_vibration :: proc(id: Gamepad, left_motor, right_motor: f32, loc := #caller_location) {
	assert(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1, "motors out of range 0..1", loc)

	i := gamepad_index(id)
	if i == -1 do return

	xinput_vibration: xinput.VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	xinput.SetState(win32.DWORD(i), &xinput_vibration)
}

gamepad_get_input :: proc(gamepad: ^Gamepad_Desc, xinput_gamepad: xinput.GAMEPAD) {
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

	cut_deadzones :: proc(xinput_gamepad: ^xinput.GAMEPAD) {
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

_gamepads_get_input :: proc() {
    for &gamepad, i in ctx.gamepads {
        if gamepad.id != INVALID_GAMEPAD {
            state: xinput.STATE = ---
            result := xinput.GetState(win32.DWORD(i), &state)
            if result != win32.ERROR_SUCCESS {
                gamepad.id = INVALID_GAMEPAD
                continue
            }
            gamepad_get_input(&gamepad, state.Gamepad)
        }
    }
}