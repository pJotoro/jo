package ngl

import gl "vendor:OpenGL"

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
