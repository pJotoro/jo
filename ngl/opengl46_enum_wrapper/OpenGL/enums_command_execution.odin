package vendor_gl

/* OpenGL Errors [2.3.1] */

/* enum GetError(void); */
Error :: enum u32 {
	No_Error                      = NO_ERROR,
	Context_Lost                  = CONTEXT_LOST,
	Invalid_Enum                  = INVALID_ENUM,
	Invalid_Value                 = INVALID_VALUE,
	Invalid_Operation             = INVALID_OPERATION,
	Invalid_Framebuffer_Operation = INVALID_FRAMEBUFFER_OPERATION,
	Out_Of_Memory                 = OUT_OF_MEMORY,
	Stack_Overflow                = STACK_OVERFLOW,
	Stack_Underflow               = STACK_UNDERFLOW,
}


/* Graphics Reset Recovery [2.3.2] */

/* enum GetGraphicsResetStatus(void); */
Graphics_Reset_Status :: enum u32 {
	No_Error               = NO_ERROR,
	Guilty_Context_Reset   = GUILTY_CONTEXT_RESET,
	Innocent_Context_Reset = INNOCENT_CONTEXT_RESET,
	Unknown_Context_Reset  = UNKNOWN_CONTEXT_RESET,
}
