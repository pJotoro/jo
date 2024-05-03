package ngl

import gl "vendor:OpenGL"

gen_samplers :: proc "contextless" (samplers: []Sampler) {
    gl.impl_CreateSamplers(i32(len(samplers)), ([^]u32)(raw_data(samplers)))
}

delete_samplers :: proc "contextless" (samplers: []Sampler) {
	gl.impl_DeleteSamplers(i32(len(samplers)), ([^]u32)(raw_data(samplers)))
}

is_sampler :: proc "contextless" (sampler: u32) -> bool {
	return gl.impl_IsSampler(sampler)
}

bind_sampler :: proc "contextless" (unit: u32, sampler: Sampler) {
	gl.BindSampler(unit, u32(sampler))
}

sampler_min_filter :: proc "contextless" (sampler: Sampler, min_filter: Min_Filter) {
    gl.impl_SamplerParameteri(u32(sampler), gl.TEXTURE_MIN_FILTER, i32(min_filter))
}

sampler_mag_filter :: proc "contextless" (sampler: Sampler, mag_filter: Mag_Filter) {
    gl.impl_SamplerParameteri(u32(sampler), gl.TEXTURE_MAG_FILTER, i32(mag_filter))
}

sampler_min_lod :: proc "contextless" (sampler: Sampler, min_lod: f32) {
    gl.impl_SamplerParameterf(u32(sampler), gl.TEXTURE_MIN_LOD, min_lod)
}

sampler_max_lod :: proc "contextless" (sampler: Sampler, max_lod: f32) {
    gl.impl_SamplerParameterf(u32(sampler), gl.TEXTURE_MAX_LOD, max_lod)
}

Sampler_Wrap :: enum u32 {
    Clamp_To_Edge = gl.CLAMP_TO_EDGE,
    Mirrored_Repeat = gl.MIRRORED_REPEAT,
    Repeat = gl.REPEAT,
	Mirror_Clamp_To_Edge = gl.MIRROR_CLAMP_TO_EDGE,
}

sampler_wrap_s :: proc "contextless" (sampler: Sampler, wrap: Sampler_Wrap) {
    wrap := wrap
    gl.impl_SamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_S, (^u32)(&wrap))
}

sampler_wrap_t :: proc "contextless" (sampler: Sampler, wrap: Sampler_Wrap) {
    wrap := wrap
    gl.impl_SamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_T, (^u32)(&wrap))
}

sampler_wrap_r :: proc "contextless" (sampler: Sampler, wrap: Sampler_Wrap) {
    wrap := wrap
    gl.impl_SamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_R, (^u32)(&wrap))
}

sampler_border_color_f32 :: proc "contextless" (sampler: Sampler, r, g, b, a: f32) {
    params := [4]f32{r, g, b, a}
    gl.impl_SamplerParameterfv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&params))
}

sampler_border_color_i32 :: proc "contextless" (sampler: Sampler, r, g, b, a: i32) {
    params := [4]i32{r, g, b, a}
    gl.impl_SamplerParameteriv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&params))
}

sampler_border_color_u32 :: proc "contextless" (sampler: Sampler, r, g, b, a: u32) {
    params := [4]u32{r, g, b, a}
    gl.impl_SamplerParameterIuiv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&params))
}

sampler_border_color :: proc {
    sampler_border_color_f32,
    sampler_border_color_i32,
    sampler_border_color_u32,
}

sampler_compare_mode :: proc "contextless" (sampler: Sampler, compare_mode: Compare_Mode) {
    gl.impl_SamplerParameteri(u32(sampler), gl.TEXTURE_COMPARE_MODE, i32(compare_mode))
}

sampler_compare_func :: proc "contextless" (sampler: Sampler, compare_func: Comparison_Func) {
    compare_func := compare_func
    gl.impl_SamplerParameterIuiv(u32(sampler), gl.TEXTURE_COMPARE_FUNC, (^u32)(&compare_func))
}


get_sampler_min_filter :: proc "contextless" (sampler: Sampler) -> (min_filter: Min_Filter) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_MIN_FILTER, (^u32)(&min_filter))
    return
}

get_sampler_mag_filter :: proc "contextless" (sampler: Sampler) -> (mag_filter: Mag_Filter) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_MAG_FILTER, (^u32)(&mag_filter))
    return
}

get_sampler_min_lod :: proc "contextless" (sampler: Sampler) -> (min_lod: f32) {
    gl.impl_GetSamplerParameterfv(u32(sampler), gl.TEXTURE_MIN_LOD, (^f32)(&min_lod))
    return
}

get_sampler_max_lod :: proc "contextless" (sampler: Sampler) -> (max_lod: f32) {
    gl.impl_GetSamplerParameterfv(u32(sampler), gl.TEXTURE_MAX_LOD, (^f32)(&max_lod))
    return
}

get_sampler_wrap_s :: proc "contextless" (sampler: Sampler) -> (wrap: Sampler_Wrap) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_S, (^u32)(&wrap))
    return
}

get_sampler_wrap_t :: proc "contextless" (sampler: Sampler) -> (wrap: Sampler_Wrap) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_T, (^u32)(&wrap))
    return
}

get_sampler_wrap_r :: proc "contextless" (sampler: Sampler) -> (wrap: Sampler_Wrap) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_WRAP_R, (^u32)(&wrap))
    return
}

get_sampler_border_color_f32 :: proc "contextless" (sampler: Sampler) -> (r, g, b, a: f32) {
    res: [4]f32 = ---
    gl.impl_GetSamplerParameterfv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&res))
    r = res[0]
    g = res[1]
    b = res[2]
    a = res[3]
    return
}

get_sampler_border_color_i32 :: proc "contextless" (sampler: Sampler) -> (r, g, b, a: i32) {
    res: [4]i32 = ---
    gl.impl_GetSamplerParameteriv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&res))
    r = res[0]
    g = res[1]
    b = res[2]
    a = res[3]
    return
}

get_sampler_border_color_u32 :: proc "contextless" (sampler: Sampler) -> (r, g, b, a: u32) {
    res: [4]u32 = ---
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_BORDER_COLOR, raw_data(&res))
    r = res[0]
    g = res[1]
    b = res[2]
    a = res[3]
    return
}

get_sampler_compare_mode :: proc "contextless" (sampler: Sampler) -> (compare_mode: Compare_Mode) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_COMPARE_MODE, (^u32)(&compare_mode))
    return
}

get_sampler_compare_func :: proc "contextless" (sampler: Sampler) -> (compare_func: Comparison_Func) {
    gl.impl_GetSamplerParameterIuiv(u32(sampler), gl.TEXTURE_COMPARE_FUNC, (^u32)(&compare_func))
    return
}