package ngl

import gl "vendor:OpenGL"

attach_shader :: proc "contextless" (program: Program, shader: Shader) {
	gl.AttachShader(u32(program), u32(shader))
}

bind_attrib_location :: proc "contextless" (program: Program, index: u32, name: cstring) {
	gl.BindAttribLocation(u32(program), index, name)
}

compile_shaders :: proc "contextless" (shaders: []Shader, binary: []byte) {
	gl.ShaderBinary(i32(len(shaders)), ([^]u32)(raw_data(shaders)), gl.SHADER_BINARY_FORMAT_SPIR_V, raw_data(binary), i32(len(binary)))
}

create_program :: proc "contextless" () -> Program {
	return Program(gl.CreateProgram())
}

create_shader :: proc "contextless" (type: Shader_Type) -> Shader {
	return Shader(gl.CreateShader(u32(type)))
}

delete_program :: proc "contextless" (program: Program) {
	gl.DeleteProgram(u32(program))
}

delete_shader :: proc "contextless" (shader: Shader) {
	gl.DeleteShader(u32(shader))
}

detach_shader :: proc "contextless" (program: Program, shader: Shader) {
	gl.DetachShader(u32(program), u32(shader))
}

is_program :: proc "contextless" (program: u32) -> bool {
	return gl.IsProgram(program)
}

is_shader :: proc "contextless" (shader: u32) -> bool {
	return gl.IsShader(shader)
}

link_program :: proc "contextless" (program: Program) {
	gl.LinkProgram(u32(program))
}

use_program :: proc "contextless" (program: Program) {
	gl.UseProgram(u32(program))
}

uniform_1_f32 :: proc "contextless" (program: Program, location: i32, v0: f32) {
	gl.ProgramUniform1f(u32(program), location, v0)
}

uniform_2_f32 :: proc "contextless" (program: Program, location: i32, v0, v1: f32) {
	gl.ProgramUniform2f(u32(program), location, v0, v1)
}

uniform_3_f32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2: f32) {
	gl.ProgramUniform3f(u32(program), location, v0, v1, v2)
}

uniform_4_f32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: f32) {
	gl.ProgramUniform4f(u32(program), location, v0, v1, v2, v3)
}

uniform_1_i32 :: proc "contextless" (program: Program, location: i32, v0: i32) {
	gl.ProgramUniform1i(u32(program), location, v0)
}

uniform_2_i32 :: proc "contextless" (program: Program, location: i32, v0, v1: i32) {
	gl.ProgramUniform2i(u32(program), location, v0, v1)
}

uniform_3_i32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2: i32) {
	gl.ProgramUniform3i(u32(program), location, v0, v1, v2)
}

uniform_4_i32 :: proc "contextless" (program: Program, location: i32, v0, v1, v2, v3: i32) {
	gl.ProgramUniform4i(u32(program), location, v0, v1, v2, v3)
}

uniform_matrix_2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 2]f32) {
	value := value
	gl.ProgramUniformMatrix2fv(u32(program), location, 2*2, transpose, raw_data(&value))
}

uniform_matrix_3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 3]f32) {
	value := value
	gl.ProgramUniformMatrix3fv(u32(program), location, 3*3, transpose, raw_data(&value))
}

uniform_matrix_4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 4]f32) {
	value := value
	gl.ProgramUniformMatrix4fv(u32(program), location, 4*4, transpose, raw_data(&value))
}

uniform_matrix_2x3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 3]f32) {
	value := value
	gl.ProgramUniformMatrix3x2fv(u32(program), location, 2*3, transpose, raw_data(&value))
}

uniform_matrix_3x2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 2]f32) {
	value := value
	gl.ProgramUniformMatrix2x3fv(u32(program), location, 3*2, transpose, raw_data(&value))
}

uniform_matrix_2x4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[2, 4]f32) {
	value := value
	gl.ProgramUniformMatrix4x2fv(u32(program), location, 2*4, transpose, raw_data(&value))
}

