package ngl

// This is vendor:OpenGL/helpers.odin modified to use ngl.

import gl "vendor:OpenGL"
import "core:os"
import "core:fmt"
import "base:runtime"
_ :: fmt
_ :: runtime

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


@(private, thread_local)
last_compile_error_message: []byte
@(private, thread_local)
last_link_error_message: []byte

@(private, thread_local)
last_compile_error_type: Shader_Type
@(private, thread_local)
last_link_error_type: Shader_Type

get_last_error_messages :: proc() -> (compile_message: string, compile_type: Shader_Type, link_message: string, link_type: Shader_Type) {
	compile_message = string(last_compile_error_message[:max(0, len(last_compile_error_message)-1)])
	compile_type = last_compile_error_type
	link_message = string(last_link_error_message[:max(0, len(last_link_error_message)-1)])
	link_type = last_link_error_type
	return
}

get_last_error_message :: proc() -> (compile_message: string, compile_type: Shader_Type) {
	compile_message = string(last_compile_error_message[:max(0, len(last_compile_error_message)-1)])
	compile_type = last_compile_error_type
	return
}

// Shader checking and linking checking are identical
// except for calling differently named GL functions
// it's a bit ugly looking, but meh
when gl.GL_DEBUG {
	@private
	check_error :: proc(
		id: u32, type: Shader_Type, status: u32,
		iv_func: proc "c" (u32, u32, [^]i32, runtime.Source_Code_Location),
		log_func: proc "c" (u32, i32, ^i32, [^]u8, runtime.Source_Code_Location), 
		loc := #caller_location,
	) -> (success: bool) {
		result, info_log_length: i32
		iv_func(id, status, &result, loc)
		iv_func(id, gl.INFO_LOG_LENGTH, &info_log_length, loc)

		if result == 0 {
			if log_func == gl.GetShaderInfoLog {
				delete(last_compile_error_message)
				last_compile_error_message = make([]byte, info_log_length)
				last_compile_error_type = type

				log_func(id, i32(info_log_length), nil, raw_data(last_compile_error_message), loc)
				//fmt.printf_err("Error in %v:\n%s", type, string(last_compile_error_message[0:len(last_compile_error_message)-1]));
			} else {

				delete(last_link_error_message)
				last_link_error_message = make([]byte, info_log_length)
				last_compile_error_type = type

				log_func(id, i32(info_log_length), nil, raw_data(last_link_error_message), loc)
				//fmt.printf_err("Error in %v:\n%s", type, string(last_link_error_message[0:len(last_link_error_message)-1]));
			}

			return false
		}

		return true
	}
} else {
	@private
	check_error :: proc(
		id: u32, type: Shader_Type, status: u32,
		iv_func: proc "c" (u32, u32, [^]i32),
		log_func: proc "c" (u32, i32, ^i32, [^]u8),
	) -> (success: bool) {
		result, info_log_length: i32
		iv_func(id, status, &result)
		iv_func(id, gl.INFO_LOG_LENGTH, &info_log_length)

		if result == 0 {
			if log_func == gl.GetShaderInfoLog {
				delete(last_compile_error_message)
				last_compile_error_message = make([]u8, info_log_length)
				last_link_error_type = type

				log_func(id, i32(info_log_length), nil, raw_data(last_compile_error_message))
				fmt.eprintf("Error in %v:\n%s", type, string(last_compile_error_message[0:len(last_compile_error_message)-1]))
			} else {
				delete(last_link_error_message)
				last_link_error_message = make([]u8, info_log_length)
				last_link_error_type = type

				log_func(id, i32(info_log_length), nil, raw_data(last_link_error_message))
				fmt.eprintf("Error in %v:\n%s", type, string(last_link_error_message[0:len(last_link_error_message)-1]))

			}

			return false
		}

		return true
	}
}

// Compiling shaders are identical for any shader (vertex, geometry, fragment, tesselation, (maybe compute too))
compile_shader_from_binary :: proc(binary: []byte, shader_type: Shader_Type) -> (shader: Shader, ok: bool) {
	shader = create_shader(shader_type)
    shader_binary([]Shader{shader}, binary)
    specialize_shader(shader, "main")
	check_error(u32(shader), shader_type, gl.COMPILE_STATUS, gl.GetShaderiv, gl.GetShaderInfoLog) or_return
	ok = true
	return
}

