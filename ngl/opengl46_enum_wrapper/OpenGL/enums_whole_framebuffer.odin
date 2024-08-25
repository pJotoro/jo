package vendor_gl

/* Selecting Buffers for Writing [17.4.1] */

/* void DrawBuffer(enum buf); */
Draw_Buffer :: enum u32 {
	None               = NONE,
	Front_Left         = FRONT_LEFT,
	Front_Right        = FRONT_RIGHT,
	Back_Left          = BACK_LEFT,
	Back_Right         = BACK_RIGHT,
	Front              = FRONT,
	Back               = BACK,
	Left               = LEFT,
	Right              = RIGHT,
	Front_And_Back     = FRONT_AND_BACK,

	Color_Attachment0  = COLOR_ATTACHMENT0,
	Color_Attachment1  = COLOR_ATTACHMENT1,
	Color_Attachment2  = COLOR_ATTACHMENT2,
	Color_Attachment3  = COLOR_ATTACHMENT3,
	Color_Attachment4  = COLOR_ATTACHMENT4,
	Color_Attachment5  = COLOR_ATTACHMENT5,
	Color_Attachment6  = COLOR_ATTACHMENT6,
	Color_Attachment7  = COLOR_ATTACHMENT7,
	Color_Attachment8  = COLOR_ATTACHMENT8,
	Color_Attachment9  = COLOR_ATTACHMENT9,
	Color_Attachment10 = COLOR_ATTACHMENT10,
	Color_Attachment11 = COLOR_ATTACHMENT11,
	Color_Attachment12 = COLOR_ATTACHMENT12,
	Color_Attachment13 = COLOR_ATTACHMENT13,
	Color_Attachment14 = COLOR_ATTACHMENT14,
	Color_Attachment15 = COLOR_ATTACHMENT15,
	Color_Attachment16 = COLOR_ATTACHMENT16,
	Color_Attachment17 = COLOR_ATTACHMENT17,
	Color_Attachment18 = COLOR_ATTACHMENT18,
	Color_Attachment19 = COLOR_ATTACHMENT19,
	Color_Attachment20 = COLOR_ATTACHMENT20,
	Color_Attachment21 = COLOR_ATTACHMENT21,
	Color_Attachment22 = COLOR_ATTACHMENT22,
	Color_Attachment23 = COLOR_ATTACHMENT23,
	Color_Attachment24 = COLOR_ATTACHMENT24,
	Color_Attachment25 = COLOR_ATTACHMENT25,
	Color_Attachment26 = COLOR_ATTACHMENT26,
	Color_Attachment27 = COLOR_ATTACHMENT27,
	Color_Attachment28 = COLOR_ATTACHMENT28,
	Color_Attachment29 = COLOR_ATTACHMENT29,
	Color_Attachment30 = COLOR_ATTACHMENT30,
	Color_Attachment31 = COLOR_ATTACHMENT31,
}

/* void NamedFramebufferDrawBuffer(uint framebuffer, enum buf); */
// buf: Draw_Buffer

/* void DrawBuffers(sizei n, const enum *bufs); */
Draw_Buffers :: enum u32 {
	None               = NONE,
	Front_Left         = FRONT_LEFT,
	Front_Right        = FRONT_RIGHT,
	Back_Left          = BACK_LEFT,
	Back_Right         = BACK_RIGHT,

	Color_Attachment0  = COLOR_ATTACHMENT0,
	Color_Attachment1  = COLOR_ATTACHMENT1,
	Color_Attachment2  = COLOR_ATTACHMENT2,
	Color_Attachment3  = COLOR_ATTACHMENT3,
	Color_Attachment4  = COLOR_ATTACHMENT4,
	Color_Attachment5  = COLOR_ATTACHMENT5,
	Color_Attachment6  = COLOR_ATTACHMENT6,
	Color_Attachment7  = COLOR_ATTACHMENT7,
	Color_Attachment8  = COLOR_ATTACHMENT8,
	Color_Attachment9  = COLOR_ATTACHMENT9,
	Color_Attachment10 = COLOR_ATTACHMENT10,
	Color_Attachment11 = COLOR_ATTACHMENT11,
	Color_Attachment12 = COLOR_ATTACHMENT12,
	Color_Attachment13 = COLOR_ATTACHMENT13,
	Color_Attachment14 = COLOR_ATTACHMENT14,
	Color_Attachment15 = COLOR_ATTACHMENT15,
	Color_Attachment16 = COLOR_ATTACHMENT16,
	Color_Attachment17 = COLOR_ATTACHMENT17,
	Color_Attachment18 = COLOR_ATTACHMENT18,
	Color_Attachment19 = COLOR_ATTACHMENT19,
	Color_Attachment20 = COLOR_ATTACHMENT20,
	Color_Attachment21 = COLOR_ATTACHMENT21,
	Color_Attachment22 = COLOR_ATTACHMENT22,
	Color_Attachment23 = COLOR_ATTACHMENT23,
	Color_Attachment24 = COLOR_ATTACHMENT24,
	Color_Attachment25 = COLOR_ATTACHMENT25,
	Color_Attachment26 = COLOR_ATTACHMENT26,
	Color_Attachment27 = COLOR_ATTACHMENT27,
	Color_Attachment28 = COLOR_ATTACHMENT28,
	Color_Attachment29 = COLOR_ATTACHMENT29,
	Color_Attachment30 = COLOR_ATTACHMENT30,
	Color_Attachment31 = COLOR_ATTACHMENT31,
}

/* void NamedFramebufferDrawBuffers(uint framebuffer, sizei n, const enum *bufs); */
// bufs: Draw_Buffers


