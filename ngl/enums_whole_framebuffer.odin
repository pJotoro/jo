package ngl

import gl "vendor:OpenGL"

/* Selecting Buffers for Writing [17.4.1] */

/* void DrawBuffer(enum buf); */
Draw_Buffer :: enum u32 {
	None               = gl.NONE,
	Front_Left         = gl.FRONT_LEFT,
	Front_Right        = gl.FRONT_RIGHT,
	Back_Left          = gl.BACK_LEFT,
	Back_Right         = gl.BACK_RIGHT,
	Front              = gl.FRONT,
	Back               = gl.BACK,
	Left               = gl.LEFT,
	Right              = gl.RIGHT,
	Front_And_Back     = gl.FRONT_AND_BACK,

	Color_Attachment0  = gl.COLOR_ATTACHMENT0,
	Color_Attachment1  = gl.COLOR_ATTACHMENT1,
	Color_Attachment2  = gl.COLOR_ATTACHMENT2,
	Color_Attachment3  = gl.COLOR_ATTACHMENT3,
	Color_Attachment4  = gl.COLOR_ATTACHMENT4,
	Color_Attachment5  = gl.COLOR_ATTACHMENT5,
	Color_Attachment6  = gl.COLOR_ATTACHMENT6,
	Color_Attachment7  = gl.COLOR_ATTACHMENT7,
	Color_Attachment8  = gl.COLOR_ATTACHMENT8,
	Color_Attachment9  = gl.COLOR_ATTACHMENT9,
	Color_Attachment10 = gl.COLOR_ATTACHMENT10,
	Color_Attachment11 = gl.COLOR_ATTACHMENT11,
	Color_Attachment12 = gl.COLOR_ATTACHMENT12,
	Color_Attachment13 = gl.COLOR_ATTACHMENT13,
	Color_Attachment14 = gl.COLOR_ATTACHMENT14,
	Color_Attachment15 = gl.COLOR_ATTACHMENT15,
	Color_Attachment16 = gl.COLOR_ATTACHMENT16,
	Color_Attachment17 = gl.COLOR_ATTACHMENT17,
	Color_Attachment18 = gl.COLOR_ATTACHMENT18,
	Color_Attachment19 = gl.COLOR_ATTACHMENT19,
	Color_Attachment20 = gl.COLOR_ATTACHMENT20,
	Color_Attachment21 = gl.COLOR_ATTACHMENT21,
	Color_Attachment22 = gl.COLOR_ATTACHMENT22,
	Color_Attachment23 = gl.COLOR_ATTACHMENT23,
	Color_Attachment24 = gl.COLOR_ATTACHMENT24,
	Color_Attachment25 = gl.COLOR_ATTACHMENT25,
	Color_Attachment26 = gl.COLOR_ATTACHMENT26,
	Color_Attachment27 = gl.COLOR_ATTACHMENT27,
	Color_Attachment28 = gl.COLOR_ATTACHMENT28,
	Color_Attachment29 = gl.COLOR_ATTACHMENT29,
	Color_Attachment30 = gl.COLOR_ATTACHMENT30,
	Color_Attachment31 = gl.COLOR_ATTACHMENT31,
}

/* void NamedFramebufferDrawBuffer(uint framebuffer, enum buf); */
// buf: Draw_Buffer

