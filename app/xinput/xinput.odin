package xinput

import win32 "core:sys/windows"
import "core:dynlib"
import "core:log"

BOOL :: win32.BOOL
DWORD :: win32.DWORD
LPWSTR :: win32.LPWSTR
UINT :: win32.UINT
BYTE :: win32.BYTE
WORD :: win32.WORD
SHORT :: win32.SHORT
WCHAR :: win32.WCHAR

@(private)
GetState_stub :: proc "system" (dwUserIndex: DWORD, pState: ^STATE) -> DWORD { return 1 }
@(private)
SetState_stub :: proc "system" (dwUserIndex: DWORD, pVibration: ^VIBRATION) -> DWORD { return 1 }
@(private)
GetCapabilities_stub :: proc "system" (dwUserIndex: DWORD, dwFlags: DWORD, pCapabilities: ^CAPABILITIES) -> DWORD { return 1 }

GetState := GetState_stub
SetState := SetState_stub
GetCapabilities := GetCapabilities_stub

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

CAP :: enum WORD {
	FFB_SUPPORTED = 0,
	WIRELESS = 1,
	VOICE_SUPPORTED = 2,
	PMD_SUPPORTED = 3,
	NO_NAVIGATION = 4,
}
CAPS :: distinct bit_set[CAP; WORD]

CAPABILITIES :: struct {
	Type: DEVTYPE,
	SubType: DEVSUBTYPE,
	Flags: CAPS,
	Gamepad: GAMEPAD,
	Vibration: VIBRATION,
}

DEVTYPE :: enum BYTE {
	GAMEPAD = 0x00000001
}

DEVSUBTYPE :: enum BYTE {
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

// NOTE(pJotoro): I'm not even going to bother with XInputEnable. It's only relevant on Windows 8, which nobody uses.

BATTERY_TYPE :: enum BYTE {
	DISCONNECTED,
	WIRED,
	ALKALINE,
	NIMH,
	UNKNOWN = 0xFF,
}

BATTERY_LEVEL :: enum BYTE {
	EMPTY,
	LOW,
	MEDIUM,
	FULL,
}

BATTERY_INFORMATION :: struct {
	BatteryType: BATTERY_TYPE,
	BatteryLevel: BATTERY_LEVEL,
}

@(private)
GetBatteryInformation_stub :: proc "system" (dwUserIndex: DWORD, devType: BYTE, pBatteryInformation: ^BATTERY_INFORMATION) -> DWORD { return 1 }

GetBatteryInformation := GetBatteryInformation_stub

init :: proc() -> bool {
	library: dynlib.Library
	ok: bool
	library, ok = dynlib.load_library("XINPUT1_4.DLL")
	if !ok {
		log.debug("Failed to load XInput 1.4, now trying XInput 1.3.")
		library, ok = dynlib.load_library("XINPUT1_3.DLL")
		if !ok {
			log.debug("Failed to load XInput 1.3., now trying XInput 9.1.0.")
			library, ok = dynlib.load_library("XINPUT9_1_0.DLL")
			if !ok {
				log.debug("Failed to load XInput 9.1.0.")
				return false
			}
			else {
				log.debug("Succeeded to load XInput 9.1.0.")
			}
		}
		else {
			log.debug("Succeeded to load XInput 1.3.")
		}
	}
	else {
		log.debug("Succeeded to load XInput 1.4.")
		GetBatteryInformation = auto_cast dynlib.symbol_address(library, "XInputGetBatteryInformation")
	}
	GetState = auto_cast dynlib.symbol_address(library, "XInputGetState")
	SetState = auto_cast dynlib.symbol_address(library, "XInputSetState")
	GetCapabilities = auto_cast dynlib.symbol_address(library, "XInputGetCapabilities")

	return true
}