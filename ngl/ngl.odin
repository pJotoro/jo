package ngl

import gl "vendor:OpenGL"
import "core:strings"
import "../misc"

// VERSION_1_0

Cull_Mode :: enum u32 {
	Front = gl.FRONT,
	Back = gl.BACK,
	Front_And_Back = gl.FRONT_AND_BACK,
}

cull_face :: proc "contextless" (mode: Cull_Mode) {
	gl.CullFace(u32(mode))
}

Front_Mode :: enum u32 {
	CW = gl.CW,
	CCW = gl.CCW,
}

front_face :: proc "contextless" (mode: Front_Mode) {
	gl.FrontFace(u32(mode))
}

Hint_Target :: enum u32 {
	Line_Smooth = gl.LINE_SMOOTH_HINT,
	Polygon_Smooth = gl.POLYGON_SMOOTH_HINT,
	Texture_Compression = gl.TEXTURE_COMPRESSION_HINT,
	Fragment_Shader_Derivative = gl.FRAGMENT_SHADER_DERIVATIVE_HINT,
}

Hint_Mode :: enum u32 {
	Fastest = gl.FASTEST,
	Nicest = gl.NICEST,
	Dont_Care = gl.DONT_CARE,
}

hint :: proc "contextless" (target: Hint_Target, mode: Hint_Mode) {
	gl.Hint(u32(target), u32(mode))
}

line_width :: gl.LineWidth
point_size :: gl.PointSize

Polygon_Mode :: enum u32 {
	Point = gl.POINT,
	Line = gl.LINE,
	Fill = gl.FILL,
}

polygon_mode :: proc "contextless" (mode: Polygon_Mode) {
	gl.PolygonMode(gl.FRONT_AND_BACK, u32(mode))
}

scissor :: gl.Scissor

Clear_Flag :: enum u32 {
	Depth = 8,
	Stencil = 10, 
	Color = 14, 
}

Clear_Flags :: distinct bit_set[Clear_Flag; u32]

clear :: proc "contextless" (flags: Clear_Flags) {
	gl.Clear(transmute(u32)flags)
}

clear_color :: gl.ClearColor
clear_stencil :: gl.ClearStencil
clear_depth :: gl.ClearDepth
stencil_mask :: gl.StencilMask
color_mask :: gl.ColorMask
depth_mask :: gl.DepthMask

Capability :: enum u32 {
	Blend = gl.BLEND,
	Color_Logic_Op = gl.COLOR_LOGIC_OP,
	Cull_Face = gl.CULL_FACE,
	Debug_Output = gl.DEBUG_OUTPUT,
	Debug_Output_Synchronous = gl.DEBUG_OUTPUT_SYNCHRONOUS,
	Depth_Clamp = gl.DEPTH_CLAMP,
	Depth_Test = gl.DEPTH_TEST,
	Dither = gl.DITHER,
	Framebuffer_SRGB = gl.FRAMEBUFFER_SRGB,
	Line_Smooth = gl.LINE_SMOOTH,
	Multisample = gl.MULTISAMPLE,
	Polygon_Offset_Fill = gl.POLYGON_OFFSET_FILL,
	Polygon_Offset_Line = gl.POLYGON_OFFSET_LINE,
	Polygon_Offset_Point = gl.POLYGON_OFFSET_POINT,
	Polygon_Smooth = gl.POLYGON_SMOOTH,
	Primitive_Restart = gl.PRIMITIVE_RESTART,
	Primitive_Restart_Fixed_Index = gl.PRIMITIVE_RESTART_FIXED_INDEX,
	Rasterizer_Discard = gl.RASTERIZER_DISCARD,
	Sample_Alpha_To_Coverage = gl.SAMPLE_ALPHA_TO_COVERAGE,
	Sample_Alpha_To_One = gl.SAMPLE_ALPHA_TO_ONE,
	Sample_Coverage = gl.SAMPLE_COVERAGE,
	Sample_Shading = gl.SAMPLE_SHADING,
	Sample_Mask = gl.SAMPLE_MASK,
	Scissor_Test = gl.SCISSOR_TEST,
	Stencil_Test = gl.STENCIL_TEST,
	Texture_Cube_Map_Seamless = gl.TEXTURE_CUBE_MAP_SEAMLESS,
	Program_Point_Size = gl.PROGRAM_POINT_SIZE,
}

