package ngl

import gl "vendor:OpenGL"

/* Shader Objects [7.1-2] */

/* uint CreateShader(enum type); */
// NOTE(tarik): Since helpers.odin defined an own Shader_Type, this is unused.
_Shader_Type :: enum u32 {
	Compute_Shader         = gl.COMPUTE_SHADER,
	Fragment_Shader        = gl.FRAGMENT_SHADER,
	Geometry_Shader        = gl.GEOMETRY_SHADER,
	Vertex_Shader          = gl.VERTEX_SHADER,
	Tess_Evaluation_Shader = gl.TESS_EVALUATION_SHADER,
	Tess_Control_Shader    = gl.TESS_CONTROL_SHADER,
}

/* void ShaderBinary(sizei count, const uint *shaders, enum binaryformat, const void *binary, sizei length); */
Shader_Binary_Format :: enum u32 {
	Shader_Binary_Format_SPIR_V = gl.SHADER_BINARY_FORMAT_SPIR_V,
}


/* Program Objects [7.3] */

/* uint CreateShaderProgramv(enum type, sizei count, const char * const * strings); */
// type: Shader_Type

/* void ProgramParameteri(uint program, enum pname, int value); */
Program_Parameter :: enum u32 {
	Program_Separable               = gl.PROGRAM_SEPARABLE,
	Program_Binary_Retrievable_Hint = gl.PROGRAM_BINARY_RETRIEVABLE_HINT,
}


/* Program Interfaces [7.3.1] */

/* void GetProgramInterfaceiv(uint program, enum programInterface, enum pname, int *params); */
Program_Interface :: enum u32 {
	Uniform                            = gl.UNIFORM,
	Uniform_Block                      = gl.UNIFORM_BLOCK,
	Atomic_Counter_Buffer              = gl.ATOMIC_COUNTER_BUFFER,
	Program_Input                      = gl.PROGRAM_INPUT,
	Program_Output                     = gl.PROGRAM_OUTPUT,

	Vertex_Subroutine                  = gl.VERTEX_SUBROUTINE,
	Tess_Control_Subroutine            = gl.TESS_CONTROL_SUBROUTINE,
	Tess_Evaluation_Subroutine         = gl.TESS_EVALUATION_SUBROUTINE,
	Geometry_Subroutine                = gl.GEOMETRY_SUBROUTINE,
	Fragment_Subroutine                = gl.FRAGMENT_SUBROUTINE,
	Compute_Subroutine                 = gl.COMPUTE_SUBROUTINE,

	Vertex_Subroutine_Uniform          = gl.VERTEX_SUBROUTINE_UNIFORM,
	Tess_Control_Subroutine_Uniform    = gl.TESS_CONTROL_SUBROUTINE_UNIFORM,
	Tess_Evaluation_Subroutine_Uniform = gl.TESS_EVALUATION_SUBROUTINE_UNIFORM,
	Geometry_Subroutine_Uniform        = gl.GEOMETRY_SUBROUTINE_UNIFORM,
	Fragment_Subroutine_Uniform        = gl.FRAGMENT_SUBROUTINE_UNIFORM,
	Compute_Subroutine_Uniform         = gl.COMPUTE_SUBROUTINE_UNIFORM,

	Transform_Feedback_Varying         = gl.TRANSFORM_FEEDBACK_VARYING,
	Transform_Feedback_Buffer          = gl.TRANSFORM_FEEDBACK_BUFFER,
	Buffer_Variable                    = gl.BUFFER_VARIABLE,
	Shader_Storage_Block               = gl.SHADER_STORAGE_BLOCK,
}

Program_Interface_Parameter :: enum u32 {
	Active_Resources               = gl.ACTIVE_RESOURCES,
	Max_Name_Length                = gl.MAX_NAME_LENGTH,
	Max_Num_Active_Variables       = gl.MAX_NUM_ACTIVE_VARIABLES,
	Max_Num_Compatible_Subroutines = gl.MAX_NUM_COMPATIBLE_SUBROUTINES,
}

