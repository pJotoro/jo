package ngl

import gl "vendor:OpenGL"
import "core:mem"

flush_mapped_buffer_range :: proc "contextless" (buffer: Buffer, offset, length: int) {
	gl.impl_FlushMappedNamedBufferRange(u32(buffer), offset, length)
}

delete_buffers :: proc "contextless" (buffers: []Buffer) {
	gl.impl_DeleteBuffers(i32(len(buffers)), ([^]u32)(raw_data(buffers)))
}

gen_buffers :: proc "contextless" (buffers: []Buffer) {
	gl.impl_CreateBuffers(i32(len(buffers)), ([^]u32)(raw_data(buffers)))
}

is_buffer :: proc "contextless" (buffer: u32) -> bool {
	return gl.impl_IsBuffer(buffer)
}

buffer_data :: proc "contextless" (buffer: Buffer, data: []byte, usage: Buffer_Data_Usage) {
	gl.impl_NamedBufferData(u32(buffer), len(data), raw_data(data), u32(usage))
}

buffer_sub_data :: proc "contextless" (buffer: Buffer, offset: int, data: []byte) {
	gl.impl_NamedBufferSubData(u32(buffer), offset, len(data), raw_data(data))
}

get_buffer_sub_data :: proc "contextless" (buffer: Buffer, offset: int, data: []byte) {
	gl.impl_GetNamedBufferSubData(u32(buffer), offset, len(data), raw_data(data))
}

map_buffer :: proc "contextless" (buffer: Buffer, offset, length: int, access: Access_Bits) -> []byte {
	data: mem.Raw_Slice
	data.len = length
	data.data = gl.impl_MapNamedBufferRange(u32(buffer), offset, length, u32(access))
	return transmute([]byte)data
}

unmap_buffer :: proc "contextless" (buffer: Buffer) {
	gl.impl_UnmapNamedBuffer(u32(buffer))
}

get_buffer_pointer :: proc "contextless" (buffer: Buffer) -> (pointer: rawptr) {
	gl.impl_GetNamedBufferPointerv(u32(buffer), gl.BUFFER_MAP_POINTER, &pointer)
	return
}

get_buffer_access :: proc "contextless" (buffer: Buffer) -> Access_Bits {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_ACCESS, &p)
    return Access_Bits(p)
}

get_buffer_immutable_storage :: proc "contextless" (buffer: Buffer) -> bool {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_IMMUTABLE_STORAGE, &p)
    return bool(p)
}

get_buffer_mapped :: proc "contextless" (buffer: Buffer) -> bool {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_MAPPED, &p)
    return bool(p)
}

get_buffer_map_length :: proc "contextless" (buffer: Buffer) -> i64 {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_MAP_LENGTH, &p)
    return p
}

get_buffer_map_offset :: proc "contextless" (buffer: Buffer) -> i64 {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_MAP_OFFSET, &p)
    return p
}

get_buffer_size :: proc "contextless" (buffer: Buffer) -> i64 {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_SIZE, &p)
    return p
}

get_buffer_storage_flags :: proc "contextless" (buffer: Buffer) -> Buffer_Storage_Bits {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_STORAGE_FLAGS, &p)
    return Buffer_Storage_Bits(p)
}

get_buffer_usage :: proc "contextless" (buffer: Buffer) -> Buffer_Data_Usage {
    p: i64
    gl.impl_GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_USAGE, &p)
    return Buffer_Data_Usage(p)
}

copy_buffer_sub_data :: proc "contextless" (read_buffer, write_buffer: Buffer, read_offset, write_offset, size: int) {
	gl.impl_CopyNamedBufferSubData(u32(read_buffer), u32(write_buffer), read_offset, write_offset, size)
}