# jo

A stupidly easy to use library for the Odin programming language.

```odin
package example

import "jo/app"
import "core:image/png"
import "core:slice"
import "core:mem"

main :: proc() {
	app.init()

	gamepad := app.gamepad(0)
	
	bitmap := make([]u32, app.width() * app.height())
	awesomeface, _ := png.load("awesomeface.png")

	pos: [2]f32 = ---
	pos.x = f32((app.width() - awesomeface.width) / 2)
	pos.y = f32((app.height() - awesomeface.height) / 2)
	
	for !app.should_close() {
		slice.fill(bitmap, 0)

		if gamepad != app.INVALID_GAMEPAD {
			pos += app.gamepad_left_stick(gamepad)
		} else {
			if app.key_down(.Left)  do pos.x -= 1
			if app.key_down(.Right) do pos.x += 1
			if app.key_down(.Down)  do pos.y -= 1
			if app.key_down(.Up)    do pos.y += 1
		}
		pos.x = clamp(pos.x, 0, f32(app.width()-1-awesomeface.width))
		pos.y = clamp(pos.y, 0, f32(app.height()-1-awesomeface.height))

		draw_image(bitmap, awesomeface, pos)

		app.render(bitmap)
		mem.free_all(context.temp_allocator)
	}
}

image_pixel :: proc(img: ^png.Image, x, y: int) -> u32 {
	reversed_y := img.height - y - 1
	i := (x+reversed_y*img.width) * 4
	pixel: [4]byte = ---
	copy(pixel[:], img.pixels.buf[i:i+4])
	pixel[0], pixel[2] = pixel[2], pixel[0]
	return transmute(u32)pixel
}

draw_pixel :: proc(bitmap: []u32, x, y: int, pixel: u32) {
	bitmap[x+y*app.width()] = pixel
}

draw_image :: proc(bitmap: []u32, img: ^png.Image, pos: [2]f32) {
	x := int(pos.x)
	y := int(pos.y)
	for image_x := 0; image_x < img.width && image_x < app.width(); image_x += 1 {
		for image_y := 0; image_y < img.height && image_y < app.height(); image_y += 1 {
			pixel := image_pixel(img, image_x, image_y)
			draw_pixel(bitmap, x + image_x, y + image_y, pixel)
		}
	}
}
```

You can also create an OpenGL context with just one procedure call:

```odin
package gl_example

import "jo/app"
import gl "vendor:OpenGL"

main :: proc() {
	app.init()
	app.gl_init(4, 6)

	for !app.should_close() {
		gl.ClearColor(0.123, 0.456, 0.789, 1)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		app.gl_swap_buffers()
	}
}
```