/* uint GetProgramResourceIndex(uint program, enum programInterface, const char *name); */
Program_Resource_Interface :: enum u32 {
	Uniform                            = gl.UNIFORM,
	Uniform_Block                      = gl.UNIFORM_BLOCK,
	Program_Input                      = gl.PROGRAM_INPUT,
	Program_Output                     = gl.PROGRAM_OUTPUT,

	Vertex_Subroutine                  = gl.VERTEX_SUBROUTINE,
	Tess_Control_Subroutine            = gl.TESS_CONTROL_SUBROUTINE,
	Tess_Evaluation_Subroutine         = gl.TESS_EVALUATION_SUBROUTINE,
	Geometry_Subroutine                = gl.GEOMETRY_SUBROUTINE,
	Fragment_Subroutine                = gl.FRAGMENT_SUBROUTINE,
	Compute_Subroutine                 = gl.COMPUTE_SUBROUTINE,

	Vertex_Subroutine_Uniform          = gl.VERTEX_SUBROUTINE_UNIFORM,
	Tess_Control_Subroutine_Uniform    = gl.TESS_CONTROL_SUBROUTINE_UNIFORM,
	Tess_Evaluation_Subroutine_Uniform = gl.TESS_EVALUATION_SUBROUTINE_UNIFORM,
	Geometry_Subroutine_Uniform        = gl.GEOMETRY_SUBROUTINE_UNIFORM,
	Fragment_Subroutine_Uniform        = gl.FRAGMENT_SUBROUTINE_UNIFORM,
	Compute_Subroutine_Uniform         = gl.COMPUTE_SUBROUTINE_UNIFORM,

	Transform_Feedback_Varying         = gl.TRANSFORM_FEEDBACK_VARYING,
	Buffer_Variable                    = gl.BUFFER_VARIABLE,
	Shader_Storage_Block               = gl.SHADER_STORAGE_BLOCK,
}

/* void GetProgramResourceName(uint program, enum programInterface, uint index, sizei bufSize, sizei *length, char *name); */
// programInterface: Program_Resource_Interface

/* void GetProgramResourceiv(uint program, enum programInterface, uint index, sizei propCount, const enum *props, sizei bufSize, sizei *length, int *params); */
// programInterface: Program_Interface

Program_Resource_Property :: enum u32 {
	Active_Variables                     = gl.ACTIVE_VARIABLES,
	Buffer_Binding                       = gl.BUFFER_BINDING,
	Num_Active_Variables                 = gl.NUM_ACTIVE_VARIABLES,
	Array_Size                           = gl.ARRAY_SIZE,
	Array_Stride                         = gl.ARRAY_STRIDE,
	Block_Index                          = gl.BLOCK_INDEX,
	Is_Row_Major                         = gl.IS_ROW_MAJOR,
	Matrix_Stride                        = gl.MATRIX_STRIDE,
	Atomic_Counter_Buffer_Index          = gl.ATOMIC_COUNTER_BUFFER_INDEX,
	Buffer_Data_Size                     = gl.BUFFER_DATA_SIZE,
	Num_Compatible_Subroutines           = gl.NUM_COMPATIBLE_SUBROUTINES,
	Compatible_Subroutines               = gl.COMPATIBLE_SUBROUTINES,
	Is_Per_Patch                         = gl.IS_PER_PATCH,
	Location                             = gl.LOCATION,
	Location_Component                   = gl.LOCATION_COMPONENT,
	Location_Index                       = gl.LOCATION_INDEX,
	Name_Length                          = gl.NAME_LENGTH,
	Offset                               = gl.OFFSET,
	Referenced_By_Vertex_Shader          = gl.REFERENCED_BY_VERTEX_SHADER,
	Referenced_By_Tess_Control_Shader    = gl.REFERENCED_BY_TESS_CONTROL_SHADER,
	Referenced_By_Tess_Evaluation_Shader = gl.REFERENCED_BY_TESS_EVALUATION_SHADER,
	Referenced_By_Geometry_Shader        = gl.REFERENCED_BY_GEOMETRY_SHADER,
	Referenced_By_Fragment_Shader        = gl.REFERENCED_BY_FRAGMENT_SHADER,
	Referenced_By_Compute_Shader         = gl.REFERENCED_BY_COMPUTE_SHADER,
	Transform_Feedback_Buffer_Index      = gl.TRANSFORM_FEEDBACK_BUFFER_INDEX,
	Transform_Feedback_Buffer_Stride     = gl.TRANSFORM_FEEDBACK_BUFFER_STRIDE,
	Top_Level_Array_Size                 = gl.TOP_LEVEL_ARRAY_SIZE,
	Top_Level_Array_Stride               = gl.TOP_LEVEL_ARRAY_STRIDE,
	Type                                 = gl.TYPE,
}

