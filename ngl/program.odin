package ngl

import gl "vendor:OpenGL"
import "core:strings"

create_program :: proc "contextless" () -> Program {
	return Program(gl.impl_CreateProgram())
}

delete_program :: proc "contextless" (program: Program) {
	gl.impl_DeleteProgram(u32(program))
}

is_program :: proc "contextless" (program: u32) -> bool {
	return gl.impl_IsProgram(program)
}

attach_shader :: proc "contextless" (program: Program, shader: Shader) {
	gl.impl_AttachShader(u32(program), u32(shader))
}

bind_attrib_location :: proc "contextless" (program: Program, index: u32, name: cstring) {
	gl.impl_BindAttribLocation(u32(program), index, name)
}

detach_shader :: proc "contextless" (program: Program, shader: Shader) {
	gl.impl_DetachShader(u32(program), u32(shader))
}

link_program :: proc "contextless" (program: Program) {
	gl.impl_LinkProgram(u32(program))
}

use_program :: proc "contextless" (program: Program) {
	gl.impl_UseProgram(u32(program))
}

uniform_1_f32 :: proc "contextless" (program: Program, location: i32, v0: f32) {
	gl.impl_ProgramUniform1f(u32(program), location, v0)
}

uniform_2_f32 :: proc "contextless" (program: Program, location: i32, v0, v1: f32) {
	gl.impl_ProgramUniform2f(u32(program), location, v0, v1)
}

uniform_3_f32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2: f32) {
	gl.impl_ProgramUniform3f(u32(program), location, v0, v1, v2)
}

uniform_4_f32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: f32) {
	gl.impl_ProgramUniform4f(u32(program), location, v0, v1, v2, v3)
}

uniform_1_i32 :: proc "contextless" (program: Program, location: i32, v0: i32) {
	gl.impl_ProgramUniform1i(u32(program), location, v0)
}

uniform_2_i32 :: proc "contextless" (program: Program, location: i32, v0, v1: i32) {
	gl.impl_ProgramUniform2i(u32(program), location, v0, v1)
}

uniform_3_i32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2: i32) {
	gl.impl_ProgramUniform3i(u32(program), location, v0, v1, v2)
}

uniform_4_i32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: i32) {
	gl.impl_ProgramUniform4i(u32(program), location, v0, v1, v2, v3)
}

uniform_matrix_2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 2]f32) {
	value := value
	gl.impl_ProgramUniformMatrix2fv(u32(program), location, 2*2, transpose, raw_data(&value))
}

uniform_matrix_3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 3]f32) {
	value := value
	gl.impl_ProgramUniformMatrix3fv(u32(program), location, 3*3, transpose, raw_data(&value))
}

uniform_matrix_4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 4]f32) {
	value := value
	gl.impl_ProgramUniformMatrix4fv(u32(program), location, 4*4, transpose, raw_data(&value))
}

uniform_matrix_2x3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 3]f32) {
	value := value
	gl.impl_ProgramUniformMatrix3x2fv(u32(program), location, 2*3, transpose, raw_data(&value))
}

uniform_matrix_3x2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 2]f32) {
	value := value
	gl.impl_ProgramUniformMatrix2x3fv(u32(program), location, 3*2, transpose, raw_data(&value))
}

uniform_matrix_2x4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 4]f32) {
	value := value
	gl.impl_ProgramUniformMatrix4x2fv(u32(program), location, 2*4, transpose, raw_data(&value))
}

uniform_matrix_4x2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 2]f32) {
	value := value
	gl.impl_ProgramUniformMatrix2x4fv(u32(program), location, 4*2, transpose, raw_data(&value))
}

uniform_matrix_3x4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 4]f32) {
	value := value
	gl.impl_ProgramUniformMatrix4x3fv(u32(program), location, 3*4, transpose, raw_data(&value))
}

uniform_matrix_4x3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 3]f32) {
	value := value
	gl.impl_ProgramUniformMatrix3x4fv(u32(program), location, 4*3, transpose, raw_data(&value))
}

