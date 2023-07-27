package ngl

import gl "vendor:OpenGL"
import "core:strings"

viewport :: gl.Viewport
clear_color :: gl.ClearColor

Clear_Flag :: enum u32 {
	Depth = 8,
	Stencil = 10, 
	Color = 14, 
}

Clear_Flags :: distinct bit_set[Clear_Flag; u32]

clear :: proc "contextless" (flags: Clear_Flags) {
	gl.Clear(transmute(u32)flags)
}

Buffer :: distinct u32

create_buffer :: proc "contextless" () -> Buffer {
	buf: u32 = ---
	gl.CreateBuffers(1, &buf)
	return Buffer(buf)
}

create_buffers :: proc(n: i32, allocator := context.allocator, loc := #caller_location) -> []Buffer {
	bufs := make([]u32, n, allocator, loc = loc)
	gl.CreateBuffers(n, raw_data(bufs))
	return transmute([]Buffer)bufs
}

Buffer_Usage :: enum u32 {
	Stream_Draw = 0x88E0,
	Stream_Read = 0x88E1,
	Stream_Copy = 0x88E2,
	Static_Draw = 0x88E4,
	Static_Read = 0x88E5,
	Static_Copy = 0x88E6,
	Dynamic_Draw = 0x88E8,
	Dynamic_Read = 0x88E9,
	Dynamic_Copy = 0x88EA,
}

buffer_data :: proc "contextless" (buffer: Buffer, data: []byte, usage: Buffer_Usage) {
	gl.NamedBufferData(u32(buffer), len(data), raw_data(data), u32(usage))
}

Shader :: distinct u32

Shader_Type :: enum u32 {
	Fragment = 0x8B30, 
	Vertex = 0x8B31,
	Geometry = 0x8DD9,
	Tess_Evaluation = 0x8E87,
	Tess_Control = 0x8E88,
	Compute = 0x91B9,
}

create_shader_from_binary :: proc(binary: []byte, type: Shader_Type, entry := "main", loc := #caller_location) -> (Shader, bool) #optional_ok {
	assert(condition = align_of(raw_data(binary)) >= align_of(u32), loc = loc)
	cstring_entry := strings.clone_to_cstring(entry, context.temp_allocator, loc)
	shader := gl.CreateShader(u32(type))
	gl.ShaderBinary(1, &shader, gl.SHADER_BINARY_FORMAT_SPIR_V, raw_data(binary), i32(len(binary)))
	gl.SpecializeShader(shader, cstring_entry, 0, nil, nil)
	success: i32 = ---
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
	when !ODIN_DISABLE_ASSERT {
		if success == 0 {
			info_log: [512]byte = ---
			gl.GetShaderInfoLog(shader, 512, nil, raw_data(info_log[:]))
			panic(string(cstring(raw_data(info_log[:]))), loc)
		}
	}
	return Shader(shader), bool(success)
}

create_shader_from_file :: proc(filename: string, type: Shader_Type, entry := "main", loc := #caller_location) -> (Shader, bool) #optional_ok {
	binary, ok := read_entire_file_aligned(filename, align_of(u32))
	assert(condition = ok, loc = loc)
	return create_shader_from_binary(binary, type, entry, loc)
}

create_shader :: proc{create_shader_from_binary, create_shader_from_file}

Program :: distinct u32

create_program :: proc(shaders: ..Shader, loc := #caller_location) -> (Program, bool) #optional_ok {
	program := gl.CreateProgram()
	for shader in shaders {
		gl.AttachShader(program, u32(shader))
	}
	gl.LinkProgram(program)
	success: i32 = ---
	gl.GetProgramiv(program, gl.LINK_STATUS, &success)
	when !ODIN_DISABLE_ASSERT {
		if success == 0 {
			info_log: [512]byte = ---
			gl.GetShaderInfoLog(program, 512, nil, raw_data(info_log[:]))
			panic(string(cstring(raw_data(info_log[:]))), loc)
		}
	}
	return Program(program), bool(success)
}

use_program :: proc "contextless" (program: Program) {
	gl.UseProgram(u32(program))
}

Vertex_Array :: distinct u32

create_vertex_array :: proc "contextless" () -> Vertex_Array {
	vertex_array: u32 = ---
	gl.CreateVertexArrays(1, &vertex_array)
	return Vertex_Array(vertex_array)
}

create_vertex_arrays :: proc(n: i32) -> []Vertex_Array {
	vertex_arrays := make([]u32, n)
	gl.CreateVertexArrays(n, raw_data(vertex_arrays))
	return transmute([]Vertex_Array)vertex_arrays
}

bind_vertex_buffer_to_vertex_array :: proc "contextless" (vertex_array: Vertex_Array, binding_index: u32, vertex_buffer: Buffer, offset: int, stride: i32) {
	gl.VertexArrayVertexBuffer(u32(vertex_array), binding_index, u32(vertex_buffer), offset, stride)
}