disable :: proc "contextless" (cap: Capability) {
	gl.Disable(u32(cap))
}

enable :: proc "contextless" (cap: Capability) {
	gl.Enable(u32(cap))
}

finish :: gl.Finish
flush :: gl.Flush

Blend_Func :: enum u32 {
	Zero = gl.ZERO,
	One = gl.ONE,
	Src_Color = gl.SRC_COLOR,
	One_Minus_Src_Color = gl.ONE_MINUS_SRC_COLOR,
	Dst_Color = gl.DST_COLOR,
	One_Minus_Dst_Color = gl.ONE_MINUS_DST_COLOR,
	Src_Alpha = gl.SRC_ALPHA,
	One_Minus_Src_Alpha = gl.ONE_MINUS_SRC_ALPHA,
	Dst_Alpha = gl.DST_ALPHA,
	One_Minus_Dst_Alpha = gl.ONE_MINUS_DST_ALPHA,
	Constant_Color = gl.CONSTANT_COLOR,
	One_Minus_Constant_Color = gl.ONE_MINUS_CONSTANT_COLOR,
	Constant_Alpha = gl.CONSTANT_ALPHA,
	One_Minus_Constant_Alpha = gl.ONE_MINUS_CONSTANT_ALPHA,
	Src_Alpha_Saturate = gl.SRC_ALPHA_SATURATE,
	Src1_Color = gl.SRC1_COLOR,
	One_Minus_Src1_Color = gl.ONE_MINUS_SRC1_COLOR,
	Src1_Alpha = gl.SRC1_ALPHA,
	One_Minus_Src1_Alpha = gl.ONE_MINUS_SRC1_ALPHA,
}

blend_func :: proc "contextless" (sfactor, dfactor: Blend_Func) {
	gl.BlendFunc(u32(sfactor), u32(dfactor))
}

Logic_Op :: enum u32 {
	Clear = gl.CLEAR,
	Set = gl.SET,
	Copy = gl.COPY,
	Copy_Inverted = gl.COPY_INVERTED,
	Noop = gl.NOOP,
	Invert = gl.INVERT,
	And = gl.AND,
	Nand = gl.NAND,
	Or = gl.OR,
	Nor = gl.NOR,
	Xor = gl.XOR,
	Equiv = gl.EQUIV,
	And_Reverse = gl.AND_REVERSE,
	And_Inverted = gl.AND_INVERTED,
	Or_Reverse = gl.OR_REVERSE,
	Or_Inverted = gl.OR_INVERTED,
}

logic_op :: proc "contextless" (opcode: Logic_Op) {
	gl.LogicOp(u32(opcode))
}

Stencil_Func :: enum u32 {
	Never = gl.NEVER,
	Less = gl.LESS,
	Less_Or_Equal = gl.LEQUAL,
	Greater = gl.GREATER,
	Greater_Or_Equal = gl.GEQUAL,
	Equal = gl.EQUAL,
	Not_Equal = gl.NOTEQUAL,
	Always = gl.ALWAYS,
}

stencil_func :: proc "contextless" (func: Stencil_Func, ref: i32, mask: u32) {
	gl.StencilFunc(u32(func), ref, mask)
}

Stencil_Op :: enum u32 {
	Keep = gl.KEEP,
	Zero = gl.ZERO,
	Replace = gl.REPLACE,
	Incr = gl.INCR,
	Incr_Wrap = gl.INCR_WRAP,
	Decr = gl.DECR,
	Decr_Wrap = gl.DECR_WRAP,
	Invert = gl.INVERT,
}

stencil_op :: proc "contextless" (sfail, dpfail, dppass: Stencil_Op) {
	gl.StencilOp(u32(sfail), u32(dpfail), u32(dppass))
}

Depth_Func :: Stencil_Func

depth_func :: proc "contextless" (func: Depth_Func) {
	gl.DepthFunc(u32(func))
}