uniform :: proc {
	uniform_1_f32,
	uniform_2_f32,
	uniform_3_f32,
	uniform_4_f32,
	uniform_1_i32,
	uniform_2_i32,
	uniform_3_i32,
	uniform_4_i32,
	uniform_matrix_2_f32,
	uniform_matrix_3_f32,
	uniform_matrix_4_f32,
	uniform_matrix_2x3_f32,
	uniform_matrix_3x2_f32,
	uniform_matrix_2x4_f32,
	uniform_matrix_4x2_f32,
	uniform_matrix_3x4_f32,
	uniform_matrix_4x3_f32,
}

validate_program :: proc "contextless" (program: Program) {
	gl.impl_ValidateProgram(u32(program))
}

get_uniform_uiv :: proc "contextless" (program: Program, location: i32) -> (param: u32) {
	gl.impl_GetnUniformuiv(u32(program), location, 1, &param)
	return
}

getn_uniform_uiv :: proc "contextless" (program: Program, location: i32, params: []u32) {
	gl.impl_GetnUniformuiv(u32(program), location, i32(len(params)), raw_data(params))
	return
}

get_uniform :: proc {
	get_uniform_uiv,
	getn_uniform_uiv,
}

bind_frag_data_location :: proc "contextless" (program: Program, color: u32, name: cstring) {
	gl.impl_BindFragDataLocation(u32(program), color, name)
}

get_frag_data_location :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.impl_GetFragDataLocation(u32(program), name)
}

get_uniform_indices :: proc "contextless" (program: Program, uniform_names: []cstring, uniform_indices: []u32) {
	gl.impl_GetUniformIndices(u32(program), i32(min(len(uniform_names), len(uniform_indices))), raw_data(uniform_names), raw_data(uniform_indices))
}

uniform_block_binding :: proc "contextless" (program: Program, uniform_block_index, uniform_block_binding: u32) {
	gl.impl_UniformBlockBinding(u32(program), uniform_block_index, uniform_block_binding)
}

get_frag_data_index :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.impl_GetFragDataIndex(u32(program), name)
}

bind_frag_data_location_indexed :: proc "contextless" (program: Program, color_number: u32, index: u32, name: cstring) {
	gl.impl_BindFragDataLocationIndexed(u32(program), color_number, index, name)
}

get_program_binary :: proc(program: Program, allocator := context.allocator) -> (binary: []byte, binary_format: Binary_Format) {
	buf_size: i32 = ---
	gl.impl_GetProgramiv(u32(program), gl.PROGRAM_BINARY_LENGTH, &buf_size)
	binary = make([]byte, buf_size, allocator)
	length: i32 = ---
	gl.impl_GetProgramBinary(u32(program), buf_size, &length, (^u32)(&binary_format), raw_data(binary))
	binary = binary[:int(length)]
	return
}

program_binary :: proc "contextless" (program: Program, binary: []byte) {
	gl.impl_ProgramBinary(u32(program), gl.SHADER_BINARY_FORMAT_SPIR_V, raw_data(binary), i32(len(binary)))
}

get_uniform_location :: proc "contextless" (program: Program, name: cstring) -> i32 {
    return gl.impl_GetUniformLocation(u32(program), name)
}

get_active_uniform_count :: proc "contextless" (program: Program) -> (active_uniforms: i32) {
    gl.impl_GetProgramiv(u32(program), gl.ACTIVE_UNIFORMS, &active_uniforms)
    return
}

get_active_uniform :: proc(program: Program, index: u32, allocator := context.allocator) -> (size: i32, type: Uniform_Type, name: string) {
    BUF_SIZE :: 256
    buf: [BUF_SIZE]byte
    length: i32 = ---
    gl.impl_GetActiveUniform(u32(program), index, BUF_SIZE, &length, &size, (^u32)(&type), raw_data(&buf))
    name = strings.clone(string(buf[:int(length)]), allocator)
    return
}

program_binary_retrievable :: proc "contextless" (program: Program, binary_retrievable: bool) {
    gl.impl_ProgramParameteri(u32(program), gl.PROGRAM_BINARY_RETRIEVABLE_HINT, i32(binary_retrievable))
}

program_separable :: proc "contextless" (program: Program, separable: bool) {
    gl.impl_ProgramParameteri(u32(program), gl.PROGRAM_SEPARABLE, i32(separable))
}