/* void DrawBuffers(sizei n, const enum *bufs); */
Draw_Buffers :: enum u32 {
	None               = gl.NONE,
	Front_Left         = gl.FRONT_LEFT,
	Front_Right        = gl.FRONT_RIGHT,
	Back_Left          = gl.BACK_LEFT,
	Back_Right         = gl.BACK_RIGHT,

	Color_Attachment0  = gl.COLOR_ATTACHMENT0,
	Color_Attachment1  = gl.COLOR_ATTACHMENT1,
	Color_Attachment2  = gl.COLOR_ATTACHMENT2,
	Color_Attachment3  = gl.COLOR_ATTACHMENT3,
	Color_Attachment4  = gl.COLOR_ATTACHMENT4,
	Color_Attachment5  = gl.COLOR_ATTACHMENT5,
	Color_Attachment6  = gl.COLOR_ATTACHMENT6,
	Color_Attachment7  = gl.COLOR_ATTACHMENT7,
	Color_Attachment8  = gl.COLOR_ATTACHMENT8,
	Color_Attachment9  = gl.COLOR_ATTACHMENT9,
	Color_Attachment10 = gl.COLOR_ATTACHMENT10,
	Color_Attachment11 = gl.COLOR_ATTACHMENT11,
	Color_Attachment12 = gl.COLOR_ATTACHMENT12,
	Color_Attachment13 = gl.COLOR_ATTACHMENT13,
	Color_Attachment14 = gl.COLOR_ATTACHMENT14,
	Color_Attachment15 = gl.COLOR_ATTACHMENT15,
	Color_Attachment16 = gl.COLOR_ATTACHMENT16,
	Color_Attachment17 = gl.COLOR_ATTACHMENT17,
	Color_Attachment18 = gl.COLOR_ATTACHMENT18,
	Color_Attachment19 = gl.COLOR_ATTACHMENT19,
	Color_Attachment20 = gl.COLOR_ATTACHMENT20,
	Color_Attachment21 = gl.COLOR_ATTACHMENT21,
	Color_Attachment22 = gl.COLOR_ATTACHMENT22,
	Color_Attachment23 = gl.COLOR_ATTACHMENT23,
	Color_Attachment24 = gl.COLOR_ATTACHMENT24,
	Color_Attachment25 = gl.COLOR_ATTACHMENT25,
	Color_Attachment26 = gl.COLOR_ATTACHMENT26,
	Color_Attachment27 = gl.COLOR_ATTACHMENT27,
	Color_Attachment28 = gl.COLOR_ATTACHMENT28,
	Color_Attachment29 = gl.COLOR_ATTACHMENT29,
	Color_Attachment30 = gl.COLOR_ATTACHMENT30,
	Color_Attachment31 = gl.COLOR_ATTACHMENT31,
}

/* void NamedFramebufferDrawBuffers(uint framebuffer, sizei n, const enum *bufs); */
// bufs: Draw_Buffers


/* Fine Control of Buffer Updates [17.4.2] */

/* void StencilMaskSeparate(enum face, uint mask); */
// face: Stencil_Face


/* Clearing the Buffers [17.4.3] */

/* void Clear(bitfield buf); */
Clear_Bits :: enum u32 {
	Color_Buffer_Bit   = gl.COLOR_BUFFER_BIT,
	Depth_Buffer_Bit   = gl.DEPTH_BUFFER_BIT,
	Stencil_Buffer_Bit = gl.STENCIL_BUFFER_BIT,
}

/* void ClearBufferiv(enum buffer, int drawbuffer, const T *value); */
Clear_Bufferiv :: enum u32 {
	Color   = gl.COLOR,
	Stencil = gl.STENCIL,
}

/* void ClearBufferfv(enum buffer, int drawbuffer, const T *value); */
Clear_Bufferfv :: enum u32 {
	Color = gl.COLOR,
	Depth = gl.DEPTH,
}

/* void ClearBufferuiv(enum buffer, int drawbuffer, const T *value); */
Clear_Bufferuiv :: enum u32 {
	Color = gl.COLOR,
}

/* void ClearNamedFramebufferiv(uint framebuffer, enum buffer, int drawbuffer, const T *value); */
// buffer: Clear_Bufferiv

/* void ClearNamedFramebufferfv(uint framebuffer, enum buffer, int drawbuffer, const T *value); */
// buffer: Clear_Bufferfv

/* void ClearNamedFramebufferuiv(uint framebuffer, enum buffer, int drawbuffer, const T *value); */
// buffer: Clear_Bufferuiv

/* void ClearBufferfi(enum buffer, int drawbuffer, float depth, int stencil); */
Clear_Bufferfi :: enum u32 {
	Depth_Stencil = gl.DEPTH_STENCIL,
}

