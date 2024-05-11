package app

import "core:fmt"

Gamepad_Debug_Flag :: enum u32 {
    Navigation,
    Thumb,
    Shoulder,
    Face, // A, B, X, Y
    Trigger,
    Stick,
    Down,
    Pressed,
    Released,
    Delta,
}

Gamepad_Debug_Flags :: distinct bit_set[Gamepad_Debug_Flag; u32]

// Enables debug output for gamepad inputs specified by flags.
gamepad_debug_enable :: proc "contextless" (flags: Gamepad_Debug_Flags) {
    ctx.gamepad_debug_flags += flags
}

// Disables debug output for gamepad inputs specified by flags.
gamepad_debug_disable :: proc "contextless" (flags: Gamepad_Debug_Flags) {
    ctx.gamepad_debug_flags -= flags
}

@(private)
gamepad_debug :: proc(gamepad_index: int) {
    if .Navigation in ctx.gamepad_debug_flags {
        if .Down in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v dpad up: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Up))
            fmt.printf("gamepad %v dpad down: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Down))
            fmt.printf("gamepad %v dpad left: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Left))
            fmt.printf("gamepad %v dpad right: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Right))
            fmt.printf("gamepad %v start: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Start))
            fmt.printf("gamepad %v back: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Back))
        }
        if .Pressed in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v dpad up pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Up))
            fmt.printf("gamepad %v dpad down pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Down))
            fmt.printf("gamepad %v dpad left pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Left))
            fmt.printf("gamepad %v dpad right pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Right))
            fmt.printf("gamepad %v start pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Start))
            fmt.printf("gamepad %v back pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Back))
        }
        if .Released in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v dpad up released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Up))
            fmt.printf("gamepad %v dpad down released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Down))
            fmt.printf("gamepad %v dpad left released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Left))
            fmt.printf("gamepad %v dpad right released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Right))
            fmt.printf("gamepad %v start released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Start))
            fmt.printf("gamepad %v back released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Back))
        }
    }

    if .Thumb in ctx.gamepad_debug_flags {
        if .Down in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left thumb: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Left_Thumb))
            fmt.printf("gamepad %v right thumb: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Right_Thumb))
        }
        if .Pressed in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left thumb pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Left_Thumb))
            fmt.printf("gamepad %v right thumb pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Right_Thumb))
        }
        if .Released in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left thumb released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Left_Thumb))
            fmt.printf("gamepad %v right thumb released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Right_Thumb))
        }
    }
    
    if .Shoulder in ctx.gamepad_debug_flags {
        if .Down in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left shoulder: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Left_Shoulder))
            fmt.printf("gamepad %v right shoulder: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Right_Shoulder))
        }
        if .Pressed in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left shoulder pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Left_Shoulder))
            fmt.printf("gamepad %v right shoulder pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Right_Shoulder))
        }
        if .Released in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left shoulder released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Left_Shoulder))
            fmt.printf("gamepad %v right shoulder released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Right_Shoulder))
        }
    }
    
    if .Face in ctx.gamepad_debug_flags {
        if .Down in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v A: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .A))
            fmt.printf("gamepad %v B: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .B))
            fmt.printf("gamepad %v X: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .X))
            fmt.printf("gamepad %v Y: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Y))
        }
        if .Pressed in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v A pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .A))
            fmt.printf("gamepad %v B pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .B))
            fmt.printf("gamepad %v X pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .X))
            fmt.printf("gamepad %v Y pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Y))
        }
        if .Released in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v A released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .A))
            fmt.printf("gamepad %v B released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .B))
            fmt.printf("gamepad %v X released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .X))
            fmt.printf("gamepad %v Y released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Y))
        }
    }
    
    if .Trigger in ctx.gamepad_debug_flags {
        fmt.printf("gamepad %v left trigger: %v\n", gamepad_index, gamepad_left_trigger(gamepad_index))
        fmt.printf("gamepad %v right trigger: %v\n", gamepad_index, gamepad_right_trigger(gamepad_index))
        if .Delta in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left trigger delta: %v\n", gamepad_index, gamepad_left_trigger_delta(gamepad_index))
            fmt.printf("gamepad %v right trigger delta: %v\n", gamepad_index, gamepad_right_trigger_delta(gamepad_index))
        }
    }

    if .Stick in ctx.gamepad_debug_flags {
        fmt.printf("gamepad %v left stick: %v\n", gamepad_index, gamepad_left_stick(gamepad_index))
        fmt.printf("gamepad %v right stick: %v\n", gamepad_index, gamepad_right_stick(gamepad_index))
        if .Delta in ctx.gamepad_debug_flags {
            fmt.printf("gamepad %v left stick delta: %v\n", gamepad_index, gamepad_left_stick_delta(gamepad_index))
            fmt.printf("gamepad %v right stick delta: %v\n", gamepad_index, gamepad_right_stick_delta(gamepad_index))
        }
    }
}