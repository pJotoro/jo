package xinput

import win32 "core:sys/windows"
import "core:dynlib"

BOOL :: win32.BOOL
DWORD :: win32.DWORD
LPWSTR :: win32.LPWSTR
UINT :: win32.UINT
BYTE :: win32.BYTE
WORD :: win32.WORD
SHORT :: win32.SHORT
WCHAR :: win32.WCHAR

@(private)
GetState_stub :: proc "stdcall" (dwUserIndex: DWORD, pState: ^STATE) -> DWORD { return 1 }
@(private)
SetState_stub :: proc "stdcall" (dwUserIndex: DWORD, pVibration: ^VIBRATION) -> DWORD { return 1 }

GetState := GetState_stub
SetState := SetState_stub

GAMEPAD :: struct {
	wButtons: WORD,
	bLeftTrigger: BYTE,
	bRightTrigger: BYTE,
	sThumbLX: SHORT,
	sThumbLY: SHORT,
	sThumbRX: SHORT,
	sThumbRY: SHORT,
}

STATE :: struct {
	dwPacketNumber: DWORD,
	Gamepad: GAMEPAD,
}

VIBRATION :: struct {
	wLeftMotorSpeed: WORD,
	wRightMotorSpeed: WORD,
}

DEVTYPE_GAMEPAD :: 0x00000001

ERROR_DEVICE_NOT_CONNECTED :: 1167

GAMEPAD_LEFT_THUMB_DEADZONE  :: 7849
GAMEPAD_RIGHT_THUMB_DEADZONE :: 8689
GAMEPAD_TRIGGER_THRESHOLD    :: 30

init :: proc() -> bool {
	library: dynlib.Library
	ok: bool
	library, ok = dynlib.load_library("XINPUT1_4.DLL")
	if !ok {
		library, ok = dynlib.load_library("XINPUT9_1_0.DLL")
		if !ok {
			library, ok = dynlib.load_library("XINPUT1_3.DLL")
			if !ok do return false
		}
	}
	GetState = auto_cast dynlib.symbol_address(library, "XInputGetState")
	if GetState == nil do GetState = GetState_stub
	SetState = auto_cast dynlib.symbol_address(library, "XInputSetState")
	if SetState == nil do SetState = SetState_stub

	return true
}