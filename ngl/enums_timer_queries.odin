package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_timer_queries.odin

Query_Counter_Target :: enum u32 {
	Timestamp = gl.TIMESTAMP,
}
