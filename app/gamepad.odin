package app

import "core:fmt"
import "core:math"

Gamepad_Button :: enum u16 {
	Dpad_Up,
	Dpad_Down,
	Dpad_Left,
	Dpad_Right,
	Menu_Left,
	Menu_Right,
	Left_Stick,
	Right_Stick,
	Left_Bumper,
	Right_Bumper,
	A = 12,
	B,
	X,
	Y,
}

Gamepad_Buttons :: distinct bit_set[Gamepad_Button; u16]

Gamepad_Input :: struct {
	buttons: Gamepad_Buttons,

	left_trigger: f64,
	right_trigger: f64,
	left_stick: [2]f64,
	right_stick: [2]f64,
}

Gamepad :: struct {
	using gamepad_input: Gamepad_Input,
	connected: bool,

	trigger_deadzone: f64,
	left_stick_deadzone: f64,
	right_stick_deadzone: f64,
}

// Called for every possible gamepad by app.init().
// Called again by app.running() for every gamepad which is still connected.
//
// If the user already has their gamepad connected at initialization time and never disconnects it, then you'll never have to call this.
// In practice, it is very common for people to plug their gamepad in *after* opening a game, which means you will have to call this.
// The way I would recommend would be to make the player open a menu where they have to say they have connected a gamepad.
// Then, call this procedure again.
// If it fails, then the player lied to you. If it succeeds, then as long as their gamepad stays connected, you won't have to call this again.
//
// Depending on the target platform, the player may have to do something with their gamepad before it is detected.
try_connect_gamepad :: proc(ctx: ^Context, g_idx: int) {
	_try_connect_gamepad(ctx, g_idx)
	g := &ctx.gamepads[g_idx]
	if g.connected {
		g.left_trigger = remove_deadzone(g.left_trigger, g.trigger_deadzone)
		g.right_trigger = remove_deadzone(g.right_trigger, g.trigger_deadzone)
		g.left_stick.x = remove_deadzone(g.left_stick.x, g.left_stick_deadzone)
		g.left_stick.y = remove_deadzone(g.left_stick.y, g.left_stick_deadzone)
		g.right_stick.x = remove_deadzone(g.right_stick.x, g.right_stick_deadzone)
		g.right_stick.y = remove_deadzone(g.right_stick.y, g.right_stick_deadzone)

		g.left_stick.x, g.left_stick.y = clamp_magnitude(g.left_stick.x, g.left_stick.y)
		g.right_stick.x, g.right_stick.y = clamp_magnitude(g.right_stick.x, g.right_stick.y)

		remove_deadzone :: proc "contextless" (v, d: f64) -> f64 {
			s := math.sign(v)
			v := abs(v)
			minv := max(v-d, 0)
			maxv := 1-d
			return s*v*minv/maxv
		}

		clamp_magnitude :: proc "contextless" (x0, y0: f64) -> (x1, y1: f64) {
			squared_magnitude := x0*x0 + y0*y0
			if squared_magnitude > 1 {
				scale := 1.0 / math.sqrt(squared_magnitude)
				x1 = x0 * scale
				y1 = y0 * scale
			} else {
				x1 = x0
				y1 = y0 
			}
			return
		}
	}
}

// left_motor and right_motor must be normalized floating point values.
gamepad_set_vibration :: proc(ctx: ^Context, g_idx: int, left_motor, right_motor: f64) {
	left_motor := left_motor
	right_motor := right_motor
	fmt.assertf(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1, "App: motors must be in range [0.0, 1.0]. Got %v and %v.", left_motor, right_motor)
	if !ctx.gamepads[g_idx].connected {
		return
	}
	res := _gamepad_set_vibration(ctx, g_idx, left_motor, right_motor)
	fmt.assertf(res, "App: failed to set vibration for gamepad %v.", g_idx)
}

// Returns the battery level of a gamepad as a normalized float. 1=full, 0=empty.
gamepad_battery_level :: proc(ctx: ^Context, g_idx: int) -> (battery_level: f64, has_battery: bool) {
	if !ctx.gamepads[g_idx].connected {
		return
	}
	battery_level, has_battery = _gamepad_battery_level(ctx, g_idx)
	return
}

Gamepad_Type :: enum {
	Unknown,
	Gamepad,
	Wheel,
	Arcade_Stick,
	Flight_Stick,
	Dance_Pad,
	Guitar,
	Drum_Kit,
}

Gamepad_Flag :: enum {
	Voice,
	Wireless,
	Navigation,
}
Gamepad_Flags :: distinct bit_set[Gamepad_Flag]

Gamepad_Capabilities :: struct {
	using gamepad_input: Gamepad_Input,
	left_motor, right_motor: f64,
	type: Gamepad_Type,
	flags: Gamepad_Flags,
}

gamepad_capabilities :: proc(ctx: ^Context, g_idx: int) -> (capabilities: Gamepad_Capabilities) {
	if !ctx.gamepads[g_idx].connected {
		return
	}
	ok: bool
	capabilities, ok = _gamepad_capabilities(ctx, g_idx)
	fmt.assertf(ok, "App: failed to get capabilities for gamepad %v.", g_idx)
	return
}