/* int GetProgramResourceLocation(uint program, enum programInterface, const char *name); */
Program_Resource_Location :: enum u32 {
	Uniform                            = gl.UNIFORM,
	Program_Input                      = gl.PROGRAM_INPUT,
	Program_Output                     = gl.PROGRAM_OUTPUT,
	Vertex_Subroutine_Uniform          = gl.VERTEX_SUBROUTINE_UNIFORM,
	Tess_Control_Subroutine_Uniform    = gl.TESS_CONTROL_SUBROUTINE_UNIFORM,
	Tess_Evaluation_Subroutine_Uniform = gl.TESS_EVALUATION_SUBROUTINE_UNIFORM,
	Geometry_Subroutine_Uniform        = gl.GEOMETRY_SUBROUTINE_UNIFORM,
	Fragment_Subroutine_Uniform        = gl.FRAGMENT_SUBROUTINE_UNIFORM,
	Compute_Subroutine_Uniform         = gl.COMPUTE_SUBROUTINE_UNIFORM,
}

/* int GetProgramResourceLocationIndex(uint program, enum programInterface, const char *name); */
Program_Resource_Location_Index :: enum u32 {
	Program_Output = gl.PROGRAM_OUTPUT,
}


/* Program Pipeline Objects [7.4] */

/* void UseProgramStages(uint pipeline, bitfield stages, uint program); */
Program_Stages_Bits :: enum u32 {
	Compute_Shader_Bit         = gl.COMPUTE_SHADER_BIT,
	Vertex_Shader_Bit          = gl.VERTEX_SHADER_BIT,
	Tess_Control_Shader_Bit    = gl.TESS_CONTROL_SHADER_BIT,
	Tess_Evaluation_Shader_Bit = gl.TESS_EVALUATION_SHADER_BIT,
	Geometry_Shader_Bit        = gl.GEOMETRY_SHADER_BIT,
	Fragment_Shader_Bit        = gl.FRAGMENT_SHADER_BIT,

	All_Shader_Bits            = gl.ALL_SHADER_BITS,
}


/* Program Binaries [7.5] */

/* void GetProgramBinary(uint program, sizei bufSize, sizei *length, enum *binaryFormat, void *binary); */
Program_Binary_Format :: enum u32 {
	// TODO(tarik): Not sure if this is correct

	// "OpenGL defines no specific binary formats. Queries of
	// values NUM_PROGRAM_BINARY_FORMATS and PROGRAM_BINARY_FORMATS return
	// the number of program binary formats and the list of program binary
	// format values supported by an implementation. The binaryFormat
	// returned by GetProgramBinary must be present in this list."
}

/* void ProgramBinary(uint program, enum binaryFormat, const void *binary, sizei length); */
// TODO(tarik): Not sure if this is correct
// binaryFormat: Program_Binary_Format


/* Uniform Variables [7.6] */

