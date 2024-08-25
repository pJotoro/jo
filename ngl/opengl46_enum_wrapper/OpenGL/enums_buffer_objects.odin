package vendor_gl

/* Create and Bind Buffer Objects [6.1] */

/* void BindBuffer(enum target, uint buffer); */
Buffer_Binding_Target :: enum u32 {
	Array_Buffer              = ARRAY_BUFFER,
	Uniform_Buffer            = UNIFORM_BUFFER,
	Atomic_Counter_Buffer     = ATOMIC_COUNTER_BUFFER,
	Query_Buffer              = QUERY_BUFFER,
	Copy_Read_Buffer          = COPY_READ_BUFFER,
	Copy_Write_Buffer         = COPY_WRITE_BUFFER,
	Dispatch_Indirect_Buffer  = DISPATCH_INDIRECT_BUFFER,
	Draw_Indirect_Buffer      = DRAW_INDIRECT_BUFFER,
	Element_Array_Buffer      = ELEMENT_ARRAY_BUFFER,
	Texture_Buffer            = TEXTURE_BUFFER,
	Pixel_Pack_Buffer         = PIXEL_PACK_BUFFER,
	Pixel_Unpack_Buffer       = PIXEL_UNPACK_BUFFER,
	Parameter_Buffer          = PARAMETER_BUFFER,
	Shader_Storage_Buffer     = SHADER_STORAGE_BUFFER,
	Transform_Feedback_Buffer = TRANSFORM_FEEDBACK_BUFFER,
}

