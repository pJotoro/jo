package tests

import "core:testing"
import "../app"


@(test)
app_basic :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(fullscreen = .Off, title = "basic")
    for app.running() {

    }
}

@(test)
app_explicit_size :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(fullscreen = .Off, title = "explicit size", width = 600, height = 400)
    for app.running() {

    }
}

@(test)
app_explicit_size_warning_width :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(fullscreen = .Off, title = "explicit size warning width", width = 600)
    for app.running() {

    }
}

@(test)
app_explicit_size_warning_height :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(fullscreen = .Off, title = "explicit size warning height", height = 600)
    for app.running() {
        
    }
}

@(test)
app_resizable :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(title = "resizable", resizable = true)
    for app.running() {

    }
}

@(test)
app_minimize_box :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(title = "minimize box", minimize_box = true)
    for app.running() {

    }
}

@(test)
app_maximize_box :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    app.init(title = "maximize box", maximize_box = true)
    for app.running() {

    }
}

@(test)
app_all_boxes :: proc(t: ^testing.T) {
    context.logger = create_logger(t)
    
    app.init(title = "all boxes", resizable = true, minimize_box = true, maximize_box = true)
    for app.running() {

    }
}

@(test)
forgot_to_init :: proc(t: ^testing.T) {
    context.logger = create_logger(t)

    for app.running() {
        
    }
}