/* void GetActiveUniform(uint program, uint index, sizei bufSize, sizei *length, int *size, enum *type, char *name); */
Uniform_Type :: enum u32 {
	Float                                     = gl.FLOAT,
	Float_Vec2                                = gl.FLOAT_VEC2,
	Float_Vec3                                = gl.FLOAT_VEC3,
	Float_Vec4                                = gl.FLOAT_VEC4,

	Double                                    = gl.DOUBLE,
	Double_Vec2                               = gl.DOUBLE_VEC2,
	Double_Vec3                               = gl.DOUBLE_VEC3,
	Double_Vec4                               = gl.DOUBLE_VEC4,

	Int                                       = gl.INT,
	Int_Vec2                                  = gl.INT_VEC2,
	Int_Vec3                                  = gl.INT_VEC3,
	Int_Vec4                                  = gl.INT_VEC4,

	Unsigned_Int                              = gl.UNSIGNED_INT,
	Unsigned_Int_Vec2                         = gl.UNSIGNED_INT_VEC2,
	Unsigned_Int_Vec3                         = gl.UNSIGNED_INT_VEC3,
	Unsigned_Int_Vec4                         = gl.UNSIGNED_INT_VEC4,

	Bool                                      = gl.BOOL,
	Bool_Vec2                                 = gl.BOOL_VEC2,
	Bool_Vec3                                 = gl.BOOL_VEC3,
	Bool_Vec4                                 = gl.BOOL_VEC4,

	Float_Mat2                                = gl.FLOAT_MAT2,
	Float_Mat3                                = gl.FLOAT_MAT3,
	Float_Mat4                                = gl.FLOAT_MAT4,
	Float_Mat2x3                              = gl.FLOAT_MAT2x3,
	Float_Mat2x4                              = gl.FLOAT_MAT2x4,
	Float_Mat3x2                              = gl.FLOAT_MAT3x2,
	Float_Mat3x4                              = gl.FLOAT_MAT3x4,
	Float_Mat4x2                              = gl.FLOAT_MAT4x2,
	Float_Mat4x3                              = gl.FLOAT_MAT4x3,

	Double_Mat2                               = gl.DOUBLE_MAT2,
	Double_Mat3                               = gl.DOUBLE_MAT3,
	Double_Mat4                               = gl.DOUBLE_MAT4,
	Double_Mat2x3                             = gl.DOUBLE_MAT2x3,
	Double_Mat2x4                             = gl.DOUBLE_MAT2x4,
	Double_Mat3x2                             = gl.DOUBLE_MAT3x2,
	Double_Mat3x4                             = gl.DOUBLE_MAT3x4,
	Double_Mat4x2                             = gl.DOUBLE_MAT4x2,
	Double_Mat4x3                             = gl.DOUBLE_MAT4x3,

	Sampler_1D                                = gl.SAMPLER_1D,
	Sampler_2D                                = gl.SAMPLER_2D,
	Sampler_3D                                = gl.SAMPLER_3D,
	Sampler_Cube                              = gl.SAMPLER_CUBE,
	Sampler_1D_Shadow                         = gl.SAMPLER_1D_SHADOW,
	Sampler_2D_Shadow                         = gl.SAMPLER_2D_SHADOW,
	Sampler_1D_Array                          = gl.SAMPLER_1D_ARRAY,
	Sampler_2D_Array                          = gl.SAMPLER_2D_ARRAY,
	Sampler_1D_Array_Shadow                   = gl.SAMPLER_1D_ARRAY_SHADOW,
	Sampler_2D_Array_Shadow                   = gl.SAMPLER_2D_ARRAY_SHADOW,
	Sampler_2D_Multisample                    = gl.SAMPLER_2D_MULTISAMPLE,
	Sampler_2D_Multisample_Array              = gl.SAMPLER_2D_MULTISAMPLE_ARRAY,
	Sampler_Cube_Shadow                       = gl.SAMPLER_CUBE_SHADOW,
	Sampler_Buffer                            = gl.SAMPLER_BUFFER,
	Sampler_2D_Rect                           = gl.SAMPLER_2D_RECT,
	Sampler_2D_Rect_Shadow                    = gl.SAMPLER_2D_RECT_SHADOW,

	Int_Sampler_1D                            = gl.INT_SAMPLER_1D,
	Int_Sampler_2D                            = gl.INT_SAMPLER_2D,
	Int_Sampler_3D                            = gl.INT_SAMPLER_3D,
	Int_Sampler_Cube                          = gl.INT_SAMPLER_CUBE,
	Int_Sampler_1D_Array                      = gl.INT_SAMPLER_1D_ARRAY,
	Int_Sampler_2D_Array                      = gl.INT_SAMPLER_2D_ARRAY,
	Int_Sampler_2D_Multisample                = gl.INT_SAMPLER_2D_MULTISAMPLE,
	Int_Sampler_2D_Multisample_Array          = gl.INT_SAMPLER_2D_MULTISAMPLE_ARRAY,
	Int_Sampler_Buffer                        = gl.INT_SAMPLER_BUFFER,
	Int_Sampler_2D_Rect                       = gl.INT_SAMPLER_2D_RECT,

	Unsigned_Int_Sampler_1D                   = gl.UNSIGNED_INT_SAMPLER_1D,
	Unsigned_Int_Sampler_2D                   = gl.UNSIGNED_INT_SAMPLER_2D,
	Unsigned_Int_Sampler_3D                   = gl.UNSIGNED_INT_SAMPLER_3D,
	Unsigned_Int_Sampler_Cube                 = gl.UNSIGNED_INT_SAMPLER_CUBE,
	Unsigned_Int_Sampler_1D_Array             = gl.UNSIGNED_INT_SAMPLER_1D_ARRAY,
	Unsigned_Int_Sampler_2D_Array             = gl.UNSIGNED_INT_SAMPLER_2D_ARRAY,
	Unsigned_Int_Sampler_2D_Multisample       = gl.UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE,
	Unsigned_Int_Sampler_2D_Multisample_Array = gl.UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY,
	Unsigned_Int_Sampler_Buffer               = gl.UNSIGNED_INT_SAMPLER_BUFFER,
	Unsigned_Int_Sampler_2D_Rect              = gl.UNSIGNED_INT_SAMPLER_2D_RECT,

	Image_1D                                  = gl.IMAGE_1D,
	Image_2D                                  = gl.IMAGE_2D,
	Image_3D                                  = gl.IMAGE_3D,
	Image_2D_Rect                             = gl.IMAGE_2D_RECT,
	Image_Cube                                = gl.IMAGE_CUBE,
	Image_Buffer                              = gl.IMAGE_BUFFER,
	Image_1D_Array                            = gl.IMAGE_1D_ARRAY,
	Image_2D_Array                            = gl.IMAGE_2D_ARRAY,
	Image_2D_Multisample                      = gl.IMAGE_2D_MULTISAMPLE,
	Image_2D_Multisample_Array                = gl.IMAGE_2D_MULTISAMPLE_ARRAY,

	Int_Image_1D                              = gl.INT_IMAGE_1D,
	Int_Image_2D                              = gl.INT_IMAGE_2D,
	Int_Image_3D                              = gl.INT_IMAGE_3D,
	Int_Image_2D_Rect                         = gl.INT_IMAGE_2D_RECT,
	Int_Image_Cube                            = gl.INT_IMAGE_CUBE,
	Int_Image_Buffer                          = gl.INT_IMAGE_BUFFER,
	Int_Image_1D_Array                        = gl.INT_IMAGE_1D_ARRAY,
	Int_Image_2D_Array                        = gl.INT_IMAGE_2D_ARRAY,
	Int_Image_2D_Multisample                  = gl.INT_IMAGE_2D_MULTISAMPLE,
	Int_Image_2D_Multisample_Array            = gl.INT_IMAGE_2D_MULTISAMPLE_ARRAY,

	Unsigned_Int_Image_1D                     = gl.UNSIGNED_INT_IMAGE_1D,
	Unsigned_Int_Image_2D                     = gl.UNSIGNED_INT_IMAGE_2D,
	Unsigned_Int_Image_3D                     = gl.UNSIGNED_INT_IMAGE_3D,
	Unsigned_Int_Image_2D_Rect                = gl.UNSIGNED_INT_IMAGE_2D_RECT,
	Unsigned_Int_Image_Cube                   = gl.UNSIGNED_INT_IMAGE_CUBE,
	Unsigned_Int_Image_Buffer                 = gl.UNSIGNED_INT_IMAGE_BUFFER,
	Unsigned_Int_Image_1D_Array               = gl.UNSIGNED_INT_IMAGE_1D_ARRAY,
	Unsigned_Int_Image_2D_Array               = gl.UNSIGNED_INT_IMAGE_2D_ARRAY,
	Unsigned_Int_Image_2D_Multisample         = gl.UNSIGNED_INT_IMAGE_2D_MULTISAMPLE,
	Unsigned_Int_Image_2D_Multisample_Array   = gl.UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY,

	Unsigned_Int_Atomic_Counter               = gl.UNSIGNED_INT_ATOMIC_COUNTER,
}

