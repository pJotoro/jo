package ngl

import gl "vendor:OpenGL"

sampler_min_filter :: proc "contextless" (sampler: Sampler, min_filter: Min_Filter) {
    gl.SamplerParameteri(u32(sampler), gl.TEXTURE_MIN_FILTER, i32(min_filter))
}

sampler_mag_filter :: proc "contextless" (sampler: Sampler, mag_filter: Mag_Filter) {
    gl.SamplerParameteri(u32(sampler), gl.TEXTURE_MAG_FILTER, i32(mag_filter))
}

sampler_min_lod :: proc "contextless" (sampler: Sampler, min_lod: f32) {
    gl.SamplerParameterf(u32(sampler), gl.TEXTURE_MIN_LOD, min_lod)
}

sampler_max_lod :: proc "contextless" (sampler: Sampler, max_lod: f32) {
    gl.SamplerParameterf(u32(sampler), gl.TEXTURE_MAX_LOD, max_lod)
}

Sampler_Wrap :: enum u32 {
    Clamp_To_Edge = gl.CLAMP_TO_EDGE,
    Mirrored_Repeat = gl.MIRRORED_REPEAT,
    Repeat = gl.REPEAT,
	Mirror_Clamp_To_Edge = gl.MIRROR_CLAMP_TO_EDGE,
}

sampler_wrap_s :: proc "contextless" (sampler: Sampler, wrap: Sampler_Wrap) {
    wrap := wrap
    gl.SamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_S, (^u32)(&wrap))
}

sampler_wrap_t :: proc "contextless" (sampler: Sampler, wrap: Sampler_Wrap) {
    wrap := wrap
    gl.SamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_T, (^u32)(&wrap))
}

sampler_wrap_r :: proc "contextless" (sampler: Sampler, wrap: Sampler_Wrap) {
    wrap := wrap
    gl.SamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_R, (^u32)(&wrap))
}

sampler_border_color_f32 :: proc "contextless" (sampler: Sampler, r, g, b, a: f32) {
    params := [4]f32{r, g, b, a}
    gl.SamplerParameterfv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&params))
}

sampler_border_color_i32 :: proc "contextless" (sampler: Sampler, r, g, b, a: i32) {
    params := [4]i32{r, g, b, a}
    gl.SamplerParameteriv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&params))
}

sampler_border_color_u32 :: proc "contextless" (sampler: Sampler, r, g, b, a: u32) {
    params := [4]u32{r, g, b, a}
    gl.SamplerParameterIuiv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&params))
}

sampler_border_color :: proc {
    sampler_border_color_f32,
    sampler_border_color_i32,
    sampler_border_color_u32,
}

sampler_compare_mode :: proc "contextless" (sampler: Sampler, compare_mode: Compare_Mode) {
    gl.SamplerParameteri(u32(sampler), gl.TEXTURE_COMPARE_MODE, i32(compare_mode))
}

sampler_compare_func :: proc "contextless" (sampler: Sampler, compare_func: Comparison_Func) {
    compare_func := compare_func
    gl.SamplerParameterIuiv(u32(sampler), gl.TEXTURE_COMPARE_FUNC, (^u32)(&compare_func))
}

