package ngl

import gl "vendor:OpenGL"

draw_arrays :: proc "contextless" (mode: Draw_Mode, first, count: i32) {
	gl.DrawArrays(u32(mode), first, count)
}

draw_elements_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices))
}

draw_elements_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices))
}

draw_elements_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices))
}

draw_elements :: proc{
	draw_elements_byte, 
	draw_elements_u16, 
	draw_elements_u32,
}

multi_draw_arrays :: proc "contextless" (mode: Draw_Mode, first, count: []i32) {
	gl.MultiDrawArrays(u32(mode), raw_data(first), raw_data(count), i32(min(len(first), len(count))))
}

multi_draw_elements_byte :: proc "contextless" (mode: Draw_Mode, count: []i32, indices: []byte) {
	gl.MultiDrawElements(u32(mode), raw_data(count), gl.UNSIGNED_BYTE, (^rawptr)(raw_data(indices)), i32(min(len(count), len(indices))))
}

multi_draw_elements_u16 :: proc "contextless" (mode: Draw_Mode, count: []i32, indices: []u16) {
	gl.MultiDrawElements(u32(mode), raw_data(count), gl.UNSIGNED_SHORT, (^rawptr)(raw_data(indices)), i32(min(len(count), len(indices))))
}

multi_draw_elements_u32 :: proc "contextless" (mode: Draw_Mode, count: []i32, indices: []u32) {
	gl.MultiDrawElements(u32(mode), raw_data(count), gl.UNSIGNED_INT, (^rawptr)(raw_data(indices)), i32(min(len(count), len(indices))))
}

multi_draw_elements :: proc {
	multi_draw_elements_byte,
	multi_draw_elements_u16,
	multi_draw_elements_u32,
}

draw_arrays_instanced :: proc "contextless" (mode: Draw_Mode, first: i32, count: i32, instance_count: i32) {
	gl.DrawArraysInstanced(u32(mode), first, count, instance_count)
}

draw_elements_instanced_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte, instance_count: i32) {
	gl.DrawElementsInstanced(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), instance_count)
}

draw_elements_instanced_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16, instance_count: i32) {
	gl.DrawElementsInstanced(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), instance_count)
}

draw_elements_instanced_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32, instance_count: i32) {
	gl.DrawElementsInstanced(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), instance_count)
}

draw_elements_instanced :: proc {
	draw_elements_instanced_byte, 
	draw_elements_instanced_u16, 
	draw_elements_instanced_u32,
}

draw_elements_base_vertex_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte, base_vertex: i32) {
	gl.DrawElementsBaseVertex(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), base_vertex)
}

draw_elements_base_vertex_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16, base_vertex: i32) {
	gl.DrawElementsBaseVertex(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), base_vertex)
}

draw_elements_base_vertex_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32, base_vertex: i32) {
	gl.DrawElementsBaseVertex(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), base_vertex)
}

draw_elements_base_vertex :: proc {
	draw_elements_base_vertex_byte, 
	draw_elements_base_vertex_u16, 
	draw_elements_base_vertex_u32,
}

draw_range_elements_base_vertex_byte :: proc "contextless" (mode: Draw_Mode, start, end: u32, indices: []byte, base_vertex: i32) {
	gl.DrawRangeElementsBaseVertex(u32(mode), start, end, i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), base_vertex)
}

draw_range_elements_base_vertex_u16 :: proc "contextless" (mode: Draw_Mode, start, end: u32, indices: []u16, base_vertex: i32) {
	gl.DrawRangeElementsBaseVertex(u32(mode), start, end, i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), base_vertex)
}

draw_range_elements_base_vertex_u32 :: proc "contextless" (mode: Draw_Mode, start, end: u32, indices: []u32, base_vertex: i32) {
	gl.DrawRangeElementsBaseVertex(u32(mode), start, end, i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), base_vertex)
}

draw_range_elements_base_vertex :: proc {
	draw_range_elements_base_vertex_byte, 
	draw_range_elements_base_vertex_u16, 
	draw_range_elements_base_vertex_u32,
}

draw_elements_instanced_base_vertex_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte, instance_count, base_vertex: i32) {
	gl.DrawElementsInstancedBaseVertex(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), instance_count, base_vertex)
}

draw_elements_instanced_base_vertex_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16, instance_count, base_vertex: i32) {
	gl.DrawElementsInstancedBaseVertex(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), instance_count, base_vertex)
}

draw_elements_instanced_base_vertex_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32, instance_count, base_vertex: i32) {
	gl.DrawElementsInstancedBaseVertex(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), instance_count, base_vertex)
}

draw_elements_instanced_base_vertex :: proc {
	draw_elements_instanced_base_vertex_byte, 
	draw_elements_instanced_base_vertex_u16, 
	draw_elements_instanced_base_vertex_u32,
}