/* void ClearNamedFramebufferfi(uint framebuffer, enum buffer, int drawbuffer, float depth, int stencil); */
// buffer: Clear_Bufferfi


/* Invalidating Framebuffers [17.4.4] */

/* void InvalidateSubFramebuffer(enum target, sizei numAttachments, const enum *attachments, int x, int y, sizei width, sizei height); */
// target: Framebuffer_Target
Invalidate_Framebuffer_Attachment :: enum u32 {
	Front                    = gl.FRONT,
	Front_Left               = gl.FRONT_LEFT,
	Front_Right              = gl.FRONT_RIGHT,
	Back                     = gl.BACK,
	Back_Left                = gl.BACK_LEFT,
	Back_Right               = gl.BACK_RIGHT,
	Depth                    = gl.DEPTH,
	Stencil                  = gl.STENCIL,

	Depth_Attachment         = gl.DEPTH_ATTACHMENT,
	Stencil_Attachment       = gl.STENCIL_ATTACHMENT,
	Depth_Stencil_Attachment = gl.DEPTH_STENCIL_ATTACHMENT,
	Color_Attachment0        = gl.COLOR_ATTACHMENT0,
	Color_Attachment1        = gl.COLOR_ATTACHMENT1,
	Color_Attachment2        = gl.COLOR_ATTACHMENT2,
	Color_Attachment3        = gl.COLOR_ATTACHMENT3,
	Color_Attachment4        = gl.COLOR_ATTACHMENT4,
	Color_Attachment5        = gl.COLOR_ATTACHMENT5,
	Color_Attachment6        = gl.COLOR_ATTACHMENT6,
	Color_Attachment7        = gl.COLOR_ATTACHMENT7,
	Color_Attachment8        = gl.COLOR_ATTACHMENT8,
	Color_Attachment9        = gl.COLOR_ATTACHMENT9,
	Color_Attachment10       = gl.COLOR_ATTACHMENT10,
	Color_Attachment11       = gl.COLOR_ATTACHMENT11,
	Color_Attachment12       = gl.COLOR_ATTACHMENT12,
	Color_Attachment13       = gl.COLOR_ATTACHMENT13,
	Color_Attachment14       = gl.COLOR_ATTACHMENT14,
	Color_Attachment15       = gl.COLOR_ATTACHMENT15,
	Color_Attachment16       = gl.COLOR_ATTACHMENT16,
	Color_Attachment17       = gl.COLOR_ATTACHMENT17,
	Color_Attachment18       = gl.COLOR_ATTACHMENT18,
	Color_Attachment19       = gl.COLOR_ATTACHMENT19,
	Color_Attachment20       = gl.COLOR_ATTACHMENT20,
	Color_Attachment21       = gl.COLOR_ATTACHMENT21,
	Color_Attachment22       = gl.COLOR_ATTACHMENT22,
	Color_Attachment23       = gl.COLOR_ATTACHMENT23,
	Color_Attachment24       = gl.COLOR_ATTACHMENT24,
	Color_Attachment25       = gl.COLOR_ATTACHMENT25,
	Color_Attachment26       = gl.COLOR_ATTACHMENT26,
	Color_Attachment27       = gl.COLOR_ATTACHMENT27,
	Color_Attachment28       = gl.COLOR_ATTACHMENT28,
	Color_Attachment29       = gl.COLOR_ATTACHMENT29,
	Color_Attachment30       = gl.COLOR_ATTACHMENT30,
	Color_Attachment31       = gl.COLOR_ATTACHMENT31,
}

/* void InvalidateNamedFramebufferSubData(uint framebuffer, sizei numAttachments, const enum *attachments, int x, int y, sizei width, sizei height); */
// attachments: Invalidate_Framebuffer_Attachment

/* void InvalidateFramebuffer(enum target, sizei numAttachments, const enum *attachments); */
// target: Framebuffer_Target
// attachments: Invalidate_Framebuffer_Attachment

/* void InvalidateNamedFramebufferData(uint framebuffer, sizei numAttachments, const enum *attachments); */
// attachments: Invalidate_Framebuffer_Attachment
