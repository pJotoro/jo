package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_per_fragment_operations.odin

/* Multisample Fragment Ops. [17.3.3] */

/* void SampleMaski(uint maskNumber, bitfield mask); */
// NOTE(tarik): bitfield mask is unimplemented

/* void StencilFunc(enum func, int ref, uint mask); */
Comparison_Func :: enum u32 {
	Never     = gl.NEVER,
	Always    = gl.ALWAYS,
	Less      = gl.LESS,
	Lequal    = gl.LEQUAL,
	Equal     = gl.EQUAL,
	Gequal    = gl.GEQUAL,
	Greater   = gl.GREATER,
	Not_Equal = gl.NOTEQUAL,
}

/* void StencilFuncSeparate(enum face, enum func, int ref, uint mask); */
// func: Comparison_Func
Stencil_Face :: enum u32 {
	Front          = gl.FRONT,
	Back           = gl.BACK,
	Front_And_Back = gl.FRONT_AND_BACK,
}

/* void StencilOp(enum sfail, enum dpfail, enum dppass); */
Stencil_Operation :: enum u32 {
	Keep      = gl.KEEP,
	Zero      = gl.ZERO,
	Replace   = gl.REPLACE,
	Incr      = gl.INCR,
	Decr      = gl.DECR,
	INVERT    = gl.INVERT,
	Incr_Wrap = gl.INCR_WRAP,
	Decr_Wrap = gl.DECR_WRAP,
}

/* void StencilOpSeparate(enum face, enum sfail, enum dpfail, enum dppass); */
// face:   Stencil_Face
// sfail:  Stencil_Operation
// dpfail: Stencil_Operation
// dppass: Stencil_Operation


/* Depth Buffer Test [17.3.6] */

/* void DepthFunc(enum func); */
// func: Comparison_Func


/* Blending [17.3.8] */

/* void BlendEquation(enum mode); */
Blend_Mode :: enum u32 {
	Func_Add              = gl.FUNC_ADD,
	Func_Subtract         = gl.FUNC_SUBTRACT,
	Func_Reverse_Subtract = gl.FUNC_REVERSE_SUBTRACT,
	Min                   = gl.MIN,
	Max                   = gl.MAX,
}

/* void BlendEquationSeparate(enum modeRGB, enum modeAlpha); */
// modeRGB:  Blend_Mode
// modeAlpha Blend_Mode

/* void BlendEquationi(uint buf, enum mode); */
// mode: Blend_Mode

/* void BlendEquationSeparatei(uint buf, enum modeRGB, enum modeAlpha); */
// modeRGB:  Blend_Mode
// modeAlpha Blend_Mode

/* void BlendFunc(enum src, enum dst); */
// src: Blend_Function
// dst: Blend_Function
Blend_Function :: enum u32 {
	Zero                     = gl.ZERO,
	One                      = gl.ONE,
	Src_Color                = gl.SRC_COLOR,
	One_Minus_Src_Color      = gl.ONE_MINUS_SRC_COLOR,
	Dst_Color                = gl.DST_COLOR,
	One_Minus_Dst_Color      = gl.ONE_MINUS_DST_COLOR,
	Src_Alpha                = gl.SRC_ALPHA,
	One_Minus_Src_Alpha      = gl.ONE_MINUS_SRC_ALPHA,
	Dst_Alpha                = gl.DST_ALPHA,
	One_Minus_Dst_Alpha      = gl.ONE_MINUS_DST_ALPHA,
	Constant_Color           = gl.CONSTANT_COLOR,
	One_Minus_Constant_Color = gl.ONE_MINUS_CONSTANT_COLOR,
	Constant_Alpha           = gl.CONSTANT_ALPHA,
	One_Minus_Constant_Alpha = gl.ONE_MINUS_CONSTANT_ALPHA,
	Src_Alpha_Saturate       = gl.SRC_ALPHA_SATURATE,
	Src1_Color               = gl.SRC1_COLOR,
	One_Minus_Src1_Color     = gl.ONE_MINUS_SRC1_COLOR,
	Src1_Alpha               = gl.SRC1_ALPHA,
	One_Minus_Src1_Alpha     = gl.ONE_MINUS_SRC1_ALPHA,
}

/* void BlendFuncSeparate(enum srcRGB, enum dstRGB, enum srcAlpha, enum dstAlpha); */
// srcRGB:   Blend_Function
// dstRGB:   Blend_Function
// srcAlpha: Blend_Function
// dstAlpha: Blend_Function

/* void BlendFunci(uint buf, enum src, enum dst); */
// src: Blend_Function
// dst: Blend_Function

/* void BlendFuncSeparatei(uint buf, enum srcRGB, enum dstRGB, enum srcAlpha, enum dstAlpha); */
// srcRGB:   Blend_Function
// dstRGB:   Blend_Function
// srcAlpha: Blend_Function
// dstAlpha: Blend_Function


/* Logical Operation [17.3.11] */

/* void LogicOp(enum op); */
Logical_Operation :: enum u32 {
	Clear         = gl.CLEAR,
	Set           = gl.SET,
	Copy          = gl.COPY,
	Copy_Inverted = gl.COPY_INVERTED,
	Noop          = gl.NOOP,
	Invert        = gl.INVERT,
	And           = gl.AND,
	Nand          = gl.NAND,
	Or            = gl.OR,
	Nor           = gl.NOR,
	Xor           = gl.XOR,
	Equiv         = gl.EQUIV,
	And_Reverse   = gl.AND_REVERSE,
	And_Inverted  = gl.AND_INVERTED,
	Or_Reverse    = gl.OR_REVERSE,
	Or_Inverted   = gl.OR_INVERTED,
}