/* void GetActiveUniformsiv(uint program, sizei uniformCount, const uint *uniformIndices, enum pname, int *params); */
Active_Uniform_Parameter :: enum u32 {
	Uniform_Type                        = gl.UNIFORM_TYPE,
	Uniform_Size                        = gl.UNIFORM_SIZE,
	Uniform_Name_Length                 = gl.UNIFORM_NAME_LENGTH,
	Uniform_Block_Index                 = gl.UNIFORM_BLOCK_INDEX,
	Uniform_Offset                      = gl.UNIFORM_OFFSET,
	Uniform_Array_Stride                = gl.UNIFORM_ARRAY_STRIDE,
	Uniform_Matrix_Stride               = gl.UNIFORM_MATRIX_STRIDE,
	Uniform_Is_Row_Major                = gl.UNIFORM_IS_ROW_MAJOR,
	Uniform_Atomic_Counter_Buffer_Index = gl.UNIFORM_ATOMIC_COUNTER_BUFFER_INDEX,
}

/* void GetActiveUniformBlockiv(uint program, uint uniformBlockIndex, enum pname, int *params); */
Active_Uniform_Block_Parameter :: enum u32 {
	Uniform_Block_Binding                              = gl.UNIFORM_BLOCK_BINDING,
	Uniform_Block_Data_Size                            = gl.UNIFORM_BLOCK_DATA_SIZE,
	Uniform_Block_Name_Length                          = gl.UNIFORM_BLOCK_NAME_LENGTH,
	Uniform_Block_Active_Uniforms                      = gl.UNIFORM_BLOCK_ACTIVE_UNIFORMS,
	Uniform_Block_Active_Uniform_Indices               = gl.UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES,
	Uniform_Block_Referenced_By_Vertex_Shader          = gl.UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER,
	Uniform_Block_Referenced_By_Tess_Control_Shader    = gl.UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER,
	Uniform_Block_Referenced_By_Tess_Evaluation_Shader = gl.UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER,
	Uniform_Block_Referenced_By_Geometry_Shader        = gl.UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER,
	Uniform_Block_Referenced_By_Fragment_Shader        = gl.UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER,
	Uniform_Block_Referenced_By_Compute_Shader         = gl.UNIFORM_BLOCK_REFERENCED_BY_COMPUTE_SHADER,
}

