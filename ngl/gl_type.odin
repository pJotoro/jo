package ngl

import gl "vendor:OpenGL"

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