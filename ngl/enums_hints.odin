package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_hints.odin

/* void Hint(enum target, enum hint); */
Hint_Target :: enum u32 {
	Line_Smooth_Hint                = gl.LINE_SMOOTH_HINT,
	Polygon_Smooth_Hint             = gl.POLYGON_SMOOTH_HINT,
	Texture_Compression_Hint        = gl.TEXTURE_COMPRESSION_HINT,
	Fragment_Shader_Derivative_Hint = gl.FRAGMENT_SHADER_DERIVATIVE_HINT,
}

Hint_Mode :: enum u32 {
	Fastest   = gl.FASTEST,
	Nicest    = gl.NICEST,
	Dont_Care = gl.DONT_CARE,
}