/* void GetActiveAtomicCounterBufferiv(uint program, uint bufferIndex, enum pname, int *params); */
Active_Atomic_Counter_Buffer_Parameter :: enum u32 {
	Atomic_Counter_Buffer_Binding                              = gl.ATOMIC_COUNTER_BUFFER_BINDING,
	Atomic_Counter_Buffer_Data_Size                            = gl.ATOMIC_COUNTER_BUFFER_DATA_SIZE,
	Atomic_Counter_Buffer_Active_Atomic_Counters               = gl.ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTERS,
	Atomic_Counter_Buffer_Active_Atomic_Counter_Indices        = gl.ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTER_INDICES,
	Atomic_Counter_Buffer_Referenced_By_Vertex_Shader          = gl.ATOMIC_COUNTER_BUFFER_REFERENCED_BY_VERTEX_SHADER,
	Atomic_Counter_Buffer_Referenced_By_Tess_Control_Shader    = gl.ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_CONTROL_SHADER,
	Atomic_Counter_Buffer_Referenced_By_Tess_Evaluation_Shader = gl.ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_EVALUATION_SHADER,
	Atomic_Counter_Buffer_Referenced_By_Geometry_Shader        = gl.ATOMIC_COUNTER_BUFFER_REFERENCED_BY_GEOMETRY_SHADER,
	Atomic_Counter_Buffer_Referenced_By_Fragment_Shader        = gl.ATOMIC_COUNTER_BUFFER_REFERENCED_BY_FRAGMENT_SHADER,
	Atomic_Counter_Buffer_Referenced_By_Compute_Shader         = gl.ATOMIC_COUNTER_BUFFER_REFERENCED_BY_COMPUTE_SHADER,
}


/* Subroutine Uniform Variables [7.9] */

/* int GetSubroutineUniformLocation(uint program, enum shadertype, const char *name); */
// TODO(tarik): See comment on _Shader_Type. Probably should be using Shader_Type from helpers.odin here.
Subroutine_Uniform_Shader_Type :: enum u32 {
	Compute_Shader         = gl.COMPUTE_SHADER,
	Fragment_Shader        = gl.FRAGMENT_SHADER,
	Geometry_Shader        = gl.GEOMETRY_SHADER,
	Vertex_Shader          = gl.VERTEX_SHADER,
	Tess_Evaluation_Shader = gl.TESS_EVALUATION_SHADER,
	Tess_Control_Shader    = gl.TESS_CONTROL_SHADER,
}

/* uint GetSubroutineIndex(uint program, enum shadertype, const char *name); */
// TODO(tarik): See comment on _Shader_Type. Probably should be using Shader_Type from helpers.odin here.
// shadertype: Subroutine_Uniform_Shader_Type

/* void GetActiveSubroutineName(uint program, enum shadertype, uint index, sizei bufsize, sizei *length, char *name); */
// TODO(tarik): See comment on _Shader_Type. Probably should be using Shader_Type from helpers.odin here.
// shadertype: Subroutine_Uniform_Shader_Type

/* void GetActiveSubroutineUniformName(uint program, enum shadertype, uint index, sizei bufsize, sizei *length, char *name); */
// TODO(tarik): See comment on _Shader_Type. Probably should be using Shader_Type from helpers.odin here.
// shadertype: Subroutine_Uniform_Shader_Type

/* void GetActiveSubroutineUniformiv(uint program, enum shadertype, uint index, enum pname, int *values); */
// TODO(tarik): See comment on _Shader_Type. Probably should be using Shader_Type from helpers.odin here.
// shadertype: Subroutine_Uniform_Shader_Type

Active_Subroutine_Uniform_Parameter :: enum u32 {
	Compatible_Subroutines     = gl.COMPATIBLE_SUBROUTINES,
	Num_Compatible_Subroutines = gl.NUM_COMPATIBLE_SUBROUTINES,

	// NOTE(tarik): These shouldn't exist according to Quick Reference Card
	//              or the specification on page 156, but should exist
	//              according to page 620 of specification.
	Uniform_Size               = gl.UNIFORM_SIZE,
	Uniform_Name_Length        = gl.UNIFORM_NAME_LENGTH,

}

