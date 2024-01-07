// +private
package app

import "vendor:x11/xlib"
import "core:log"

OS_Specific :: struct {
    display: ^xlib.Display,
    screen: i32,
    root: xlib.Window,
    window_attributes: xlib.XSetWindowAttributes,
}

_init :: proc() {
    unimplemented()
    /*
    ctx.display = xlib.XOpenDisplay(nil)
    ctx.screen = xlib.XDefaultScreen(ctx.display)
    ctx.root = xlib.XRootWindow(ctx.display, ctx.screen)
    ctx.window_attributes.background_pixel = xlib.XWhitePixel(ctx.display, ctx.screen)
    ctx.window_attributes.border_pixel = xlib.XBlackPixel(ctx.display, ctx.screen)
    ctx.window_attributes.event_mask = {.ButtonPress}
    ctx.window = transmute(rawptr)xlib.XCreateWindow(
        ctx.display, 
        ctx.root, 
        500, 
        500, 
        500, 
        500, 
        15, 
        xlib.XDefaultDepth(ctx.display), 
        .CopyFromParent, 
        xlib.XDefaultVisual(ctx.display, ctx.screen), 
        {.CWBackPixel, .CWBorderPixel, .CWEventMask},
        &ctx.window_attributes)
    xlib.XMapWindow(ctx.display, transmute(xlib.Window)ctx.window)*/
}

import "core:fmt"

_running :: proc() -> bool {
    unimplemented()
    /*
    e: xlib.XEvent
    xlib.XNextEvent(ctx.display, &e)
    switch e.type {
        case .KeyPress:
            event := e.xkey
            fmt.println(event)
        case .KeyRelease:
            event := e.xkey
            fmt.println(event)
        case .ButtonPress:
            event := e.xbutton
            fmt.println(event)
        case .ButtonRelease:
            event := e.xbutton
            fmt.println(event)
        case .MotionNotify:
            event := e.xmotion
            fmt.println(event)
        case .EnterNotify:
            event := e.xcrossing
            fmt.println(event)
        case .LeaveNotify:
            event := e.xcrossing
            fmt.println(event)
        case .FocusIn:
            event := e.xfocus
            fmt.println(event)
        case .FocusOut:
            event := e.xfocus
            fmt.println(event)
        case .KeymapNotify:
            event := e.xkeymap
            fmt.println(event)
        case .Expose:
            event := e.xexpose
            fmt.println(event)
        case .GraphicsExpose:
            event := e.xgraphicsexpose
            fmt.println(event)
        case .NoExpose:
            event := e.xnoexpose
            fmt.println(event)
        case .VisibilityNotify:
            event := e.xvisibility
            fmt.println(event)
        case .CreateNotify:
            event := e.xcreatewindow
            fmt.println(event)
        case .DestroyNotify:
            event := e.xdestroywindow
            fmt.println(event)
            unimplemented()
        case .UnmapNotify:
            event := e.xunmap
            fmt.println(event)
        case .MapNotify:
            event := e.xmap
            fmt.println(event)
        case .MapRequest:
            event := e.xmaprequest
            fmt.println(event)
        case .ReparentNotify:
            event := e.xreparent
            fmt.println(event)
        case .ConfigureNotify:
            event := e.xconfigure
            fmt.println(event)
        case .ConfigureRequest:
            event := e.xconfigurerequest
            fmt.println(event)
        case .GravityNotify:
            event := e.xgravity
            fmt.println(event)
        case .ResizeRequest:
            event := e.xresizerequest
            fmt.println(event)
        case .CirculateNotify:
            event := e.xcirculate
            fmt.println(event)
        case .CirculateRequest:
            event := e.xcirculaterequest
            fmt.println(event)
        case .PropertyNotify:
            event := e.xproperty
            fmt.println(event)
        case .SelectionClear:
            event := e.xselectionclear
            fmt.println(event)
        case .SelectionRequest:
            event := e.xselectionrequest
            fmt.println(event)
        case .SelectionNotify:
            event := e.xselection
            fmt.println(event)
        case .ColormapNotify:
            event := e.xcolormap
            fmt.println(event)
        case .ClientMessage:
            event := e.xclient
            fmt.println(event)
        case .MappingNotify:
            event := e.xmapping
            fmt.println(event)
        case .GenericEvent:
            event := e.xgeneric
            fmt.println(event)
    }

    return true
    */
}

_swap_buffers :: proc(buffer: []u32) {
    unimplemented()
}

_set_title :: proc(title: string) {
    unimplemented()
}

_set_position :: proc(x, y: int) -> bool {
    unimplemented()
}

_set_windowed :: proc() -> bool {
    unimplemented()
}

_set_fullscreen :: proc() -> bool {
    unimplemented()
}

_hide :: proc() -> bool {
    unimplemented()
}

_show :: proc() -> bool {
    unimplemented()
}

_minimize :: proc() -> bool {
    unimplemented()
}

_maximize :: proc() -> bool {
    unimplemented()
}

_cursor_position :: proc() -> (x, y: int) {
    unimplemented()
}

_cursor_visible :: proc() -> bool {
    unimplemented()
}

_show_cursor :: proc() -> bool {
    unimplemented()
}

_hide_cursor :: proc() -> bool {
    unimplemented()
}