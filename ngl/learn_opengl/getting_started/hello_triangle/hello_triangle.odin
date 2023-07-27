package hello_triangle

import "jo/app"
import gl "jo/ngl"
import "core:slice"

main :: proc() {
	app.init(width = 800, height = 600)
	assert(app.gl_init(4, 6))

	vertex_shader := gl.create_shader("vert.spv", .Vertex)
	fragment_shader := gl.create_shader("frag.spv", .Fragment)
	program := gl.create_program(vertex_shader, fragment_shader)

	vertices := [?]f32{
		-0.5, -0.5, 0.0, // left  
		0.5, -0.5, 0.0, // right 
		0.0,  0.5, 0.0, // top   
	}

	vertex_buffer := gl.create_buffer()
	gl.buffer_data(vertex_buffer, slice.to_bytes(vertices[:]), .Static_Draw)

	vertex_array := gl.create_vertex_array()
	gl.bind_vertex_buffer_to_vertex_array(vertex_array, 0, vertex_buffer, 0, size_of(f32) * 3)
	gl.enable_vertex_array_attrib(vertex_array, 0)
	gl.vertex_array_attrib_format(vertex_array, 0, 3, f32, false, 0)
	gl.vertex_array_attrib_binding(vertex_array, 0, 0)
	
	for !app.should_close() {
		gl.clear_color(0.2, 0.3, 0.3, 1.0)
		gl.clear({.Color})

		gl.use_program(program)
		gl.bind_vertex_array(vertex_array)
		gl.draw_arrays(.Triangles, 0, 3)

		app.gl_swap_buffers()

		free_all(context.temp_allocator)
	}
}
