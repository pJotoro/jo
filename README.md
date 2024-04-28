# jo:app

A stupidly easy to use platform layer.

You can move a window around with the arrow keys:

```odin
package app_example

import "jo:app"

main :: proc() {
	app.init(fullscreen = .Off)

	x, y: int

	for app.running() {
		if app.key_down(.Left) do x -= 1
		if app.key_down(.Right) do x += 1
		if app.key_down(.Up) do y -= 1
		if app.key_down(.Down) do y += 1

		app.set_position(x, y)
	}
}
```

You can also create an OpenGL context with just one procedure call:

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