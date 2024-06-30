package ngl

import gl "vendor:OpenGL"

shader_source :: proc "contextless" (shader: Shader, source: string) {
	source := source
	length := i32(len(source))
	shader_data_copy := cstring(raw_data(source))
	gl.impl_ShaderSource(u32(shader), 1, &shader_data_copy, &length)
}

shader_binary :: proc "contextless" (shaders: []Shader, binary: []byte) {
	gl.impl_ShaderBinary(i32(len(shaders)), ([^]u32)(raw_data(shaders)), gl.SHADER_BINARY_FORMAT_SPIR_V, raw_data(binary), i32(len(binary)))
}

compile_shader :: proc "contextless" (shader: Shader) {
	gl.impl_CompileShader(u32(shader))
}

specialize_shader :: proc "contextless" (shader: Shader, entry_point: cstring, constants_indices: []u32 = nil, constants_values: []u32 = nil) {
	length := u32(min(len(constants_indices), len(constants_values)))
	gl.impl_SpecializeShader(u32(shader), entry_point, length, raw_data(constants_indices), raw_data(constants_values))
}

create_shader :: proc "contextless" (type: Shader_Type) -> Shader {
	return Shader(gl.impl_CreateShader(u32(type)))
}

delete_shader :: proc "contextless" (shader: Shader) {
	gl.impl_DeleteShader(u32(shader))
}

is_shader :: proc "contextless" (shader: u32) -> bool {
	return gl.impl_IsShader(shader)
}

get_shader_precision_format :: proc "contextless" (shader_type: Shader_Precision_Format_Shader_Type, precision_type: Shader_Precision_Type) -> (range: [2]i32, precision: i32) {
	gl.impl_GetShaderPrecisionFormat(u32(shader_type), u32(precision_type), raw_data(&range), &precision)
	return
}