bind_element_buffer_to_vertex_array :: proc "contextless" (vertex_array: Vertex_Array, element_buffer: Buffer) {
	gl.VertexArrayElementBuffer(u32(vertex_array), u32(element_buffer))
}

enable_vertex_array_attrib :: proc "contextless" (vertex_array: Vertex_Array, index: u32) {
	gl.EnableVertexArrayAttrib(u32(vertex_array), index)
}

@(private)
gl_type :: #force_inline proc "contextless" ($T: typeid, loc := #caller_location) -> u32 {
	when T == i8 do return gl.BYTE
	else when T == u8 do return gl.UNSIGNED_BYTE
	else when T == i16 do return gl.SHORT
	else when T == u16 do return gl.UNSIGNED_SHORT
	else when T == i32 do return gl.INT
	else when T == u32 do return gl.UNSIGNED_INT
	else when T == f32 do return gl.FLOAT
	else do #panic("invalid type")
}

vertex_array_attrib_format :: proc "contextless" (vertex_array: Vertex_Array, attrib_index: u32, size: i32, $type: typeid, normalized: bool, relative_offset: u32, loc := #caller_location) {
	gl.VertexArrayAttribFormat(u32(vertex_array), attrib_index, size, gl_type(type), normalized, relative_offset)
}

vertex_array_attrib_binding :: proc "contextless" (vertex_array: Vertex_Array, attrib_index, binding_index: u32) {
	gl.VertexArrayAttribBinding(u32(vertex_array), attrib_index, binding_index)
}

Draw_Mode :: enum u32 {
	Points = 0x0000,
	Lines = 0x0001,
	Line_Loop = 0x0002,
	Line_Strip = 0x0003,
	Triangles = 0x0004,
	Triangle_Strip = 0x0005,
	Triangle_Fan = 0x0006,
	Lines_Adjacency = 0x000A,
	Line_Strip_Adjacency = 0x000B,
	Triangles_Adjacency = 0x000C,
	Triangle_Strip_Adjacency = 0x000D,
	Patches = 0x000E,
}

draw_arrays :: proc "contextless" (mode: Draw_Mode, first, count: i32) {
	gl.DrawArrays(u32(mode), first, count)
}

draw_elements :: proc "contextless" (mode: Draw_Mode, indices: []$T, loc := #caller_location) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl_type(typeid_of(T), loc), raw_data(indices))
}

bind_vertex_array :: proc "contextless" (vertex_array: Vertex_Array) {
	gl.BindVertexArray(u32(vertex_array))
}

program_uniform_1f :: proc "contextless" (program: Program, location: i32, v0: f32) {
	gl.ProgramUniform1f(u32(program), location, v0)
}

program_uniform_2f :: proc "contextless" (program: Program, location: i32, v0, v1: f32) {
	gl.ProgramUniform2f(u32(program), location, v0, v1)
}

program_uniform_3f :: proc "contextless" (program: Program, location: i32, v0, v1, v2: f32) {
	gl.ProgramUniform3f(u32(program), location, v0, v1, v2)
}

program_uniform_4f :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: f32) {
	gl.ProgramUniform4f(u32(program), location, v0, v1, v2, v3)
}

program_uniform_1i :: proc "contextless" (program: Program, location: i32, v0: i32) {
	gl.ProgramUniform1i(u32(program), location, v0)
}

program_uniform_2i :: proc "contextless" (program: Program, location: i32, v0, v1: i32) {
	gl.ProgramUniform2i(u32(program), location, v0, v1)
}

program_uniform_3i :: proc "contextless" (program: Program, location: i32, v0, v1, v2: i32) {
	gl.ProgramUniform3i(u32(program), location, v0, v1, v2)
}

program_uniform_4i :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: i32) {
	gl.ProgramUniform4i(u32(program), location, v0, v1, v2, v3)
}

program_uniform_1ui :: proc "contextless" (program: Program, location: i32, v0: u32) {
	gl.ProgramUniform1ui(u32(program), location, v0)
}

program_uniform_2ui :: proc "contextless" (program: Program, location: i32, v0, v1: u32) {
	gl.ProgramUniform2ui(u32(program), location, v0, v1)
}

program_uniform_3ui :: proc "contextless" (program: Program, location: i32, v0, v1, v2: u32) {
	gl.ProgramUniform3ui(u32(program), location, v0, v1, v2)
}

program_uniform_4ui :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: u32) {
	gl.ProgramUniform4ui(u32(program), location, v0, v1, v2, v3)
}

program_uniform :: proc{
	program_uniform_1f,
	program_uniform_2f,
	program_uniform_3f,
	program_uniform_4f,

	program_uniform_1i,
	program_uniform_2i,
	program_uniform_3i,
	program_uniform_4i,

	program_uniform_1ui,
	program_uniform_2ui,
	program_uniform_3ui,
	program_uniform_4ui,
}