/* Fine Control of Buffer Updates [17.4.2] */

/* void StencilMaskSeparate(enum face, uint mask); */
// face: Stencil_Face


/* Clearing the Buffers [17.4.3] */

/* void Clear(bitfield buf); */
Buffer_Flag :: enum u32 {
	Depth_Buffer   = 8,  // DEPTH_BUFFER_BIT   :: 0x00000100,
	Stencil_Buffer = 10, // STENCIL_BUFFER_BIT :: 0x00000400,
	Color_Buffer   = 14, // COLOR_BUFFER_BIT   :: 0x00004000,
}

Clear_Mask :: bit_set[Buffer_Flag; u32]

/* void ClearBufferiv(enum buffer, int drawbuffer, const T *value); */
Clear_Bufferiv :: enum u32 {
	Color   = COLOR,
	Stencil = STENCIL,
}

/* void ClearBufferfv(enum buffer, int drawbuffer, const T *value); */
Clear_Bufferfv :: enum u32 {
	Color = COLOR,
	Depth = DEPTH,
}

/* void ClearBufferuiv(enum buffer, int drawbuffer, const T *value); */
Clear_Bufferuiv :: enum u32 {
	Color = COLOR,
}

/* void ClearNamedFramebufferiv(uint framebuffer, enum buffer, int drawbuffer, const T *value); */
// buffer: Clear_Bufferiv

/* void ClearNamedFramebufferfv(uint framebuffer, enum buffer, int drawbuffer, const T *value); */
// buffer: Clear_Bufferfv

/* void ClearNamedFramebufferuiv(uint framebuffer, enum buffer, int drawbuffer, const T *value); */
// buffer: Clear_Bufferuiv

/* void ClearBufferfi(enum buffer, int drawbuffer, float depth, int stencil); */
Clear_Bufferfi :: enum u32 {
	Depth_Stencil = DEPTH_STENCIL,
}

/* void ClearNamedFramebufferfi(uint framebuffer, enum buffer, int drawbuffer, float depth, int stencil); */
// buffer: Clear_Bufferfi


/* Invalidating Framebuffers [17.4.4] */

/* void InvalidateSubFramebuffer(enum target, sizei numAttachments, const enum *attachments, int x, int y, sizei width, sizei height); */
// target: Framebuffer_Target
Invalidate_Framebuffer_Attachment :: enum u32 {
	Front                    = FRONT,
	Front_Left               = FRONT_LEFT,
	Front_Right              = FRONT_RIGHT,
	Back                     = BACK,
	Back_Left                = BACK_LEFT,
	Back_Right               = BACK_RIGHT,
	Depth                    = DEPTH,
	Stencil                  = STENCIL,

	Depth_Attachment         = DEPTH_ATTACHMENT,
	Stencil_Attachment       = STENCIL_ATTACHMENT,
	Depth_Stencil_Attachment = DEPTH_STENCIL_ATTACHMENT,
	Color_Attachment0        = COLOR_ATTACHMENT0,
	Color_Attachment1        = COLOR_ATTACHMENT1,
	Color_Attachment2        = COLOR_ATTACHMENT2,
	Color_Attachment3        = COLOR_ATTACHMENT3,
	Color_Attachment4        = COLOR_ATTACHMENT4,
	Color_Attachment5        = COLOR_ATTACHMENT5,
	Color_Attachment6        = COLOR_ATTACHMENT6,
	Color_Attachment7        = COLOR_ATTACHMENT7,
	Color_Attachment8        = COLOR_ATTACHMENT8,
	Color_Attachment9        = COLOR_ATTACHMENT9,
	Color_Attachment10       = COLOR_ATTACHMENT10,
	Color_Attachment11       = COLOR_ATTACHMENT11,
	Color_Attachment12       = COLOR_ATTACHMENT12,
	Color_Attachment13       = COLOR_ATTACHMENT13,
	Color_Attachment14       = COLOR_ATTACHMENT14,
	Color_Attachment15       = COLOR_ATTACHMENT15,
	Color_Attachment16       = COLOR_ATTACHMENT16,
	Color_Attachment17       = COLOR_ATTACHMENT17,
	Color_Attachment18       = COLOR_ATTACHMENT18,
	Color_Attachment19       = COLOR_ATTACHMENT19,
	Color_Attachment20       = COLOR_ATTACHMENT20,
	Color_Attachment21       = COLOR_ATTACHMENT21,
	Color_Attachment22       = COLOR_ATTACHMENT22,
	Color_Attachment23       = COLOR_ATTACHMENT23,
	Color_Attachment24       = COLOR_ATTACHMENT24,
	Color_Attachment25       = COLOR_ATTACHMENT25,
	Color_Attachment26       = COLOR_ATTACHMENT26,
	Color_Attachment27       = COLOR_ATTACHMENT27,
	Color_Attachment28       = COLOR_ATTACHMENT28,
	Color_Attachment29       = COLOR_ATTACHMENT29,
	Color_Attachment30       = COLOR_ATTACHMENT30,
	Color_Attachment31       = COLOR_ATTACHMENT31,
}

/* void InvalidateNamedFramebufferSubData(uint framebuffer, sizei numAttachments, const enum *attachments, int x, int y, sizei width, sizei height); */
// attachments: Invalidate_Framebuffer_Attachment

/* void InvalidateFramebuffer(enum target, sizei numAttachments, const enum *attachments); */
// target: Framebuffer_Target
// attachments: Invalidate_Framebuffer_Attachment

/* void InvalidateNamedFramebufferData(uint framebuffer, sizei numAttachments, const enum *attachments); */
// attachments: Invalidate_Framebuffer_Attachment
