package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_buffer_objects.odin

/* Create and Bind Buffer Objects [6.1] */

/* void BindBuffer(enum target, uint buffer); */
Buffer_Binding_Target :: enum u32 {
	Array_Buffer              = gl.ARRAY_BUFFER,
	Uniform_Buffer            = gl.UNIFORM_BUFFER,
	Atomic_Counter_Buffer     = gl.ATOMIC_COUNTER_BUFFER,
	Query_Buffer              = gl.QUERY_BUFFER,
	Copy_Read_Buffer          = gl.COPY_READ_BUFFER,
	Copy_Write_Buffer         = gl.COPY_WRITE_BUFFER,
	Dispatch_Indirect_Buffer  = gl.DISPATCH_INDIRECT_BUFFER,
	Draw_Indirect_Buffer      = gl.DRAW_INDIRECT_BUFFER,
	Element_Array_Buffer      = gl.ELEMENT_ARRAY_BUFFER,
	Texture_Buffer            = gl.TEXTURE_BUFFER,
	Pixel_Pack_Buffer         = gl.PIXEL_PACK_BUFFER,
	Pixel_Unpack_Buffer       = gl.PIXEL_UNPACK_BUFFER,
	Parameter_Buffer          = gl.PARAMETER_BUFFER,
	Shader_Storage_Buffer     = gl.SHADER_STORAGE_BUFFER,
	Transform_Feedback_Buffer = gl.TRANSFORM_FEEDBACK_BUFFER,
}

/* void BindBufferRange(enum target, uint index, uint buffer, intptr offset, sizeiptr size); */
Buffer_Binding_Indexed_Target :: enum u32 {
	Atomic_Counter_Buffer     = gl.ATOMIC_COUNTER_BUFFER,
	Shader_Storage_Buffer     = gl.SHADER_STORAGE_BUFFER,
	Uniform_Buffer            = gl.UNIFORM_BUFFER,
	Transform_Feedback_Buffer = gl.TRANSFORM_FEEDBACK_BUFFER,
}

/* void BindBufferBase(enum target, uint index, uint buffer); */
// target: Buffer_Binding_Indexed_Target

/* void BindBuffersRange(enum target, uint first, sizei count, const uint *buffers, const intptr *offsets, const sizeiptr *size); */
// target: Buffer_Binding_Indexed_Target

/* void BindBuffersBase(enum target, uint first, sizei count, const uint *buffers); */
// target: Buffer_Binding_Indexed_Target


/* Create/Modify Buffer Object Data [6.2] */

/* void BufferStorage(enum target, sizeiptr size, const void *data, bitfield flags); */
// target: Buffer_Binding_Target

Buffer_Storage_Bits :: enum u32 {
	Map_Read_Bit        = gl.MAP_READ_BIT,
	Map_Write_Bit       = gl.MAP_WRITE_BIT,
	Dynamic_Storage_Bit = gl.DYNAMIC_STORAGE_BIT,
	Client_Storage_Bit  = gl.CLIENT_STORAGE_BIT,
	Map_Coherent_Bit    = gl.MAP_COHERENT_BIT,
	Map_Persistent_Bit  = gl.MAP_PERSISTENT_BIT,
}

/* void NamedBufferStorage(uint buffer, sizeiptr size, const void *data, bitfield flags); */
// flags: Buffer_Storage_Bits

/* void BufferData(enum target, sizeiptr size, const void *data, enum usage); */
// target: Buffer_Binding_Target

Buffer_Data_Usage :: enum u32 {
	Dynamic_Draw = gl.DYNAMIC_DRAW,
	Dynamic_Read = gl.DYNAMIC_READ,
	Dynamic_Copy = gl.DYNAMIC_COPY,
	Static_Draw  = gl.STATIC_DRAW,
	Static_Read  = gl.STATIC_READ,
	Static_Copy  = gl.STATIC_COPY,
	Stream_Draw  = gl.STREAM_DRAW,
	Stream_Read  = gl.STREAM_READ,
	Stream_Copy  = gl.STREAM_COPY,
}

/* void NamedBufferData(uint buffer, sizeiptr size, const void *data, enum usage); */
// usage: Buffer_Data_Usage

/* void BufferSubData(enum target, intptr offset, sizeiptr size, const void *data); */
// target: Buffer_Binding_Target

/* void ClearBufferSubData(enum target, enum internalFormat, intptr offset, sizeiptr size, enum format, enum type, const void *data); */
// target: Buffer_Binding_Target

