package vendor_gl

/* Multisample Fragment Ops. [17.3.3] */

/* void SampleMaski(uint maskNumber, bitfield mask); */
// NOTE: bitfield mask is unimplemented

/* void StencilFunc(enum func, int ref, uint mask); */
Comparison_Func :: enum u32 {
	Never     = NEVER,
	Always    = ALWAYS,
	Less      = LESS,
	Lequal    = LEQUAL,
	Equal     = EQUAL,
	Gequal    = GEQUAL,
	Greater   = GREATER,
	Not_Equal = NOTEQUAL,
}

/* void StencilFuncSeparate(enum face, enum func, int ref, uint mask); */
// func: Comparison_Func
Stencil_Face :: enum u32 {
	Front          = FRONT,
	Back           = BACK,
	Front_And_Back = FRONT_AND_BACK,
}

/* void StencilOp(enum sfail, enum dpfail, enum dppass); */
Stencil_Operation :: enum u32 {
	Keep      = KEEP,
	Zero      = ZERO,
	Replace   = REPLACE,
	Incr      = INCR,
	Decr      = DECR,
	INVERT    = INVERT,
	Incr_Wrap = INCR_WRAP,
	Decr_Wrap = DECR_WRAP,
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
	Func_Add              = FUNC_ADD,
	Func_Subtract         = FUNC_SUBTRACT,
	Func_Reverse_Subtract = FUNC_REVERSE_SUBTRACT,
	Min                   = MIN,
	Max                   = MAX,
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
	Zero                     = ZERO,
	One                      = ONE,
	Src_Color                = SRC_COLOR,
	One_Minus_Src_Color      = ONE_MINUS_SRC_COLOR,
	Dst_Color                = DST_COLOR,
	One_Minus_Dst_Color      = ONE_MINUS_DST_COLOR,
	Src_Alpha                = SRC_ALPHA,
	One_Minus_Src_Alpha      = ONE_MINUS_SRC_ALPHA,
	Dst_Alpha                = DST_ALPHA,
	One_Minus_Dst_Alpha      = ONE_MINUS_DST_ALPHA,
	Constant_Color           = CONSTANT_COLOR,
	One_Minus_Constant_Color = ONE_MINUS_CONSTANT_COLOR,
	Constant_Alpha           = CONSTANT_ALPHA,
	One_Minus_Constant_Alpha = ONE_MINUS_CONSTANT_ALPHA,
	Src_Alpha_Saturate       = SRC_ALPHA_SATURATE,
	Src1_Color               = SRC1_COLOR,
	One_Minus_Src1_Color     = ONE_MINUS_SRC1_COLOR,
	Src1_Alpha               = SRC1_ALPHA,
	One_Minus_Src1_Alpha     = ONE_MINUS_SRC1_ALPHA,
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
	Clear         = CLEAR,
	Set           = SET,
	Copy          = COPY,
	Copy_Inverted = COPY_INVERTED,
	Noop          = NOOP,
	Invert        = INVERT,
	And           = AND,
	Nand          = NAND,
	Or            = OR,
	Nor           = NOR,
	Xor           = XOR,
	Equiv         = EQUIV,
	And_Reverse   = AND_REVERSE,
	And_Inverted  = AND_INVERTED,
	Or_Reverse    = OR_REVERSE,
	Or_Inverted   = OR_INVERTED,
}