uniform_matrix_4x2_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 2]f32) {
	value := value
	gl.ProgramUniformMatrix2x4fv(u32(program), location, 4*2, transpose, raw_data(&value))
}

uniform_matrix_3x4_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[3, 4]f32) {
	value := value
	gl.ProgramUniformMatrix4x3fv(u32(program), location, 3*4, transpose, raw_data(&value))
}

uniform_matrix_4x3_f32 :: proc "contextless" (program: Program, location: i32, transpose: bool, value: matrix[4, 3]f32) {
	value := value
	gl.ProgramUniformMatrix3x4fv(u32(program), location, 4*3, transpose, raw_data(&value))
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
	gl.ValidateProgram(u32(program))
}

get_uniform_uiv :: proc "contextless" (program: Program, location: i32) -> (param: u32) {
	gl.GetnUniformuiv(u32(program), location, 1, &param)
	return
}

getn_uniform_uiv :: proc "contextless" (program: Program, location: i32, params: []u32) {
	gl.GetnUniformuiv(u32(program), location, i32(len(params)), raw_data(params))
	return
}

get_uniform :: proc {
	get_uniform_uiv,
	getn_uniform_uiv,
}

bind_frag_data_location :: proc "contextless" (program: Program, color: u32, name: cstring) {
	gl.BindFragDataLocation(u32(program), color, name)
}

get_frag_data_location :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.GetFragDataLocation(u32(program), name)
}

get_uniform_indices :: proc "contextless" (program: Program, uniform_names: []cstring, uniform_indices: []u32) {
	gl.GetUniformIndices(u32(program), i32(min(len(uniform_names), len(uniform_indices))), raw_data(uniform_names), raw_data(uniform_indices))
}

uniform_block_binding :: proc "contextless" (program: Program, uniform_block_index, uniform_block_binding: u32) {
	gl.UniformBlockBinding(u32(program), uniform_block_index, uniform_block_binding)
}

get_frag_data_index :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.GetFragDataIndex(u32(program), name)
}

bind_frag_data_location_indexed :: proc "contextless" (program: Program, color_number: u32, index: u32, name: cstring) {
	gl.BindFragDataLocationIndexed(u32(program), color_number, index, name)
}

shader_binary :: proc "contextless" (shaders: []Shader, binary_format: Shader_Binary_Format, binary: []byte) {
	gl.ShaderBinary(i32(len(shaders)), ([^]u32)(raw_data(shaders)), u32(binary_format), raw_data(binary), i32(len(binary)))
}

get_shader_precision_format :: proc "contextless" (shader_type: Shader_Precision_Format_Shader_Type, precision_type: Shader_Precision_Type) -> (range: [2]i32, precision: i32) {
	gl.GetShaderPrecisionFormat(u32(shader_type), u32(precision_type), raw_data(&range), &precision)
	return
}

get_program_binary :: proc(program: Program, allocator := context.allocator) -> (binary: []byte, binary_format: Shader_Binary_Format) {
	buf_size: i32 = ---
	gl.GetProgramiv(u32(program), gl.PROGRAM_BINARY_LENGTH, &buf_size)
	binary = make([]byte, buf_size, allocator)
	length: i32 = ---
	gl.GetProgramBinary(u32(program), buf_size, &length, (^u32)(&binary_format), raw_data(binary))
	binary = binary[:int(length)]
	return
}

program_binary :: proc "contextless" (program: Program, binary_format: Program_Binary_Format, binary: []byte) {
	gl.ProgramBinary(u32(program), u32(binary_format), raw_data(binary), i32(len(binary)))
}

Shader_Type :: enum i32 {
	NONE = 0x0000,
	FRAGMENT_SHADER        = 0x8B30,
	VERTEX_SHADER          = 0x8B31,
	GEOMETRY_SHADER        = 0x8DD9,
	COMPUTE_SHADER         = 0x91B9,
	TESS_EVALUATION_SHADER = 0x8E87,
	TESS_CONTROL_SHADER    = 0x8E88,
	SHADER_LINK            = -1, // @Note: Not an OpenGL constant, but used for error checking.
}