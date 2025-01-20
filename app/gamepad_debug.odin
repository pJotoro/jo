package app

import "core:fmt"

Gamepad_Debug_Flag :: enum u32 {
    Navigation,
    Bumper,
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

// @(private)
// gamepad_debug :: proc(ctx: ^Context, gamepad_index: int) {
//     if .Navigation in ctx.gamepad_debug_flags {
//         if .Down in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v dpad up: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Up))
//             fmt.printf("gamepad %v dpad down: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Down))
//             fmt.printf("gamepad %v dpad left: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Left))
//             fmt.printf("gamepad %v dpad right: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Right))
//             fmt.printf("gamepad %v menu right: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Menu_Right))
//             fmt.printf("gamepad %v menu left: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Menu_Left))
//         }
//         if .Pressed in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v dpad up pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Up))
//             fmt.printf("gamepad %v dpad down pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Down))
//             fmt.printf("gamepad %v dpad left pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Left))
//             fmt.printf("gamepad %v dpad right pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Right))
//             fmt.printf("gamepad %v menu right pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Menu_Right))
//             fmt.printf("gamepad %v menu left pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Menu_Left))
//         }
//         if .Released in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v dpad up released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Up))
//             fmt.printf("gamepad %v dpad down released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Down))
//             fmt.printf("gamepad %v dpad left released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Left))
//             fmt.printf("gamepad %v dpad right released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Right))
//             fmt.printf("gamepad %v menu right released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Menu_Right))
//             fmt.printf("gamepad %v menu left released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Menu_Left))
//         }
//     }

//     if .Bumper in ctx.gamepad_debug_flags {
//         if .Down in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left bumper: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Left_Bumper))
//             fmt.printf("gamepad %v right bumper: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Right_Bumper))
//         }
//         if .Pressed in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left bumper pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Left_Bumper))
//             fmt.printf("gamepad %v right bumper pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Right_Bumper))
//         }
//         if .Released in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left bumper released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Left_Bumper))
//             fmt.printf("gamepad %v right bumper released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Right_Bumper))
//         }
//     }
    
//     if .Bumper in ctx.gamepad_debug_flags {
//         if .Down in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left bumper: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Left_Bumper))
//             fmt.printf("gamepad %v right bumper: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Right_Bumper))
//         }
//         if .Pressed in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left bumper pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Left_Bumper))
//             fmt.printf("gamepad %v right bumper pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Right_Bumper))
//         }
//         if .Released in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left bumper released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Left_Bumper))
//             fmt.printf("gamepad %v right bumper released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Right_Bumper))
//         }
//     }
    
//     if .Face in ctx.gamepad_debug_flags {
//         if .Down in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v A: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .A))
//             fmt.printf("gamepad %v B: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .B))
//             fmt.printf("gamepad %v X: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .X))
//             fmt.printf("gamepad %v Y: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Y))
//         }
//         if .Pressed in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v A pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .A))
//             fmt.printf("gamepad %v B pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .B))
//             fmt.printf("gamepad %v X pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .X))
//             fmt.printf("gamepad %v Y pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Y))
//         }
//         if .Released in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v A released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .A))
//             fmt.printf("gamepad %v B released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .B))
//             fmt.printf("gamepad %v X released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .X))
//             fmt.printf("gamepad %v Y released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Y))
//         }
//     }
    
//     if .Trigger in ctx.gamepad_debug_flags {
//         fmt.printf("gamepad %v left trigger: %v\n", gamepad_index, gamepad_left_trigger(gamepad_index))
//         fmt.printf("gamepad %v right trigger: %v\n", gamepad_index, gamepad_right_trigger(gamepad_index))
//         if .Delta in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left trigger delta: %v\n", gamepad_index, gamepad_left_trigger_delta(gamepad_index))
//             fmt.printf("gamepad %v right trigger delta: %v\n", gamepad_index, gamepad_right_trigger_delta(gamepad_index))
//         }
//     }

//     if .Stick in ctx.gamepad_debug_flags {
//         fmt.printf("gamepad %v left stick: %v\n", gamepad_index, gamepad_left_stick(gamepad_index))
//         fmt.printf("gamepad %v right stick: %v\n", gamepad_index, gamepad_right_stick(gamepad_index))
//         if .Delta in ctx.gamepad_debug_flags {
//             fmt.printf("gamepad %v left stick delta: %v\n", gamepad_index, gamepad_left_stick_delta(gamepad_index))
//             fmt.printf("gamepad %v right stick delta: %v\n", gamepad_index, gamepad_right_stick_delta(gamepad_index))
//         }
//     }
// }