package ngl

import gl "vendor:OpenGL"





get_aliased_line_width_range :: proc "contextless" () -> (lo, hi: i32) {
	arr: [2]i32 = ---
	gl.GetIntegerv(gl.ALIASED_LINE_WIDTH_RANGE, raw_data(&arr))
	lo = arr[0]
	hi = arr[1]
	return
}

get_blend_enabled :: proc "contextless" () -> (res: bool) {
    gl.GetBooleanv(gl.BLEND, &res)
    return
}

get_blend_color :: proc "contextless" () -> (r, g, b, a: f32) {
    arr: [4]f32 = ---
    gl.GetFloatv(gl.BLEND_COLOR, raw_data(&arr))
    r = arr[0]
    g = arr[1]
    b = arr[2]
    a = arr[3]
    return
}