// only used once, but I'd just make a subprocedure(?) for consistency
create_and_link_program :: proc(shaders: []Shader, binary_retrievable := false) -> (program: Program, ok: bool) {
	program = create_program()
	for shader in shaders {
		attach_shader(program, shader)
	}
	if binary_retrievable {
        program_binary_retrievable(program, true)
	}
    link_program(program)

	check_error(u32(program), .SHADER_LINK, gl.LINK_STATUS, gl.GetProgramiv, gl.GetProgramInfoLog) or_return
	ok = true
	return
}

load_compute_file :: proc(filename: string, binary_retrievable := false) -> (program: Program, ok: bool) {
	cs_data := os.read_entire_file(filename) or_return
	defer delete(cs_data)

	// Create the shaders
	compute_shader := compile_shader_from_binary(cs_data, .COMPUTE_SHADER) or_return
	return create_and_link_program([]Shader{compute_shader}, binary_retrievable)
}

load_compute_source :: proc(cs_data: []byte, binary_retrievable := false) -> (program: Program, ok: bool) {
	// Create the shaders
	compute_shader := compile_shader_from_binary(cs_data, .COMPUTE_SHADER) or_return
	return create_and_link_program([]Shader{compute_shader}, binary_retrievable)
}

load_shaders_file :: proc(vs_filename, fs_filename: string, binary_retrievable := false) -> (program: Program, ok: bool) {
	vs_binary := os.read_entire_file(vs_filename) or_return
	defer delete(vs_binary)
	
	fs_binary := os.read_entire_file(fs_filename) or_return
	defer delete(fs_binary)

	return load_shaders_source(vs_binary, fs_binary, binary_retrievable)
}

load_shaders_source :: proc(vs_binary, fs_binary: []byte, binary_retrievable := false) -> (program: Program, ok: bool) {
	// actual function from here
	vertex_shader := compile_shader_from_binary(vs_binary, .VERTEX_SHADER) or_return
	defer delete_shader(vertex_shader)

	fragment_shader := compile_shader_from_binary(fs_binary, .FRAGMENT_SHADER) or_return
	defer delete_shader(fragment_shader)

	return create_and_link_program([]Shader{vertex_shader, fragment_shader}, binary_retrievable)
}

load_shaders :: proc{load_shaders_file}


when ODIN_OS == .Windows {
	update_shader_if_changed :: proc(
		vertex_name, fragment_name: string, 
		program: Program, 
		last_vertex_time, last_fragment_time: os.File_Time,
	) -> (
		old_program: Program, 
		current_vertex_time, current_fragment_time: os.File_Time, 
		updated: bool,
	) {
		current_vertex_time, _ = os.last_write_time_by_name(vertex_name)
		current_fragment_time, _ = os.last_write_time_by_name(fragment_name)
		old_program = program

		if current_vertex_time != last_vertex_time || current_fragment_time != last_fragment_time {
			new_program, success := load_shaders(vertex_name, fragment_name)
			if success {
				delete_program(old_program)
				old_program = new_program
				fmt.println("Updated shaders")
				updated = true
			} else {
				fmt.println("Failed to update shaders")
			}
		}

		return old_program, current_vertex_time, current_fragment_time, updated
	}

	update_shader_if_changed_compute :: proc(
		compute_name: string, 
		program: Program, 
		last_compute_time: os.File_Time,
	) -> (
		old_program: Program, 
		current_compute_time: os.File_Time, 
		updated: bool,
	) {
		current_compute_time, _ = os.last_write_time_by_name(compute_name)
		old_program = program

		if current_compute_time != last_compute_time {
			new_program, success := load_compute_file(compute_name)
			if success {
                delete_program(old_program)
				old_program = new_program
				fmt.println("Updated shaders")
				updated = true
			} else {
				fmt.println("Failed to update shaders")
			}
		}

		return old_program, current_compute_time, updated
	}
}


Uniform_Info :: struct {
	location: i32,
	size:     i32,
	kind:     Uniform_Type,
	name:     string, // NOTE: This will need to be freed
}

Uniforms :: map[string]Uniform_Info

destroy_uniforms :: proc(u: Uniforms) {
	for _, v in u {
		delete(v.name)
	}
	delete(u)
}

get_uniforms_from_program :: proc(program: Program) -> (uniforms: Uniforms) {
	uniform_count := get_active_uniform_count(program)
	if uniform_count > 0 {
		reserve(&uniforms, int(uniform_count))
	}

	for i in 0..<uniform_count {
		uniform_info: Uniform_Info

		uniform_info.size, uniform_info.kind, uniform_info.name, uniform_info.location = get_active_uniform(program, u32(i))
		uniforms[uniform_info.name] = uniform_info
	}

	return uniforms
}