Buffer_Internalformat :: enum u32 {
	R8       = gl.R8,
	R8i      = gl.R8I,
	R8ui     = gl.R8UI,
	R16      = gl.R16,
	R16F     = gl.R16F,
	R16i     = gl.R16I,
	R16ui    = gl.R16UI,
	R32F     = gl.R32F,
	R32i     = gl.R32I,
	R32ui    = gl.R32UI,
	RG8      = gl.RG8,
	RG8i     = gl.RG8I,
	RG8ui    = gl.RG8UI,
	RG16     = gl.RG16,
	RG16F    = gl.RG16F,
	RG16i    = gl.RG16I,
	RG16ui   = gl.RG16UI,
	RG32F    = gl.RG32F,
	RG32i    = gl.RG32I,
	RG32ui   = gl.RG32UI,
	RGB32F   = gl.RGB32F,
	RGB32i   = gl.RGB32I,
	RGB32ui  = gl.RGB32UI,
	RGBA8    = gl.RGBA8,
	RGBA8i   = gl.RGBA8I,
	RGBA8ui  = gl.RGBA8UI,
	RGBA16   = gl.RGBA16,
	RGBA16F  = gl.RGBA16F,
	RGBA16i  = gl.RGBA16I,
	RGBA16ui = gl.RGBA16UI,
	RGBA32F  = gl.RGBA32F,
	RGBA32i  = gl.RGBA32I,
	RGBA32ui = gl.RGBA32UI,
}

Buffer_Format :: enum u32 {
	Red             = gl.RED,
	Green           = gl.GREEN,
	Blue            = gl.BLUE,
	RG              = gl.RG,
	RGB             = gl.RGB,
	RGBA            = gl.RGBA,
	BGR             = gl.BGR,
	BGRA            = gl.BGRA,
	Red_Integer     = gl.RED_INTEGER,
	Green_Integer   = gl.GREEN_INTEGER,
	Blue_Integer    = gl.BLUE_INTEGER,
	RG_Integer      = gl.RG_INTEGER,
	RGB_Integer     = gl.RGB_INTEGER,
	RGBA_Integer    = gl.RGBA_INTEGER,
	BGR_Integer     = gl.BGR_INTEGER,
	BGRA_Integer    = gl.BGRA_INTEGER,
	Stencil_Index   = gl.STENCIL_INDEX,
	Depth_Component = gl.DEPTH_COMPONENT,
	Depth_Stencil   = gl.DEPTH_STENCIL,
}

//TODO(tarik): Duplicate of Pixel_Data_Type (other file)
Buffer_Type :: enum u32 {
	Unsigned_Byte                  = gl.UNSIGNED_BYTE,
	Byte                           = gl.BYTE,
	Unsigned_Short                 = gl.UNSIGNED_SHORT,
	Short                          = gl.SHORT,
	Unsigned_Int                   = gl.UNSIGNED_INT,
	Int                            = gl.INT,
	Half_Float                     = gl.HALF_FLOAT,
	Float                          = gl.FLOAT,
	Unsigned_Byte_3_3_2            = gl.UNSIGNED_BYTE_3_3_2,
	Unsigned_Byte_2_3_3_Rev        = gl.UNSIGNED_BYTE_2_3_3_REV,
	Unsigned_Short_5_6_5           = gl.UNSIGNED_SHORT_5_6_5,
	Unsigned_Short_5_6_5_Rev       = gl.UNSIGNED_SHORT_5_6_5_REV,
	Unsigned_Short_4_4_4_4         = gl.UNSIGNED_SHORT_4_4_4_4,
	Unsigned_Short_4_4_4_4_Rev     = gl.UNSIGNED_SHORT_4_4_4_4_REV,
	Unsigned_Short_5_5_5_1         = gl.UNSIGNED_SHORT_5_5_5_1,
	Unsigned_Short_1_5_5_5_Rev     = gl.UNSIGNED_SHORT_1_5_5_5_REV,
	Unsigned_Int_8_8_8_8           = gl.UNSIGNED_INT_8_8_8_8,
	Unsigned_Int_8_8_8_8_Rev       = gl.UNSIGNED_INT_8_8_8_8_REV,
	Unsigned_Int_10_10_10_2        = gl.UNSIGNED_INT_10_10_10_2,
	Unsigned_Int_2_10_10_10_Rev    = gl.UNSIGNED_INT_2_10_10_10_REV,
	Unsigned_Int_24_8              = gl.UNSIGNED_INT_24_8,
	Unsigned_Int_10f_11f_11f_Rev   = gl.UNSIGNED_INT_10F_11F_11F_REV,
	Unsigned_Int_5_9_9_9_Rev       = gl.UNSIGNED_INT_5_9_9_9_REV,
	Float_32_Unsigned_Int_24_8_Rev = gl.FLOAT_32_UNSIGNED_INT_24_8_REV,
}

