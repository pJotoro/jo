package xinput

import win32 "core:sys/windows"
import "core:dynlib"
import "core:log"

@(private)
GetBatteryInformation_stub :: proc "system" (dwUserIndex: win32.DWORD, devType: win32.BYTE, pBatteryInformation: ^BATTERY_INFORMATION) -> win32.DWORD { return 1 }
@(private)
GetCapabilities_stub :: proc "system" (dwUserIndex: win32.DWORD, dwFlags: win32.DWORD, pCapabilities: ^CAPABILITIES) -> win32.DWORD { return 1 }
@(private)
GetKeystroke_stub :: proc "system" (dwUserIndex, dwReserved: win32.DWORD, pKeystroke: ^KEYSTROKE) -> win32.DWORD { return 1 }
@(private)
GetState_stub :: proc "system" (dwUserIndex: win32.DWORD, pState: ^STATE) -> win32.DWORD { return 1 }
@(private)
SetState_stub :: proc "system" (dwUserIndex: win32.DWORD, pVibration: ^VIBRATION) -> win32.DWORD { return 1 }

GetBatteryInformation := GetBatteryInformation_stub
GetCapabilities := GetCapabilities_stub
GetKeystroke := GetKeystroke_stub
GetState := GetState_stub
SetState := SetState_stub

// NOTE(pJotoro): I'm not even going to bother with XInputEnable. It's only relevant on Windows 8, which nobody uses.


BATTERY_INFORMATION :: struct {
	BatteryType: BATTERY_TYPE,
	BatteryLevel: BATTERY_LEVEL,
}

CAPABILITIES :: struct {
	Type: DEVTYPE,
	SubType: DEVSUBTYPE,
	Flags: CAPS,
	Gamepad: GAMEPAD,
	Vibration: VIBRATION,
}

GAMEPAD :: struct {
	wButtons: win32.WORD,
	bLeftTrigger: win32.BYTE,
	bRightTrigger: win32.BYTE,
	sThumbLX: win32.SHORT,
	sThumbLY: win32.SHORT,
	sThumbRX: win32.SHORT,
	sThumbRY: win32.SHORT,
}

KEYSTROKE :: struct {
  	VirtualKey: win32.WORD,
  	Unicode: win32.WCHAR,
  	Flags: win32.WORD,
  	UserIndex: win32.BYTE,
  	HidCode: win32.BYTE,
}

STATE :: struct {
	dwPacketNumber: win32.DWORD,
	Gamepad: GAMEPAD,
}

VIBRATION :: struct {
	wLeftMotorSpeed: win32.WORD,
	wRightMotorSpeed: win32.WORD,
}


BATTERY_TYPE :: enum win32.BYTE {
	DISCONNECTED,
	WIRED,
	ALKALINE,
	NIMH,
	UNKNOWN = 0xFF,
}

BATTERY_LEVEL :: enum win32.BYTE {
	EMPTY,
	LOW,
	MEDIUM,
	FULL,
}

CAP :: enum win32.WORD {
	FFB_SUPPORTED = 0,
	WIRELESS = 1,
	VOICE_SUPPORTED = 2,
	PMD_SUPPORTED = 3,
	NO_NAVIGATION = 4,
}
CAPS :: distinct bit_set[CAP; win32.WORD]

DEVTYPE :: enum win32.BYTE {
	GAMEPAD = 0x00000001,
}

DEVSUBTYPE :: enum win32.BYTE {
	GAMEPAD = 0x01,
	UNKNOWN = 0x00,
	WHEEL = 0x02,
	ARCADE_STICK = 0x03,
	FLIGHT_STICK = 0x04,
	DANCE_PAD = 0x05,
	GUITAR = 0x06,
	GUITAR_ALTERNATE = 0x07,
	DRUM_KIT = 0x08,
	GUITAR_BASS = 0x0B,
	ARCADE_PAD = 0x13,
}

ERROR_DEVICE_NOT_CONNECTED :: 1167

GAMEPAD_LEFT_THUMB_DEADZONE  :: 7849
GAMEPAD_RIGHT_THUMB_DEADZONE :: 8689
GAMEPAD_TRIGGER_THRESHOLD    :: 30

init :: proc(loc := #caller_location) -> bool {
	library: dynlib.Library
	ok: bool
	library, ok = dynlib.load_library("XINPUT1_4.DLL")
	if !ok {
		log.debug("Failed to load XInput 1.4, now trying XInput 1.3.", location = loc)
		library, ok = dynlib.load_library("XINPUT1_3.DLL")
		if !ok {
			log.debug("Failed to load XInput 1.3., now trying XInput 9.1.0.", location = loc)
			library, ok = dynlib.load_library("XINPUT9_1_0.DLL")
			if !ok {
				log.debug("Failed to load XInput 9.1.0.", location = loc)
				return false
			} else {
				log.debug("Succeeded to load XInput 9.1.0.", location = loc)
			}
		} else {
			log.debug("Succeeded to load XInput 1.3.", location = loc)
			GetKeystroke = auto_cast dynlib.symbol_address(library, "XInputGetKeystroke")
		}
	} else {
		log.debug("Succeeded to load XInput 1.4.", location = loc)
		GetBatteryInformation = auto_cast dynlib.symbol_address(library, "XInputGetBatteryInformation")
		GetKeystroke = auto_cast dynlib.symbol_address(library, "XInputGetKeystroke")
	}
	GetState = auto_cast dynlib.symbol_address(library, "XInputGetState")
	SetState = auto_cast dynlib.symbol_address(library, "XInputSetState")
	GetCapabilities = auto_cast dynlib.symbol_address(library, "XInputGetCapabilities")

	return true
}