multi_draw_elements_base_vertex_byte :: proc "contextless" (mode: Draw_Mode, count: []i32, indices: [][^]byte, base_vertex: []i32) {
	gl.MultiDrawElementsBaseVertex(u32(mode), raw_data(count), gl.UNSIGNED_BYTE, ([^]rawptr)(raw_data(indices)), i32(min(len(count), len(indices), len(base_vertex))), raw_data(base_vertex))
}

multi_draw_elements_base_vertex_u16 :: proc "contextless" (mode: Draw_Mode, count: []i32, indices: [][^]u16, base_vertex: []i32) {
	gl.MultiDrawElementsBaseVertex(u32(mode), raw_data(count), gl.UNSIGNED_SHORT, ([^]rawptr)(raw_data(indices)), i32(min(len(count), len(indices), len(base_vertex))), raw_data(base_vertex))
}

multi_draw_elements_base_vertex_u32 :: proc "contextless" (mode: Draw_Mode, count: []i32, indices: [][^]u32, base_vertex: []i32) {
	gl.MultiDrawElementsBaseVertex(u32(mode), raw_data(count), gl.UNSIGNED_INT, ([^]rawptr)(raw_data(indices)), i32(min(len(count), len(indices), len(base_vertex))), raw_data(base_vertex))
}

multi_draw_elements_base_vertex :: proc {
	multi_draw_elements_base_vertex_byte,
	multi_draw_elements_base_vertex_u16,
	multi_draw_elements_base_vertex_u32,
}

Draw_Arrays_Indirect_Command :: struct {
	count:          u32,
	instance_count: u32,
	first:          u32,
	base_instance:  u32,
}

draw_arrays_indirect :: proc "contextless" (mode: Draw_Mode, indirect: ^Draw_Arrays_Indirect_Command) {
	gl.DrawArraysIndirect(u32(mode), auto_cast indirect)
}

Draw_Elements_Indirect_Command :: struct {
	count:          u32,
	instance_count: u32,
	first_index:    u32,
	base_vertex:    u32,
	base_instance:  u32,
}

draw_elements_indirect :: proc "contextless" (mode: Draw_Mode, type: Draw_Type, indirect: ^Draw_Elements_Indirect_Command) {
	gl.DrawElementsIndirect(u32(mode), u32(type), auto_cast indirect)
}

draw_arrays_instanced_base_instance :: proc "contextless" (mode: Draw_Mode, first, count, instance_count: i32, base_instance: u32) {
	gl.DrawArraysInstancedBaseInstance(u32(mode), first, count, instance_count, base_instance)
}

draw_elements_instanced_base_instance_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte, instance_count: i32, base_instance: u32) {
	gl.DrawElementsInstancedBaseInstance(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), instance_count, base_instance)
}

draw_elements_instanced_base_instance_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16, instance_count: i32, base_instance: u32) {
	gl.DrawElementsInstancedBaseInstance(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), instance_count, base_instance)
}

draw_elements_instanced_base_instance_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32, instance_count: i32, base_instance: u32) {
	gl.DrawElementsInstancedBaseInstance(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), instance_count, base_instance)
}

draw_elements_instanced_base_instance :: proc {
	draw_elements_instanced_base_instance_byte,
	draw_elements_instanced_base_instance_u16,
	draw_elements_instanced_base_instance_u32,
}

draw_elements_instanced_base_vertex_base_instance_byte :: proc "contextless" (mode: Draw_Mode, indices: []byte, instance_count, base_vertex: i32, base_instance: u32) {
	gl.DrawElementsInstancedBaseVertexBaseInstance(u32(mode), i32(len(indices)), gl.UNSIGNED_BYTE, raw_data(indices), instance_count, base_vertex, base_instance)
}

draw_elements_instanced_base_vertex_base_instance_u16 :: proc "contextless" (mode: Draw_Mode, indices: []u16, instance_count, base_vertex: i32, base_instance: u32) {
	gl.DrawElementsInstancedBaseVertexBaseInstance(u32(mode), i32(len(indices)), gl.UNSIGNED_SHORT, raw_data(indices), instance_count, base_vertex, base_instance)
}

draw_elements_instanced_base_vertex_base_instance_u32 :: proc "contextless" (mode: Draw_Mode, indices: []u32, instance_count, base_vertex: i32, base_instance: u32) {
	gl.DrawElementsInstancedBaseVertexBaseInstance(u32(mode), i32(len(indices)), gl.UNSIGNED_INT, raw_data(indices), instance_count, base_vertex, base_instance)
}

draw_elements_instanced_base_vertex_base_instance :: proc {
	draw_elements_instanced_base_vertex_base_instance_byte,
	draw_elements_instanced_base_vertex_base_instance_u16,
	draw_elements_instanced_base_vertex_base_instance_u32,
}