/* void UniformSubroutinesuiv(enum shadertype, sizei count, const uint *indices); */
// shadertype: Subroutine_Uniform_Shader_Type


/* Shader Memory Access [7.12.2] */

/* void MemoryBarrier(bitfield barriers); */
Memory_Barrier_Bits :: enum u32 {
	Vertex_Attrib_Array_Barrier_Bit  = gl.VERTEX_ATTRIB_ARRAY_BARRIER_BIT,
	Element_Array_Barrier_Bit        = gl.ELEMENT_ARRAY_BARRIER_BIT,
	Uniform_Barrier_Bit              = gl.UNIFORM_BARRIER_BIT,
	Texture_Fetch_Barrier_Bit        = gl.TEXTURE_FETCH_BARRIER_BIT,
	Shader_Image_Access_Barrier_Bit  = gl.SHADER_IMAGE_ACCESS_BARRIER_BIT,
	Command_Barrier_Bit              = gl.COMMAND_BARRIER_BIT,
	Pixel_Buffer_Barrier_Bit         = gl.PIXEL_BUFFER_BARRIER_BIT,
	Texture_Update_Barrier_Bit       = gl.TEXTURE_UPDATE_BARRIER_BIT,
	Buffer_Update_Barrier_Bit        = gl.BUFFER_UPDATE_BARRIER_BIT,
	Client_Mapped_Buffer_Barrier_Bit = gl.CLIENT_MAPPED_BUFFER_BARRIER_BIT,
	Query_Buffer_Barrier_Bit         = gl.QUERY_BUFFER_BARRIER_BIT,
	Framebuffer_Barrier_Bit          = gl.FRAMEBUFFER_BARRIER_BIT,
	Transform_Feedback_Barrier_Bit   = gl.TRANSFORM_FEEDBACK_BARRIER_BIT,
	Atomic_Counter_Barrier_Bit       = gl.ATOMIC_COUNTER_BARRIER_BIT,
	Shader_Storage_Barrier_Bit       = gl.SHADER_STORAGE_BARRIER_BIT,

	All_Barrier_Bits                 = gl.ALL_BARRIER_BITS,
}

/* void MemoryBarrierByRegion(bitfield barriers); */
Memory_Barrier_By_Region_Bits :: enum u32 {
	Atomic_Counter_Barrier_Bit      = gl.ATOMIC_COUNTER_BARRIER_BIT,
	Framebuffer_Barrier_Bit         = gl.FRAMEBUFFER_BARRIER_BIT,
	Shader_Image_Access_Barrier_Bit = gl.SHADER_IMAGE_ACCESS_BARRIER_BIT,
	Shader_Storage_Barrier_Bit      = gl.SHADER_STORAGE_BARRIER_BIT,
	Texture_Fetch_Barrier_Bit       = gl.TEXTURE_FETCH_BARRIER_BIT,
	Uniform_Barrier_Bit             = gl.UNIFORM_BARRIER_BIT,

	All_Barrier_Bits                = gl.ALL_BARRIER_BITS,
}


/* Shader and Program Queries [7.13] */

/* void GetShaderiv(uint shader, enum pname, int *params); */
Get_Shader_Parameter :: enum u32 {
	Shader_Type          = gl.SHADER_TYPE,
	Delete_Status        = gl.DELETE_STATUS,
	Compile_Status       = gl.COMPILE_STATUS,
	Info_Log_Length      = gl.INFO_LOG_LENGTH,
	Shader_Source_Length = gl.SHADER_SOURCE_LENGTH,
	SPIR_V_Binary        = gl.SPIR_V_BINARY,

	// TODO(tarik): Exists on Quick Reference Card, but not Specification.
	//              See pages 167, 612.
	// Compute_Shader       = gl.COMPUTE_SHADER,
}

