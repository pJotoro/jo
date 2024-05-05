# jo:app

A stupidly easy to use platform layer.

This is how easy it is to get a window open:

```odin
package main

import "jo:app"

main :: proc() {
	app.init()
	for app.running() {
		if app.key_pressed(.Escape) do return
	}
}
```

In debug mode, the window is automatically centered and is 1/4 the size of the monitor. In release mode, it is automatically set to fullscreen. Of course, this is only the default behavior, and can be changed with parameters:

```odin
package app_example

import "jo:app"

main :: proc() {
	app.init(fullscreen = .Off) // can also be set to .On, or the default, .Auto
	for app.running() {
		if app.key_pressed(.Escape) do return
	}
}
```

Create your own backbuffer which you can render to on the CPU:

```odin
package main

import "jo:app"

main :: proc() {
	app.init()
	backbuffer := make([]u32, app.width() * app.height())
	for app.running() {
		if app.key_pressed(.Escape) do return
		// code to fill the backbuffer with pixels...
		app.swap_buffers(backbuffer)
	}
}
```

Easily make it resizable:

```odin
package main

import "jo:app"

main :: proc() {
	app.init(resizable = true)
	backbuffer := make([dynamic]u32, app.width() * app.height())
	for app.running() {
		if app.key_pressed(.Escape) do return
		resize(&backbuffer, app.width() * app.height())
		// code to fill the backbuffer with pixels...
		app.swap_buffers(backbuffer[:])
	}
}
```

It is highly recommend to enable logging when using jo:app. To enable it, set the context.logger:

```odin
package main

import "jo:app"
import "core:log"

main :: proc() {
	context.logger = log.create_console_logger(.Debug, {.Terminal_Color, .Level})
	app.init()
	for app.running() {
		if app.key_pressed(.Escape) do return
	}
}
```

Don't want to render on the CPU? You can also create an OpenGL context with just one procedure call:

```odin
package app_gl_example

import "jo:app"
import gl "vendor:OpenGL"

main :: proc() {
	app.init()
	app.gl_init(4, 6)

	for app.running() {
		if app.key_pressed(.Escape) do return

		gl.ClearColor(0.123, 0.456, 0.789, 1)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		app.gl_swap_buffers()
	}
}
```

## Why another platform layer?

SDL is too low level. Raylib is too high level.

Currently, these are the principles I am developing jo:app with:

1. Prioritize game development.
2. There should be good defaults.
3. Don't be too flexible or general purpose.
4. Don't return errors. Log them.

This library isn't for everyone. For example, you can't create multiple windows.

# IMPORTANT:

jo is still early in development. For now, it is Windows only.