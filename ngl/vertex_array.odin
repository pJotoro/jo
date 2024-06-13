package ngl

import gl "vendor:OpenGL"

disable_vertex_attrib_array :: proc "contextless" (vertex_array: Vertex_Array, index: u32) {
	gl.impl_DisableVertexArrayAttrib(u32(vertex_array), index)
}

enable_vertex_attrib_array :: proc "contextless" (vertex_array: Vertex_Array, index: u32) {
	gl.impl_EnableVertexArrayAttrib(u32(vertex_array), index)
}

vertex_attrib_binding :: proc "contextless" (vertex_array: Vertex_Array, attrib_index, binding_index: u32) {
	gl.impl_VertexArrayAttribBinding(u32(vertex_array), attrib_index, binding_index)
}

vertex_attrib_format :: proc "contextless" (vertex_array: Vertex_Array, attrib_index: u32, size: i32, type: Attribute_Type, normalized: bool, relative_offset: u32) {
	gl.impl_VertexArrayAttribFormat(u32(vertex_array), attrib_index, size, u32(type), normalized, relative_offset)
}

bind_vertex_array :: proc "contextless" (vertex_array: Vertex_Array) {
	gl.impl_BindVertexArray(u32(vertex_array))
}

delete_vertex_arrays :: proc "contextless" (vertex_arrays: []Vertex_Array) {
	gl.impl_DeleteVertexArrays(i32(len(vertex_arrays)), ([^]u32)(raw_data(vertex_arrays)))
}

gen_vertex_arrays :: proc "contextless" (vertex_arrays: []Vertex_Array) {
	gl.impl_CreateVertexArrays(i32(len(vertex_arrays)), ([^]u32)(raw_data(vertex_arrays)))
}

is_vertex_array :: proc "contextless" (vertex_array: u32) -> bool {
	return gl.impl_IsVertexArray(u32(vertex_array))
}

bind_vertex_buffer :: proc "contextless" (vertex_array: Vertex_Array, binding_index: u32, buffer: Buffer, offset: int, stride: i32) {
	gl.VertexArrayVertexBuffer(u32(vertex_array), binding_index, u32(buffer), offset, stride)
}