package ngl

import gl "vendor:OpenGL"

/* OpenGL Errors [2.3.1] */

/* enum GetError(void); */
Error :: enum u32 {
	No_Error                      = gl.NO_ERROR,
	Context_Lost                  = gl.CONTEXT_LOST,
	Invalid_Enum                  = gl.INVALID_ENUM,
	Invalid_Value                 = gl.INVALID_VALUE,
	Invalid_Operation             = gl.INVALID_OPERATION,
	Invalid_Framebuffer_Operation = gl.INVALID_FRAMEBUFFER_OPERATION,
	Out_Of_Memory                 = gl.OUT_OF_MEMORY,
	Stack_Overflow                = gl.STACK_OVERFLOW,
	Stack_Underflow               = gl.STACK_UNDERFLOW,
}


/* Graphics Reset Recovery [2.3.2] */

/* enum GetGraphicsResetStatus(void); */
Graphics_Reset_Status :: enum u32 {
	No_Error               = gl.NO_ERROR,
	Guilty_Context_Reset   = gl.GUILTY_CONTEXT_RESET,
	Innocent_Context_Reset = gl.INNOCENT_CONTEXT_RESET,
	Unknown_Context_Reset  = gl.UNKNOWN_CONTEXT_RESET,
}
