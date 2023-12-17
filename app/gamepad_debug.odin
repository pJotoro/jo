package app

import "core:runtime"
import "core:fmt"

gamepad_debug_enable :: proc "contextless" () {
    ctx.gamepad_debug = true
}

gamepad_debug_disable :: proc "contextless" () {
    ctx.gamepad_debug = false
}

gamepad_debug :: proc(gamepad_index: int, loc := #caller_location) {
    runtime.bounds_check_error_loc(loc, gamepad_index, len(ctx.gamepads))

    fmt.printf("gamepad %v dpad up: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Up))
    fmt.printf("gamepad %v dpad down: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Down))
    fmt.printf("gamepad %v dpad left: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Left))
    fmt.printf("gamepad %v dpad right: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Dpad_Right))
    fmt.printf("gamepad %v start: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Start))
    fmt.printf("gamepad %v back: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Back))
    fmt.printf("gamepad %v left thumb: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Left_Thumb))
    fmt.printf("gamepad %v right thumb: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Right_Thumb))
    fmt.printf("gamepad %v left shoulder: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Left_Shoulder))
    fmt.printf("gamepad %v right shoulder: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Right_Shoulder))
    fmt.printf("gamepad %v A: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .A))
    fmt.printf("gamepad %v B: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .B))
    fmt.printf("gamepad %v X: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .X))
    fmt.printf("gamepad %v Y: %v\n", gamepad_index, gamepad_button_down(gamepad_index, .Y))

    fmt.printf("gamepad %v dpad up pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Up))
    fmt.printf("gamepad %v dpad down pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Down))
    fmt.printf("gamepad %v dpad left pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Left))
    fmt.printf("gamepad %v dpad right pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Dpad_Right))
    fmt.printf("gamepad %v start pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Start))
    fmt.printf("gamepad %v back pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Back))
    fmt.printf("gamepad %v left thumb pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Left_Thumb))
    fmt.printf("gamepad %v right thumb pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Right_Thumb))
    fmt.printf("gamepad %v left shoulder pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Left_Shoulder))
    fmt.printf("gamepad %v right shoulder pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Right_Shoulder))
    fmt.printf("gamepad %v A pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .A))
    fmt.printf("gamepad %v B pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .B))
    fmt.printf("gamepad %v X pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .X))
    fmt.printf("gamepad %v Y pressed: %v\n", gamepad_index, gamepad_button_pressed(gamepad_index, .Y))

    fmt.printf("gamepad %v dpad up released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Up))
    fmt.printf("gamepad %v dpad down released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Down))
    fmt.printf("gamepad %v dpad left released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Left))
    fmt.printf("gamepad %v dpad right released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Dpad_Right))
    fmt.printf("gamepad %v start released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Start))
    fmt.printf("gamepad %v back released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Back))
    fmt.printf("gamepad %v left thumb released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Left_Thumb))
    fmt.printf("gamepad %v right thumb released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Right_Thumb))
    fmt.printf("gamepad %v left shoulder released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Left_Shoulder))
    fmt.printf("gamepad %v right shoulder released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Right_Shoulder))
    fmt.printf("gamepad %v A released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .A))
    fmt.printf("gamepad %v B released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .B))
    fmt.printf("gamepad %v X released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .X))
    fmt.printf("gamepad %v Y released: %v\n", gamepad_index, gamepad_button_released(gamepad_index, .Y))

    fmt.printf("gamepad %v left trigger: %v\n", gamepad_index, gamepad_left_trigger(gamepad_index))
    fmt.printf("gamepad %v right trigger: %v\n", gamepad_index, gamepad_right_trigger(gamepad_index))
    fmt.printf("gamepad %v left stick: %v\n", gamepad_index, gamepad_left_stick(gamepad_index))
    fmt.printf("gamepad %v right stick: %v\n", gamepad_index, gamepad_right_stick(gamepad_index))
}