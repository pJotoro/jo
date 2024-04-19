package ngl

import gl "vendor:OpenGL"

get_buffer_access :: proc "contextless" (buffer: Buffer) -> Access_Bits {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_ACCESS, &p)
    return Access_Bits(p)
}

get_buffer_immutable_storage :: proc "contextless" (buffer: Buffer) -> bool {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_IMMUTABLE_STORAGE, &p)
    return bool(p)
}

get_buffer_mapped :: proc "contextless" (buffer: Buffer) -> bool {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_MAPPED, &p)
    return bool(p)
}

get_buffer_map_length :: proc "contextless" (buffer: Buffer) -> i64 {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_MAP_LENGTH, &p)
    return p
}

get_buffer_map_offset :: proc "contextless" (buffer: Buffer) -> i64 {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_MAP_OFFSET, &p)
    return p
}

get_buffer_size :: proc "contextless" (buffer: Buffer) -> i64 {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_SIZE, &p)
    return p
}

get_buffer_storage_flags :: proc "contextless" (buffer: Buffer) -> Buffer_Storage_Bits {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_STORAGE_FLAGS, &p)
    return Buffer_Storage_Bits(p)
}

get_buffer_usage :: proc "contextless" (buffer: Buffer) -> Buffer_Data_Usage {
    p: i64
    gl.GetNamedBufferParameteri64v(u32(buffer), gl.BUFFER_USAGE, &p)
    return Buffer_Data_Usage(p)
}