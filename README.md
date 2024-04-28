# jo:app

A stupidly easy to use alternative to SDL, GLFW, Raylib, and others.

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

## Why another library?

Libraries like SDL, GLFW, Raylib, Sokol, and others aren't good enough for me. 

So far, these are the principles I've been running with when developing jo:app:

1. Flexibility isn't always good. Most programs don't need multiple windows, for example. Strategic *inflexibility* can make a library much nicer to use in 99% of cases.
2. Reduce the number of *necessary* API calls as much as possible.
3. Avoid returning results. Most errors in platform specific code are just that: *errors*. If they happen, it means there's something wrong with the *library*. Where this isn't the case, such as with `app.gl_init`, a boolean result is acceptable. If it fails, it simply means that version of OpenGL isn't present on the user's machine.
4. NEVER EVER make a procedure like `app.get_last_error`. If the library is being used in a blatantly incorrect way, it should panic with a useful error message. Forcing the user to get an error and print it out themsevles is completely pointless.

# IMPORTANT:

jo is still early in development. For now, it is Windows only.