package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_reading_and_copying_pixels.odin

/* Reading Pixels [18.2] */

/* void ReadBuffer(enum src); */
// src: Draw_Buffer (in other file)

/* void NamedFramebufferReadBuffer(uint framebuffer, enum src); */
// src: Draw_Buffer (in other file)

/* void ReadPixels(int x, int y, sizei width, sizei height, enum format, enum type, void *data); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void ReadnPixels(int x, int y, sizei width, sizei height, enum format, enum type, sizei bufSize, void *data); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type


/* Final Conversion [18.2.8] */

/* void ClampColor(enum target, enum clamp); */
Clamp_Color_Target :: enum u32 {
	Clamp_Read_Color = gl.CLAMP_READ_COLOR,
}

Color_Clamping :: enum u32 {
	True       = 1,
	False      = 0,
	Fixed_Only = gl.FIXED_ONLY,
}


/* Copying Pixels [18.3] */

/* void BlitFramebuffer(int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, bitfield mask, enum filter); */
// mask: Buffer_Flag // NOTE: The field None = NONE is disregarded
Blit_Mask :: Clear_Mask

Blit_Framebuffer_Filter :: enum u32 {
	Linear  = gl.LINEAR,
	Nearest = gl.NEAREST,
}

/* void BlitNamedFramebuffer(uint readFramebuffer, uint drawFramebuffer, int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, bitfield mask, enum filter); */
// mask: Blit_Mask
// filter: Blit_Framebuffer_Filter

/* void CopyImageSubData(uint srcName, enum srcTarget, int srcLevel, int srcX, int srcY, int srcZ, uint dstName, enum dstTarget, int dstLevel, int dstX, int dstY, int dstZ, sizei srcWidth, sizei srcHeight, sizei srcDepth); */
Copy_Image_Sub_Data_Target :: enum u32 {
	Renderbuffer                 = gl.RENDERBUFFER,

	Texture_1D                   = gl.TEXTURE_1D,
	Texture_2D                   = gl.TEXTURE_2D,
	Texture_3D                   = gl.TEXTURE_3D,
	Texture_1D_Array             = gl.TEXTURE_1D_ARRAY,
	Texture_2D_Array             = gl.TEXTURE_2D_ARRAY,
	Texture_Rectangle            = gl.TEXTURE_RECTANGLE,
	Texture_Cube_Map             = gl.TEXTURE_CUBE_MAP,
	Texture_Cube_Map_Array       = gl.TEXTURE_CUBE_MAP_ARRAY,
	Texture_2D_Multisample       = gl.TEXTURE_2D_MULTISAMPLE,
	Texture_2D_Multisample_Array = gl.TEXTURE_2D_MULTISAMPLE_ARRAY,
}
