package vendor_gl

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
	Clamp_Read_Color = CLAMP_READ_COLOR,
}

Color_Clamping :: enum u32 {
	True       = 1,
	False      = 0,
	Fixed_Only = FIXED_ONLY,
}


/* Copying Pixels [18.3] */

/* void BlitFramebuffer(int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, bitfield mask, enum filter); */
// mask: Buffer_Flag // NOTE: The field None = NONE is disregarded
Blit_Mask :: Clear_Mask

Blit_Framebuffer_Filter :: enum u32 {
	Linear  = LINEAR,
	Nearest = NEAREST,
}

/* void BlitNamedFramebuffer(uint readFramebuffer, uint drawFramebuffer, int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, bitfield mask, enum filter); */
// mask: Blit_Mask
// filter: Blit_Framebuffer_Filter

/* void CopyImageSubData(uint srcName, enum srcTarget, int srcLevel, int srcX, int srcY, int srcZ, uint dstName, enum dstTarget, int dstLevel, int dstX, int dstY, int dstZ, sizei srcWidth, sizei srcHeight, sizei srcDepth); */
Copy_Image_Sub_Data_Target :: enum u32 {
	Renderbuffer                 = RENDERBUFFER,

	Texture_1D                   = TEXTURE_1D,
	Texture_2D                   = TEXTURE_2D,
	Texture_3D                   = TEXTURE_3D,
	Texture_1D_Array             = TEXTURE_1D_ARRAY,
	Texture_2D_Array             = TEXTURE_2D_ARRAY,
	Texture_Rectangle            = TEXTURE_RECTANGLE,
	Texture_Cube_Map             = TEXTURE_CUBE_MAP,
	Texture_Cube_Map_Array       = TEXTURE_CUBE_MAP_ARRAY,
	Texture_2D_Multisample       = TEXTURE_2D_MULTISAMPLE,
	Texture_2D_Multisample_Array = TEXTURE_2D_MULTISAMPLE_ARRAY,
}
