package example

import "app"
import "core:image/png"
import "core:slice"
import "core:mem"

main :: proc() {
	app.init()
	
	bitmap := make([]u32, app.width() * app.height())
	awesomeface, _ := png.load("awesomeface.png")

	x := (app.width() - awesomeface.width) / 2
	y := (app.height() - awesomeface.height) / 2
	
	for !app.should_close() {
		slice.fill(bitmap, 0)

		if app.key_down(.Left) do x -= 1
		if app.key_down(.Right) do x += 1
		x = clamp(x, 0, app.width()-1-awesomeface.width)

		if app.key_down(.Down) do y -= 1
		if app.key_down(.Up) do y += 1
		y = clamp(y, 0, app.height()-1-awesomeface.height)

		draw_image(bitmap, awesomeface, x, y)

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

draw_image :: proc(bitmap: []u32, img: ^png.Image, x, y: int) {
	for image_x := 0; image_x < img.width && image_x < app.width(); image_x += 1 {
		for image_y := 0; image_y < img.height && image_y < app.height(); image_y += 1 {
			pixel := image_pixel(img, image_x, image_y)
			draw_pixel(bitmap, x + image_x, y + image_y, pixel)
		}
	}
}