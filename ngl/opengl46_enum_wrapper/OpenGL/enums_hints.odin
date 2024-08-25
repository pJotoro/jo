package vendor_gl

/* void Hint(enum target, enum hint); */
Hint_Target :: enum u32 {
	Line_Smooth_Hint                = LINE_SMOOTH_HINT,
	Polygon_Smooth_Hint             = POLYGON_SMOOTH_HINT,
	Texture_Compression_Hint        = TEXTURE_COMPRESSION_HINT,
	Fragment_Shader_Derivative_Hint = FRAGMENT_SHADER_DERIVATIVE_HINT,
}

Hint_Mode :: enum u32 {
	Fastest   = FASTEST,
	Nicest    = NICEST,
	Dont_Care = DONT_CARE,
}