/* void BindBufferRange(enum target, uint index, uint buffer, intptr offset, sizeiptr size); */
Buffer_Binding_Indexed_Target :: enum u32 {
	Atomic_Counter_Buffer     = ATOMIC_COUNTER_BUFFER,
	Shader_Storage_Buffer     = SHADER_STORAGE_BUFFER,
	Uniform_Buffer            = UNIFORM_BUFFER,
	Transform_Feedback_Buffer = TRANSFORM_FEEDBACK_BUFFER,
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

Buffer_Storage_Flag :: enum u32 {
	Map_Read        = 0, // MAP_READ_BIT        :: 0x0001
	Map_Write       = 1, // MAP_WRITE_BIT       :: 0x0002
	Map_Persistent  = 6, // MAP_PERSISTENT_BIT  :: 0x0040
	Map_Coherent    = 7, // MAP_COHERENT_BIT    :: 0x0080
	Dynamic_Storage = 8, // DYNAMIC_STORAGE_BIT :: 0x0100
	Client_Storage  = 9, // CLIENT_STORAGE_BIT  :: 0x0200
}

Buffer_Storage_Flags :: bit_set[Buffer_Storage_Flag; u32]

/* void NamedBufferStorage(uint buffer, sizeiptr size, const void *data, bitfield flags); */
// flags: Buffer_Storage_Flags

/* void BufferData(enum target, sizeiptr size, const void *data, enum usage); */
// target: Buffer_Binding_Target

Buffer_Data_Usage :: enum u32 {
	Dynamic_Draw = DYNAMIC_DRAW,
	Dynamic_Read = DYNAMIC_READ,
	Dynamic_Copy = DYNAMIC_COPY,
	Static_Draw  = STATIC_DRAW,
	Static_Read  = STATIC_READ,
	Static_Copy  = STATIC_COPY,
	Stream_Draw  = STREAM_DRAW,
	Stream_Read  = STREAM_READ,
	Stream_Copy  = STREAM_COPY,
}

/* void NamedBufferData(uint buffer, sizeiptr size, const void *data, enum usage); */
// usage: Buffer_Data_Usage

/* void BufferSubData(enum target, intptr offset, sizeiptr size, const void *data); */
// target: Buffer_Binding_Target

/* void ClearBufferSubData(enum target, enum internalFormat, intptr offset, sizeiptr size, enum format, enum type, const void *data); */
// target: Buffer_Binding_Target

Buffer_Internalformat :: enum u32 {
	R8       = R8,
	R8i      = R8I,
	R8ui     = R8UI,
	R16      = R16,
	R16F     = R16F,
	R16i     = R16I,
	R16ui    = R16UI,
	R32F     = R32F,
	R32i     = R32I,
	R32ui    = R32UI,
	RG8      = RG8,
	RG8i     = RG8I,
	RG8ui    = RG8UI,
	RG16     = RG16,
	RG16F    = RG16F,
	RG16i    = RG16I,
	RG16ui   = RG16UI,
	RG32F    = RG32F,
	RG32i    = RG32I,
	RG32ui   = RG32UI,
	RGB32F   = RGB32F,
	RGB32i   = RGB32I,
	RGB32ui  = RGB32UI,
	RGBA8    = RGBA8,
	RGBA8i   = RGBA8I,
	RGBA8ui  = RGBA8UI,
	RGBA16   = RGBA16,
	RGBA16F  = RGBA16F,
	RGBA16i  = RGBA16I,
	RGBA16ui = RGBA16UI,
	RGBA32F  = RGBA32F,
	RGBA32i  = RGBA32I,
	RGBA32ui = RGBA32UI,
}

Buffer_Format :: enum u32 {
	Red             = RED,
	Green           = GREEN,
	Blue            = BLUE,
	RG              = RG,
	RGB             = RGB,
	RGBA            = RGBA,
	BGR             = BGR,
	BGRA            = BGRA,
	Red_Integer     = RED_INTEGER,
	Green_Integer   = GREEN_INTEGER,
	Blue_Integer    = BLUE_INTEGER,
	RG_Integer      = RG_INTEGER,
	RGB_Integer     = RGB_INTEGER,
	RGBA_Integer    = RGBA_INTEGER,
	BGR_Integer     = BGR_INTEGER,
	BGRA_Integer    = BGRA_INTEGER,
	Stencil_Index   = STENCIL_INDEX,
	Depth_Component = DEPTH_COMPONENT,
	Depth_Stencil   = DEPTH_STENCIL,
}

Buffer_Type :: Pixel_Data_Type

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

Access_Flag :: enum u32 {
	Map_Read              = 0, // MAP_READ_BIT              :: 0x0001
	Map_Write             = 1, // MAP_WRITE_BIT             :: 0x0002
	Map_Persistent        = 2, // MAP_INVALIDATE_RANGE_BIT  :: 0x0004
	Map_Coherent          = 3, // MAP_INVALIDATE_BUFFER_BIT :: 0x0008
	Map_Invalidate_Buffer = 4, // MAP_FLUSH_EXPLICIT_BIT    :: 0x0010
	Map_Invalidate_Range  = 5, // MAP_UNSYNCHRONIZED_BIT    :: 0x0020
	Map_Flush_Explicit    = 6, // MAP_PERSISTENT_BIT        :: 0x0040
	Map_Unsynchronized    = 7, // MAP_COHERENT_BIT          :: 0x0080
}

Access_Flags :: bit_set[Access_Flag; u32]

/* void *MapNamedBufferRange(uint buffer, intptr offset, sizeiptr length, bitfield access); */
// access: Access_Flags

/* void *MapBuffer(enum target, enum access); */
// target: Buffer_Binding_Target

Access :: enum u32 {
	Read_Only  = READ_ONLY,
	Write_Only = WRITE_ONLY,
	Read_Write = READ_WRITE,
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
	Buffer_Size              = BUFFER_SIZE,
	Buffer_Usage             = BUFFER_USAGE,
	Buffer_Access            = BUFFER_ACCESS,
	Buffer_Access_Flags      = BUFFER_ACCESS_FLAGS,
	Buffer_Mapped            = BUFFER_MAPPED,
	Buffer_Map_Offset        = BUFFER_MAP_OFFSET,
	Buffer_Map_Length        = BUFFER_MAP_LENGTH,
	Buffer_Immutable_Storage = BUFFER_IMMUTABLE_STORAGE,
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
	Buffer_Map_Pointer = BUFFER_MAP_POINTER,
}

/* void GetNamedBufferPointerv(uint buffer, enum pname, const void **params); */
// pname: Buffer_Pointer_Parameter


/* Copy Between Buffers [6.6] */

/* void CopyBufferSubData(enum readTarget, enum writeTarget, intptr readOffset, intptr writeOffset, sizeiptr size); */
// readTarget:  Buffer_Binding_Target
// writeTarget: Buffer_Binding_Target