Pixel_Store_Name :: enum u32 {
	Pack_Swap_Bytes = gl.PACK_SWAP_BYTES,
	Pack_LSB_First = gl.PACK_LSB_FIRST,
	Pack_Row_Length = gl.PACK_ROW_LENGTH,
	Pack_Image_Height = gl.PACK_IMAGE_HEIGHT,
	Pack_Skip_Pixels = gl.PACK_SKIP_PIXELS,
	Pack_Skip_Rows = gl.PACK_SKIP_ROWS,
	Pack_Skip_Images = gl.PACK_SKIP_IMAGES,
	Pack_Alignment = gl.PACK_ALIGNMENT,
	Unpack_Swap_Bytes = gl.UNPACK_SWAP_BYTES,
	Unpack_LSB_First = gl.UNPACK_LSB_FIRST,
	Unpack_Row_Length = gl.UNPACK_ROW_LENGTH,
	Unpack_Image_Height = gl.UNPACK_IMAGE_HEIGHT,
	Unpack_Skip_Pixels = gl.UNPACK_SKIP_PIXELS,
	Unpack_Skip_Rows = gl.UNPACK_SKIP_ROWS,
	Unpack_Skip_Images = gl.UNPACK_SKIP_IMAGES,
	Unpack_Alignment = gl.UNPACK_ALIGNMENT,
}

pixel_store_f :: proc "contextless" (pname: Pixel_Store_Name, param: f32) {
	gl.PixelStoref(u32(pname), param)
}

pixel_store_i :: proc "contextless" (pname: Pixel_Store_Name, param: i32) {
	gl.PixelStorei(u32(pname), param)
}

pixel_store :: proc{pixel_store_f, pixel_store_i}

String_Name :: enum u32 {
	Vendor = gl.VENDOR,
	Renderer = gl.RENDERER,
	Version = gl.VERSION,
	Shading_Language_Version = gl.SHADING_LANGUAGE_VERSION,
}

get_string :: proc(name: String_Name) -> string {
	return string(gl.GetString(u32(name)))
}






viewport :: gl.Viewport

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

Buffer_Storage_Flag :: enum u32 {
	Map_Read = 0,
	Map_Write = 1,
	Map_Persistent = 6,
	Map_Coherent = 7,
	Dynamic = 8,
	Client = 9,
}

Buffer_Storage_Flags :: distinct bit_set[Buffer_Storage_Flag; u32]

buffer_storage :: proc "contextless" (buffer: Buffer, data: []byte, flags: Buffer_Storage_Flags) {
	gl.NamedBufferStorage(u32(buffer), len(data), raw_data(data), transmute(u32)flags)
}

buffer_sub_data :: proc "contextless" (buffer: Buffer, offset: int, data: []byte) {
	gl.NamedBufferSubData(u32(buffer), offset, len(data), raw_data(data))
}

copy_buffer_sub_data :: proc "contextless" (read_buffer, write_buffer: Buffer, read_offset, write_offset, size: int) {
	gl.CopyNamedBufferSubData(u32(read_buffer), u32(write_buffer), read_offset, write_offset, size)
}

Buffer_Access_Flag :: enum u32 {
	Read,
	Write,
	Invalidate_Range,
	Invalidate_Buffer,
	Flush_Explicit,
	Unsynchronized,
	Persistent,
	Coherent,
}

Buffer_Access_Flags :: distinct bit_set[Buffer_Access_Flag; u32]

map_buffer :: proc "contextless" (buffer: Buffer, offset, length: int, access: Buffer_Access_Flags) -> []byte {
	return ([^]byte)(gl.MapNamedBufferRange(u32(buffer), offset, length, transmute(u32)access))[:length]
}

