package ngl

import gl "vendor:OpenGL"

aliased_line_width_range :: proc "contextless" () -> (lo, hi: i32) {
	arr: [2]i32 = ---
	gl.GetIntegerv(gl.ALIASED_LINE_WIDTH_RANGE, raw_data(&arr))
	lo = arr[0]
	hi = arr[1]
	return
}

blend_enabled :: proc "contextless" () -> (res: bool) {
    gl.GetBooleanv(gl.BLEND, &res)
    return
}