/* void ClearNamedBufferSubData(uint buffer, enum internalformat, intptr offset, sizeiptr size, enum format, enum type, const void *data); */
// internalformat: Buffer_Internalformat
// format:         Buffer_Format
// type:           Buffer_Type

/* void ClearBufferData(enum target, enum internalformat, enum format, enum type, const void *data); */
// target:         Buffer_Binding_Target
// internalformat: Buffer_Internalformat
// format:         Buffer_Format
// type:           Buffer_Type

/* void ClearNamedBufferData(uint buffer, enum internalformat, enum format, enum type, const void *data); */
// internalformat: Buffer_Internalformat
// format:         Buffer_Format
// type:           Buffer_Type


/* Map/Unmap Buffer Data [6.3] */

/* void *MapBufferRange(enum target, intptr offset, sizeiptr length, bitfield access); */
// target: Buffer_Binding_Target

Access_Bits :: enum u32 {
	Map_Read_Bit              = gl.MAP_READ_BIT,
	Map_Write_Bit             = gl.MAP_WRITE_BIT,
	Map_Persistent_Bit        = gl.MAP_PERSISTENT_BIT,
	Map_Coherent_Bit          = gl.MAP_COHERENT_BIT,
	Map_Invalidate_Buffer_Bit = gl.MAP_INVALIDATE_BUFFER_BIT,
	Map_Invalidate_Range_Bit  = gl.MAP_INVALIDATE_RANGE_BIT,
	Map_Flush_Explicit_Bit    = gl.MAP_FLUSH_EXPLICIT_BIT,
	Map_Unsynchronized_Bit    = gl.MAP_UNSYNCHRONIZED_BIT,
}

/* void *MapNamedBufferRange(uint buffer, intptr offset, sizeiptr length, bitfield access); */
// access: Access_Bits

/* void *MapBuffer(enum target, enum access); */
// target: Buffer_Binding_Target

Access :: enum u32 {
	Read_Only  = gl.READ_ONLY,
	Write_Only = gl.WRITE_ONLY,
	Read_Write = gl.READ_WRITE,
}

/* void *MapNamedBuffer(uint buffer, enum access); */
// access: Access

/* boolean UnmapBuffer(enum target); */
// target: Buffer_Binding_Target


/* Buffer Object Queries [6, 6.7] */

/* void GetBufferSubData(enum target, intptr offset, sizeiptr size, void *data); */
// target: Buffer_Binding_Target

/* void GetBufferParameteriv(enum target, enum pname, int*data); */
// target: Buffer_Binding_Target

Buffer_Parameter :: enum u32 {
	Buffer_Size              = gl.BUFFER_SIZE,
	Buffer_Usage             = gl.BUFFER_USAGE,
	Buffer_Access            = gl.BUFFER_ACCESS,
	Buffer_Access_Flags      = gl.BUFFER_ACCESS_FLAGS,
	Buffer_Mapped            = gl.BUFFER_MAPPED,
	Buffer_Map_Offset        = gl.BUFFER_MAP_OFFSET,
	Buffer_Map_Length        = gl.BUFFER_MAP_LENGTH,
	Buffer_Immutable_Storage = gl.BUFFER_IMMUTABLE_STORAGE,
}

/* void GetBufferParameteri64v(enum target, enum pname, int64*data); */
// target: Buffer_Binding_Target
// pname: Buffer_Parameter

/* void GetNamedBufferParameteriv(uint buffer, enum pname, int*data); */
// pname: Buffer_Parameter

/* void GetNamedBufferParameteri64v(uint buffer, enum pname, int64*data); */
// pname: Buffer_Parameter

/* void GetBufferPointerv(enum target, enum pname, const void **params); */
// target: Buffer_Binding_Target

Buffer_Pointer_Parameter :: enum u32 {
	Buffer_Map_Pointer = gl.BUFFER_MAP_POINTER,
}

/* void GetNamedBufferPointerv(uint buffer, enum pname, const void **params); */
// pname: Buffer_Pointer_Parameter


/* Copy Between Buffers [6.6] */

/* void CopyBufferSubData(enum readTarget, enum writeTarget, intptr readOffset, intptr writeOffset, sizeiptr size); */
// readTarget:  Buffer_Binding_Target
// writeTarget: Buffer_Binding_Target
