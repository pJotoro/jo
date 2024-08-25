package vendor_gl

// Helper for loading shaders into a program

import "core:os"
import "core:fmt"
import "core:strings"
import "base:runtime"
import "base:intrinsics"
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
when GL_DEBUG {
	@private
	check_error :: proc(
		id: u32, type: Shader_Type, status: u32,
		iv_func: proc "c" (u32, $Type, [^]i32, runtime.Source_Code_Location),
		log_func: proc "c" (u32, i32, ^i32, [^]u8, runtime.Source_Code_Location), 
		loc := #caller_location,
	) -> (success: bool)
	where intrinsics.type_core_type(Type) == u32 {
		result, info_log_length: i32
		iv_func(id, Type(status), &result, loc)
		iv_func(id, Type(INFO_LOG_LENGTH), &info_log_length, loc)

		if result == 0 {
			if log_func == GetShaderInfoLog {
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
		iv_func: proc "c" (u32, $Type, [^]i32),
		log_func: proc "c" (u32, i32, ^i32, [^]u8),
	) -> (success: bool) where intrinsics.type_core_type(Type) == u32 {
		result, info_log_length: i32
		iv_func(id, Type(status), &result)
		iv_func(id, Type(INFO_LOG_LENGTH), &info_log_length)

		if result == 0 {
			if log_func == GetShaderInfoLog {
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
@private
compile_shader_from_source :: proc(shader_data: string, shader_type: Shader_Type) -> (shader_id: u32, ok: bool) {
	shader_id = CreateShader(shader_type)
	length := i32(len(shader_data))
	shader_data_copy := cstring(raw_data(shader_data))
	ShaderSource(shader_id, 1, &shader_data_copy, &length)
	CompileShader(shader_id)

	check_error(shader_id, shader_type, COMPILE_STATUS, GetShaderiv, GetShaderInfoLog) or_return
	ok = true
	return
}

// only used once, but I'd just make a subprocedure(?) for consistency
@private
create_and_link_program :: proc(shader_ids: []u32, binary_retrievable := false) -> (program_id: u32, ok: bool) {
	program_id = CreateProgram()
	for id in shader_ids {
		AttachShader(program_id, id)
	}
	if binary_retrievable {
		ProgramParameteri(program_id, .Program_Binary_Retrievable_Hint, 1/*true*/)
	}
	LinkProgram(program_id)

	check_error(program_id, .SHADER_LINK, LINK_STATUS, GetProgramiv, GetProgramInfoLog) or_return
	ok = true
	return
}

load_compute_file :: proc(filename: string, binary_retrievable := false) -> (program_id: u32, ok: bool) {
	cs_data := os.read_entire_file(filename) or_return
	defer delete(cs_data)

	// Create the shaders
	compute_shader_id := compile_shader_from_source(string(cs_data), .COMPUTE_SHADER) or_return
	return create_and_link_program([]u32{compute_shader_id}, binary_retrievable)
}

load_compute_source :: proc(cs_data: string, binary_retrievable := false) -> (program_id: u32, ok: bool) {
	// Create the shaders
	compute_shader_id := compile_shader_from_source(cs_data, .COMPUTE_SHADER) or_return
	return create_and_link_program([]u32{compute_shader_id}, binary_retrievable)
}

load_shaders_file :: proc(vs_filename, fs_filename: string, binary_retrievable := false) -> (program_id: u32, ok: bool) {
	vs_data := os.read_entire_file(vs_filename) or_return
	defer delete(vs_data)
	
	fs_data := os.read_entire_file(fs_filename) or_return
	defer delete(fs_data)

	return load_shaders_source(string(vs_data), string(fs_data), binary_retrievable)
}

load_shaders_source :: proc(vs_source, fs_source: string, binary_retrievable := false) -> (program_id: u32, ok: bool) {
	// actual function from here
	vertex_shader_id := compile_shader_from_source(vs_source, .VERTEX_SHADER) or_return
	defer DeleteShader(vertex_shader_id)

	fragment_shader_id := compile_shader_from_source(fs_source, .FRAGMENT_SHADER) or_return
	defer DeleteShader(fragment_shader_id)

	return create_and_link_program([]u32{vertex_shader_id, fragment_shader_id}, binary_retrievable)
}

load_shaders :: proc{load_shaders_file}


when ODIN_OS == .Windows {
	update_shader_if_changed :: proc(
		vertex_name, fragment_name: string, 
		program: u32, 
		last_vertex_time, last_fragment_time: os.File_Time,
	) -> (
		old_program: u32, 
		current_vertex_time, current_fragment_time: os.File_Time, 
		updated: bool,
	) {
		current_vertex_time, _ = os.last_write_time_by_name(vertex_name)
		current_fragment_time, _ = os.last_write_time_by_name(fragment_name)
		old_program = program

		if current_vertex_time != last_vertex_time || current_fragment_time != last_fragment_time {
			new_program, success := load_shaders(vertex_name, fragment_name)
			if success {
				DeleteProgram(old_program)
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
		program: u32, 
		last_compute_time: os.File_Time,
	) -> (
		old_program: u32, 
		current_compute_time: os.File_Time, 
		updated: bool,
	) {
		current_compute_time, _ = os.last_write_time_by_name(compute_name)
		old_program = program

		if current_compute_time != last_compute_time {
			new_program, success := load_compute_file(compute_name)
			if success {
				DeleteProgram(old_program)
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

get_uniforms_from_program :: proc(program: u32) -> (uniforms: Uniforms) {
	uniform_count: i32
	GetProgramiv(program, .Active_Uniforms, &uniform_count)

	if uniform_count > 0 {
		reserve(&uniforms, int(uniform_count))
	}

	for i in 0..<uniform_count {
		uniform_info: Uniform_Info

		length: i32
		cname: [256]u8
		GetActiveUniform(program, u32(i), 256, &length, &uniform_info.size, &uniform_info.kind, &cname[0])

		uniform_info.location = GetUniformLocation(program, cstring(&cname[0]))
		uniform_info.name = strings.clone(string(cname[:length])) // @NOTE: These need to be freed
		uniforms[uniform_info.name] = uniform_info
	}

	return uniforms
}