unmap_buffer :: proc "contextless" (buffer: Buffer) {
	gl.UnmapNamedBuffer(u32(buffer))
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
	binary, ok := misc.read_entire_file_aligned(filename, align_of(u32))
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

get_uniform_location_cstring :: proc "contextless" (program: Program, name: cstring) -> i32 {
	return gl.GetUniformLocation(u32(program), name)
}

get_uniform_location_string :: proc(program: Program, name: string, loc := #caller_location) -> i32 {
	cstring_name := strings.clone_to_cstring(name, context.temp_allocator, loc)
	return gl.GetUniformLocation(u32(program), cstring_name)
}

get_uniform_location :: proc{get_uniform_location_cstring, get_uniform_location_string}

Pipeline :: distinct u32

create_pipeline :: proc "contextless" () -> Pipeline {
	pipeline: u32 = ---
	gl.CreateProgramPipelines(1, &pipeline)
	return Pipeline(pipeline)
}

create_pipelines :: proc(n: i32, allocator := context.allocator, loc := #caller_location) -> []Pipeline {
	pipelines := make([]u32, n, allocator, loc)
	gl.CreateProgramPipelines(n, raw_data(pipelines))
	return transmute([]Pipeline)pipelines
}

Stage_Flag :: enum u32 {
	Vertex,
	Fragment,
	Geometry,
	Tess_Control,
	Tess_Evaluation,
	Compute,
}

Stage_Flags :: distinct bit_set[Stage_Flag; u32]

use_stages :: proc "contextless" (pipeline: Pipeline, stages: Stage_Flags, program: Program) {
	gl.UseProgramStages(u32(pipeline), transmute(u32)stages, u32(program))
}

bind_pipeline :: proc "contextless" (pipeline: Pipeline) {
	gl.BindProgramPipeline(u32(pipeline))
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

bind_vertex_buffer :: proc "contextless" (vertex_array: Vertex_Array, binding_index: u32, vertex_buffer: Buffer, offset: int, stride: i32) {
	gl.VertexArrayVertexBuffer(u32(vertex_array), binding_index, u32(vertex_buffer), offset, stride)
}

bind_element_buffer :: proc "contextless" (vertex_array: Vertex_Array, element_buffer: Buffer) {
	gl.VertexArrayElementBuffer(u32(vertex_array), u32(element_buffer))
}

enable_vertex_array_attrib :: proc "contextless" (vertex_array: Vertex_Array, attrib_index: u32) {
	gl.EnableVertexArrayAttrib(u32(vertex_array), attrib_index)
}

@(private)
gl_type :: #force_inline proc "contextless" ($T: typeid) -> u32 {
	when T == i8 do return gl.BYTE
	else when T == byte do return gl.UNSIGNED_BYTE
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

draw_elements :: proc "contextless" (mode: Draw_Mode, indices: []$T) {
	gl.DrawElements(u32(mode), i32(len(indices)), gl_type(T), raw_data(indices))
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

Texture :: distinct u32

Texture_Target :: enum u32 {
	D1 = 0x0DE0,
	D2 = 0x0DE1,
	D3 = 0x806F,
	Rectangle = 0x84F5,
	Cube_Map = 0x8513,
	D1_Array = 0x8C18,
	D2_Array = 0x8C1A,
	Cube_Map_Array = 0x9009,
	D2_Multisample = 0x9100,
	D2_Multisample_Array = 0x9102,
}

create_texture :: proc "contextless" (target: Texture_Target) -> Texture {
	texture: u32 = ---
	gl.CreateTextures(u32(target), 1, &texture)
	return Texture(texture)
}

create_textures :: proc(target: Texture_Target, n: i32, allocator := context.allocator, loc := #caller_location) -> []Texture {
	textures := make([]u32, n, allocator, loc = loc)
	gl.CreateTextures(u32(target), n, raw_data(textures))
	return transmute([]Texture)textures
}

// NOTE(pJotoro): I don't guarantee all the formats are in this enum. I want them to all be in there, it's just really annoying to find all of them because they're so disorganized.

Internal_Format :: enum u32 {
	R3_G3_B2 = 0x2A10,

	Rgb4 = 0x804F,
	Rgb5 = 0x8050,
	Rgb8 = 0x8051,
	Rgb10 = 0x8052,
	Rgb12 = 0x8053,
	Rgb16 = 0x8054,
	Rgba2 = 0x8055,
	Rgba4 = 0x8056,
	Rgb5_A1 = 0x8057,
	Rgba8 = 0x8058,
	Rgb10_A2 = 0x8059,
	Rgba12 = 0x805A,
	Rgba16 = 0x805B,

	R8 = 0x8229,
	R16 = 0x822A,
	Rg8 = 0x822B,
	Rg16 = 0x822C,
	R16f = 0x822D,
	R32f = 0x822E,
	Rg16f = 0x822F,
	Rg32f = 0x8230,
	R8i = 0x8231,
	R8ui = 0x8232,
	R16i = 0x8233,
	R16ui = 0x8234,
	R32i = 0x8235,
	R32ui = 0x8236,
	Rg8i = 0x8237,
	Rg8ui = 0x8238,
	Rg16i = 0x8239,
	Rg16ui = 0x823A,
	Rg32i = 0x823B,
	Rg32ui = 0x823C,

	Rgba32f = 0x8814,
	Rgb32f = 0x8815,
	Rgba16f = 0x881A,
	Rgb16f = 0x881B,

	R11f_G11f_B10f = 0x8C3A,

	Rgb9_E5 = 0x8C3D,

	Rgba32ui = 0x8D70,
	Rgb32ui = 0x8D71,
	Rgba16ui = 0x8D76,
	Rgb16ui = 0x8D77,
	Rgba8ui = 0x8D7C,
	Rgb8ui = 0x8D7D,
	Rgba32i = 0x8D82,
	Rgb32i = 0x8D83,
	Rgba16i = 0x8D88,
	Rgb16i = 0x8D89,
	Rgba8i = 0x8D8E,
	Rgb8i = 0x8D8F,

	R8_Snorm = 0x8F94,
	Rg8_Snorm = 0x8F95,
	Rgb8_Snorm = 0x8F96,
	Rgba8_Snorm = 0x8F97,
	R16_Snorm = 0x8F98,
	Rg16_Snorm = 0x8F99,
	Rgb16_Snorm = 0x8F9A,
	Rgba16_Snorm = 0x8F9B,

	Rgb10_A2ui = 0x906F,
}

texture_storage_1d :: proc "contextless" (texture: Texture, levels: i32, format: Internal_Format, size: i32) {
	gl.TextureStorage1D(u32(texture), levels, u32(format), size)
}

texture_storage_2d :: proc "contextless" (texture: Texture, levels: i32, format: Internal_Format, width, height: i32) {
	gl.TextureStorage2D(u32(texture), levels, u32(format), width, height)
}

texture_storage_3d :: proc "contextless" (texture: Texture, levels: i32, format: Internal_Format, width, height, depth: i32) {
	gl.TextureStorage3D(u32(texture), levels, u32(format), width, height, depth)
}

Format :: enum u32 {
	Stencil_Index = 0x1901,
	Depth_Component = 0x1902,
	Red = 0x1903,
	Rgb = 0x1907,
	Rgba = 0x1908,
	Rg = 0x8227,
}

// TODO(pJotoro): Should we allow all the crazy formats like GL_UNSIGNED_BYTE_2_3_3_REV here? Or should we just keep the basic ones? 

texture_sub_image_1d :: proc "contextless" (texture: Texture, level, offset: i32, format: Format, pixels: []$T) {
	gl.TextureSubImage1D(u32(texture), level, offset, i32(len(pixels)), i32(format), gl_type(T), raw_data(pixels))
}

texture_sub_image_2d_1d :: proc(texture: Texture, level, xoffset, yoffset, width, height: i32, format: Format, pixels: []$T, loc := #caller_location) {
	assert(condition = int(width * height) == len(pixels), loc = loc)
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, width, height, u32(format), gl_type(T), raw_data(pixels))
}

texture_sub_image_2d_2d :: proc "contextless" (texture: Texture, level, xoffset, yoffset: i32, format: Format, pixels: [][]$T) {
	gl.TextureSubImage2D(u32(texture), level, xoffset, yoffset, i32(len(pixels[0])), i32(len(pixels)), i32(format), gl_type(T), raw_data(pixels))
}

texture_sub_image_2d :: proc{texture_sub_image_2d_1d, texture_sub_image_2d_2d}

texture_sub_image_3d_1d :: proc(texture: Texture, level, xoffset, yoffset, zoffset, width, height, depth: i32, format: Format, pixels: []$T, loc := #caller_location) {
	assert(condition = int(width * height * depth) == len(pixels), loc = loc)
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, width, height, depth, i32(format), gl_type(T), raw_data(pixels))
}

texture_sub_image_3d_3d :: proc "contextless" (texture: Texture, level, xoffset, yoffset, zoffset: i32, format: Format, pixels: [][][]$T) {
	gl.TextureSubImage3D(u32(texture), level, xoffset, yoffset, zoffset, i32(len(pixels[0][0])), i32(len(pixels[0])), i32(len(pixels)), i32(format), gl_type(T), raw_data(pixels))
}

texture_sub_image_3d :: proc{texture_sub_image_3d_1d, texture_sub_image_3d_3d}

bind_texture_unit :: proc(unit: u32, texture: Texture, loc := #caller_location) {
	assert(unit >= 0 && unit <= 31, "invalid texture unit", loc)
	gl.BindTextureUnit(unit + gl.TEXTURE0, u32(texture))
}

generate_texture_mipmap :: proc "contextless" (texture: Texture) {
	gl.GenerateTextureMipmap(u32(texture))
}

Framebuffer :: distinct u32

create_framebuffer :: proc "contextless" () -> Framebuffer {
	framebuffer: u32 = ---
	gl.CreateFramebuffers(1, &framebuffer)
	return Framebuffer(framebuffer)
}

create_framebuffers :: proc(n: i32, allocator := context.allocator, loc := #caller_location) -> []Framebuffer {
	framebuffers := make([]u32, n, allocator, loc)
	gl.CreateFramebuffers(n, raw_data(framebuffers))
	return transmute([]Framebuffer)framebuffers
}

DEPTH :: 0x8D00
STENCIL :: 0x8D20
DEPTH_STENCIL :: 0x821A

framebuffer_texture :: proc(framebuffer: Framebuffer, attachment: u32, texture: Texture, level: i32, loc := #caller_location) {
	if attachment >= 0 && attachment <= 31 {
		gl.NamedFramebufferTexture(u32(framebuffer), attachment + gl.COLOR_ATTACHMENT0, u32(texture), level)
	} else if attachment == DEPTH || attachment == STENCIL || attachment == DEPTH_STENCIL {
		gl.NamedFramebufferTexture(u32(framebuffer), attachment, u32(texture), level)
	} else {
		panic("invalid attachment", loc)
	}
}

// NOTE(pJotoro): This is actually the same as Mag_Filter, except it's u32 instead of i32. I have no idea why OpenGL decides to make the same constants u32 or i32 whenever it wants. Either that or maybe there's an error in Odin's OpenGL bindings? I kind of doubt that though since they're auto generated...

Stretch_Filter :: enum u32 {
	Nearest = 0x2600,
	Linear = 0x2601,
}

blit_framebuffer :: proc "contextless" (read_framebuffer, draw_framebuffer: Framebuffer, src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1: i32, mask: Clear_Flags, filter: Stretch_Filter) {
	gl.BlitNamedFramebuffer(u32(read_framebuffer), u32(draw_framebuffer), src_x_0, src_y_0, src_x_1, src_y_1, dst_x_0, dst_y_0, dst_x_1, dst_y_1, transmute(u32)mask, u32(filter))
}

clear_framebuffer_color_iv :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: i32) {
	value := [4]i32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color_uiv :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: u32) {
	value := [4]u32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferuiv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color_fv :: proc "contextless" (framebuffer: Framebuffer, draw_buffer: i32, v0, v1, v2, v3: f32) {
	value := [4]f32{v0, v1, v2, v3}
	gl.ClearNamedFramebufferfv(u32(framebuffer), gl.COLOR, draw_buffer, raw_data(value[:]))
}

clear_framebuffer_color :: proc{clear_framebuffer_color_iv, clear_framebuffer_color_uiv, clear_framebuffer_color_fv}

clear_framebuffer_depth :: proc "contextless" (framebuffer: Framebuffer, value: f32) {
	value := value
	gl.ClearNamedFramebufferfv(u32(framebuffer), gl.DEPTH, 0, &value)
}

clear_framebuffer_stencil :: proc "contextless" (framebuffer: Framebuffer, value: i32) {
	value := value
	gl.ClearNamedFramebufferiv(u32(framebuffer), gl.STENCIL, 0, &value)
}

clear_framebuffer_depth_stencil :: proc "contextless" (framebuffer: Framebuffer, depth: f32, stencil: i32) {
	gl.ClearNamedFramebufferfi(u32(framebuffer), gl.DEPTH_STENCIL, 0, depth, stencil)
}