/* void GetProgramiv(uint program, enum pname, int *params); */
Get_Program_Parameter :: enum u32 {
	Delete_Status                         = gl.DELETE_STATUS,
	Link_Status                           = gl.LINK_STATUS,
	Validate_Status                       = gl.VALIDATE_STATUS,
	Info_Log_Length                       = gl.INFO_LOG_LENGTH,
	Attached_Shaders                      = gl.ATTACHED_SHADERS,
	Active_Attributes                     = gl.ACTIVE_ATTRIBUTES,
	Active_Attribute_Max_Length           = gl.ACTIVE_ATTRIBUTE_MAX_LENGTH,
	Active_Uniforms                       = gl.ACTIVE_UNIFORMS,
	Active_Uniform_Max_Length             = gl.ACTIVE_UNIFORM_MAX_LENGTH,
	Transform_Feedback_Buffer_Mode        = gl.TRANSFORM_FEEDBACK_BUFFER_MODE,
	Transform_Feedback_Varyings           = gl.TRANSFORM_FEEDBACK_VARYINGS,
	Transform_Feedback_Varying_Max_Length = gl.TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH,
	Active_Uniform_Blocks                 = gl.ACTIVE_UNIFORM_BLOCKS,
	Active_Uniform_Block_Max_Name_Length  = gl.ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH,
	Geometry_Vertices_Out                 = gl.GEOMETRY_VERTICES_OUT,
	Geometry_Input_Type                   = gl.GEOMETRY_INPUT_TYPE,
	Geometry_Output_Type                  = gl.GEOMETRY_OUTPUT_TYPE,
	Geometry_Shader_Invocations           = gl.GEOMETRY_SHADER_INVOCATIONS,
	Tess_Control_Output_Vertices          = gl.TESS_CONTROL_OUTPUT_VERTICES,
	Tess_Gen_Mode                         = gl.TESS_GEN_MODE,
	Tess_Gen_Spacing                      = gl.TESS_GEN_SPACING,
	Tess_Gen_Vertex_Order                 = gl.TESS_GEN_VERTEX_ORDER,
	Tess_Gen_Point_Mode                   = gl.TESS_GEN_POINT_MODE,
	Compute_Work_Group_Size               = gl.COMPUTE_WORK_GROUP_SIZE,
	Program_Separable                     = gl.PROGRAM_SEPARABLE,
	Program_Binary_Retrievable_Hint       = gl.PROGRAM_BINARY_RETRIEVABLE_HINT,
	Active_Atomic_Counter_Buffers         = gl.ACTIVE_ATOMIC_COUNTER_BUFFERS,

	// NOTE(tarik): This was not listed under the command description.
	// However at other places, this usage was shown (p. 131 of specification).
	Program_Binary_Length                 = gl.PROGRAM_BINARY_LENGTH,
}

/* void GetProgramPipelineiv(uint pipeline, enum pname, int *params); */
Program_Pipeline_Parameter :: enum u32 {
	Active_Program         = gl.ACTIVE_PROGRAM,
	Vertex_Shader          = gl.VERTEX_SHADER,
	Tess_Control_Shader    = gl.TESS_CONTROL_SHADER,
	Tess_Evaluation_Shader = gl.TESS_EVALUATION_SHADER,
	Geometry_Shader        = gl.GEOMETRY_SHADER,
	Fragment_Shader        = gl.FRAGMENT_SHADER,
	Compute_Shader         = gl.COMPUTE_SHADER,
	Validate_Status        = gl.VALIDATE_STATUS,
	Info_Log_Length        = gl.INFO_LOG_LENGTH,
}

/* void GetShaderPrecisionFormat(enum shadertype, enum precisiontype, int *range, int *precision); */
Shader_Precision_Format_Shader_Type :: enum u32 {
	Vertex_Shader   = gl.VERTEX_SHADER,
	Fragment_Shader = gl.FRAGMENT_SHADER,
}

Shader_Precision_Type :: enum u32 {
	Low_Float    = gl.LOW_FLOAT,
	Medium_Float = gl.MEDIUM_FLOAT,
	High_Float   = gl.HIGH_FLOAT,
	Low_Int      = gl.LOW_INT,
	Medium_Int   = gl.MEDIUM_INT,
	High_Int     = gl.HIGH_INT,
}

/* void GetUniformSubroutineuiv(enum shadertype, int location, uint *params); */
// shadertype: Subroutine_Uniform_Shader_Type

/* GetProgramStageiv(uint program, enum shadertype, enum pname, int *values); */
// shadertype: Subroutine_Uniform_Shader_Type

Program_Stage_Parameter :: enum u32 {
	Active_Subroutine_Uniform_Locations  = gl.ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS,
	Active_Subroutine_Uniforms           = gl.ACTIVE_SUBROUTINE_UNIFORMS,
	Active_Subroutines                   = gl.ACTIVE_SUBROUTINES,
	Active_Subroutine_Uniform_Max_Length = gl.ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH,
	Active_Subroutine_Max_Length         = gl.ACTIVE_SUBROUTINE_MAX_LENGTH,
}
