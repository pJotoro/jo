package app

rgba_to_bgr_u8 :: #force_inline proc "contextless" (r, g, b, a: u8) -> (bgr: u32) {
    src_r := f32(r) / 255.0
    src_g := f32(g) / 255.0
    src_b := f32(b) / 255.0
    src_a := f32(a) / 255.0

    /*
    Target.R = 1 - Source.A + (Source.A * Source.R)
    Target.G = 1 - Source.A + (Source.A * Source.G)
    Target.B = 1 - Source.A + (Source.A * Source.B)
    */

    dst_r := 1 - src_a + (src_a * src_r)
    dst_g := 1 - src_a + (src_a * src_g)
    dst_b := 1 - src_a + (src_a * src_b)

    dst_r_u32 := u32(dst_r * 255)
    dst_g_u32 := u32(dst_g * 255)
    dst_b_u32 := u32(dst_b * 255)

    bgr = (dst_r_u32 << 16) | (dst_g_u32 << 8) | (dst_b_u32)
    return
}

rgba_to_bgr_u32 :: #force_inline proc "contextless" (rgba: u32) -> (bgr: u32) {
    r := u8((rgba & 0x000000FF) >> 0)
    g := u8((rgba & 0x0000FF00) >> 8)
    b := u8((rgba & 0x00FF0000) >> 16)
    a := u8((rgba & 0xFF000000) >> 24)
    bgr = rgba_to_bgr_u8(r, g, b, a)
    return
}

rgba_to_bgr :: proc {
    rgba_to_bgr_u8,
    rgba_to_bgr_u32,
}