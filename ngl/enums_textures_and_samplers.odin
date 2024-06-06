package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_textures_and_samplers.odin

/* void ActiveTexture(enum texture); */
Active_Texture :: enum u32 {
	Texture0  = gl.TEXTURE0,
	Texture1  = gl.TEXTURE1,
	Texture2  = gl.TEXTURE2,
	Texture3  = gl.TEXTURE3,
	Texture4  = gl.TEXTURE4,
	Texture5  = gl.TEXTURE5,
	Texture6  = gl.TEXTURE6,
	Texture7  = gl.TEXTURE7,
	Texture8  = gl.TEXTURE8,
	Texture9  = gl.TEXTURE9,
	Texture10 = gl.TEXTURE10,
	Texture11 = gl.TEXTURE11,
	Texture12 = gl.TEXTURE12,
	Texture13 = gl.TEXTURE13,
	Texture14 = gl.TEXTURE14,
	Texture15 = gl.TEXTURE15,
	Texture16 = gl.TEXTURE16,
	Texture17 = gl.TEXTURE17,
	Texture18 = gl.TEXTURE18,
	Texture19 = gl.TEXTURE19,
	Texture20 = gl.TEXTURE20,
	Texture21 = gl.TEXTURE21,
	Texture22 = gl.TEXTURE22,
	Texture23 = gl.TEXTURE23,
	Texture24 = gl.TEXTURE24,
	Texture25 = gl.TEXTURE25,
	Texture26 = gl.TEXTURE26,
	Texture27 = gl.TEXTURE27,
	Texture28 = gl.TEXTURE28,
	Texture29 = gl.TEXTURE29,
	Texture30 = gl.TEXTURE30,
	Texture31 = gl.TEXTURE31,
}


/* Texture Objects [8.1] */

/* void BindTexture(enum target, uint texture); */
Texture_Target :: enum u32 {
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
	// NOTE(tarik): TEXTURE_BUFFER is no argument for Tex*Parameter* below.
	Texture_Buffer               = gl.TEXTURE_BUFFER,
}

/* void CreateTextures(enum target, sizei n, uint *textures); */
// target: Texture_Target


/* Sampler Objects [8.2] */

/* void SamplerParameteri(uint sampler, enum pname, T param); */
Sampler_Parameter :: enum u32 {
	Texture_Border_Color   = gl.TEXTURE_BORDER_COLOR,
	Texture_Compare_Func   = gl.TEXTURE_COMPARE_FUNC,
	Texture_Compare_Mode   = gl.TEXTURE_COMPARE_MODE,
	Texture_LOD_Bias       = gl.TEXTURE_LOD_BIAS,
	Texture_Max_LOD        = gl.TEXTURE_MAX_LOD,
	Texture_Mag_Filter     = gl.TEXTURE_MAG_FILTER,
	Texture_Min_Filter     = gl.TEXTURE_MIN_FILTER,
	Texture_Min_LOD        = gl.TEXTURE_MIN_LOD,
	Texture_Max_Anisotropy = gl.TEXTURE_MAX_ANISOTROPY,
	Texture_Wrap_S         = gl.TEXTURE_WRAP_S,
	Texture_Wrap_T         = gl.TEXTURE_WRAP_T,
	Texture_Wrap_R         = gl.TEXTURE_WRAP_R,
}

/* void SamplerParameterf(uint sampler, enum pname, T param); */
// pname: Sampler_Parameter

/* void SamplerParameteriv(uint sampler, enum pname, const T *param); */
// pname: Sampler_Parameter

/* void SamplerParameterfv(uint sampler, enum pname, const T *param); */
// pname: Sampler_Parameter

/* void SamplerParameterIiv(uint sampler, enum pname, const T *params); */
// pname: Sampler_Parameter

/* void SamplerParameterIuiv(uint sampler, enum pname, const T *params); */
// pname: Sampler_Parameter


/* Sampler Queries [8.3] */

/* void GetSamplerParameteriv(uint sampler, enum pname, T *params); */
// pname: Sampler_Parameter

/* void GetSamplerParameterfv(uint sampler, enum pname, T *params); */
// pname: Sampler_Parameter

/* void GetSamplerParameterIiv(uint sampler, enum pname, T *params); */
// pname: Sampler_Parameter

/* void GetSamplerParameterIuiv(uint sampler, enum pname, T *params); */
// pname: Sampler_Parameter


/* Pixel Storage Modes [8.4.1] */

/* void PixelStorei(enum pname, T param); */
Pixel_Store_Parameter :: enum u32 {
	Pack_Swap_Bytes                = gl.PACK_SWAP_BYTES,
	Pack_LSB_First                 = gl.PACK_LSB_FIRST,
	Pack_Row_Length                = gl.PACK_ROW_LENGTH,
	Pack_Skip_Rows                 = gl.PACK_SKIP_ROWS,
	Pack_Skip_Pixels               = gl.PACK_SKIP_PIXELS,
	Pack_Alignment                 = gl.PACK_ALIGNMENT,
	Pack_Image_Height              = gl.PACK_IMAGE_HEIGHT,
	Pack_Skip_Images               = gl.PACK_SKIP_IMAGES,
	Pack_Compressed_Block_Width    = gl.PACK_COMPRESSED_BLOCK_WIDTH,
	Pack_Compressed_Block_Height   = gl.PACK_COMPRESSED_BLOCK_HEIGHT,
	Pack_Compressed_Block_Depth    = gl.PACK_COMPRESSED_BLOCK_DEPTH,
	Pack_Compressed_Block_Size     = gl.PACK_COMPRESSED_BLOCK_SIZE,

	Unpack_Swap_Bytes              = gl.UNPACK_SWAP_BYTES,
	Unpack_LSB_First               = gl.UNPACK_LSB_FIRST,
	Unpack_Row_Length              = gl.UNPACK_ROW_LENGTH,
	Unpack_Skip_Rows               = gl.UNPACK_SKIP_ROWS,
	Unpack_Skip_Pixels             = gl.UNPACK_SKIP_PIXELS,
	Unpack_Alignment               = gl.UNPACK_ALIGNMENT,
	Unpack_Image_Height            = gl.UNPACK_IMAGE_HEIGHT,
	Unpack_Skip_Images             = gl.UNPACK_SKIP_IMAGES,
	Unpack_Compressed_Block_Width  = gl.UNPACK_COMPRESSED_BLOCK_WIDTH,
	Unpack_Compressed_Block_Height = gl.UNPACK_COMPRESSED_BLOCK_HEIGHT,
	Unpack_Compressed_Block_Depth  = gl.UNPACK_COMPRESSED_BLOCK_DEPTH,
	Unpack_Compressed_Block_Size   = gl.UNPACK_COMPRESSED_BLOCK_SIZE,
}

/* void PixelStoref(enum pname, T param); */
// pname: Pixel_Store_Parameter


/* Texture Image Spec. [8.5] */

// NOTE(tarik): internalformat was turned from int to u32, whereas it's casted to i32 when passed to impl_*
/* void TexImage3D(enum target, int level, int internalformat, sizei width, sizei height, sizei depth, int border, enum format, enum type, const void *data); */
Tex_Image_3D_Target :: enum u32 {
	Texture_3D                   = gl.TEXTURE_3D,
	Texture_2D_Array             = gl.TEXTURE_2D_ARRAY,
	Texture_Cube_Map_Array       = gl.TEXTURE_CUBE_MAP_ARRAY,
	Proxy_Texture_3D             = gl.PROXY_TEXTURE_3D,
	Proxy_Texture_2D_Array       = gl.PROXY_TEXTURE_2D_ARRAY,
	Proxy_Texture_Cube_Map_Array = gl.PROXY_TEXTURE_CUBE_MAP_ARRAY,
}

Texture_Internalformat :: enum u32 {
	// Base Internal Format
	Depth_Component = gl.DEPTH_COMPONENT,
	Depth_Stencil   = gl.DEPTH_STENCIL,
	Stencil_Index   = gl.STENCIL_INDEX, // TODO(tarik): This needs to be verified. It's correct according to Ref. Card.
	Red             = gl.RED,
	RG              = gl.RG,
	RGB             = gl.RGB,
	RGBA            = gl.RGBA,

	// Sized Internal Format
	R8             = gl.R8,
	R8_Snorm       = gl.R8_SNORM,
	R16            = gl.R16,
	R16_Snorm      = gl.R16_SNORM,
	RG8            = gl.RG8,
	RG8_Snorm      = gl.RG8_SNORM,
	RG16           = gl.RG16,
	RG16_Snorm     = gl.RG16_SNORM,
	R3_G3_B2       = gl.R3_G3_B2,
	RGB4           = gl.RGB4,
	RGB5           = gl.RGB5,
	RGB8           = gl.RGB8,
	RGB8_Snorm     = gl.RGB8_SNORM,
	RGB10          = gl.RGB10,
	RGB12          = gl.RGB12,
	RGB16_Snorm    = gl.RGB16_SNORM,
	RGBA2          = gl.RGBA2,
	RGBA4          = gl.RGBA4,
	RGB5_A1        = gl.RGB5_A1,
	RGBA8          = gl.RGBA8,
	RGBA8_Snorm    = gl.RGBA8_SNORM,
	RGB10_A2       = gl.RGB10_A2,
	RGB10_A2ui     = gl.RGB10_A2UI,
	RGBA12         = gl.RGBA12,
	RGBA16         = gl.RGBA16,
	SRGB8          = gl.SRGB8,
	SRGB8_Alpha8   = gl.SRGB8_ALPHA8,
	R16f           = gl.R16F,
	RG16f          = gl.RG16F,
	RGB16f         = gl.RGB16F,
	RGBA16f        = gl.RGBA16F,
	R32f           = gl.R32F,
	RG32f          = gl.RG32F,
	RGB32f         = gl.RGB32F,
	RGBA32f        = gl.RGBA32F,
	R11f_G11f_B10f = gl.R11F_G11F_B10F,
	RGB9_E5        = gl.RGB9_E5,
	R8i            = gl.R8I,
	R8ui           = gl.R8UI,
	R16i           = gl.R16I,
	R16ui          = gl.R16UI,
	R32i           = gl.R32I,
	R32ui          = gl.R32UI,
	RG8i           = gl.RG8I,
	RG8ui          = gl.RG8UI,
	RG16i          = gl.RG16I,
	RG16ui         = gl.RG16UI,
	RG32i          = gl.RG32I,
	RG32ui         = gl.RG32UI,
	RGB8i          = gl.RGB8I,
	RGB8ui         = gl.RGB8UI,
	RGB16i         = gl.RGB16I,
	RGB16ui        = gl.RGB16UI,
	RGB32i         = gl.RGB32I,
	RGB32ui        = gl.RGB32UI,
	RGBA8i         = gl.RGBA8I,
	RGBA8ui        = gl.RGBA8UI,
	RGBA16i        = gl.RGBA16I,
	RGBA16ui       = gl.RGBA16UI,
	RGBA32i        = gl.RGBA32I,
	RGBA32ui       = gl.RGBA32UI,

	// Compressed Internal Format (Generic)
	Compressed_Red        = gl.COMPRESSED_RED,
	Compressed_RG         = gl.COMPRESSED_RG,
	Compressed_RGB        = gl.COMPRESSED_RGB,
	Compressed_RGBA       = gl.COMPRESSED_RGBA,
	Compressed_SRGB       = gl.COMPRESSED_SRGB,
	Compressed_SRGB_Alpha = gl.COMPRESSED_SRGB_ALPHA,

	// Compressed Internal Format (Specific)
	Compressed_Red_RGTC1               = gl.COMPRESSED_RED_RGTC1,
	Compressed_Signed_Red_RGTC1        = gl.COMPRESSED_SIGNED_RED_RGTC1,
	Compressed_RG_RGTC2                = gl.COMPRESSED_RG_RGTC2,
	Compressed_Signed_RG_RGTC2         = gl.COMPRESSED_SIGNED_RG_RGTC2,
	Compressed_RGBA_BPTC_Unorm         = gl.COMPRESSED_RGBA_BPTC_UNORM,
	Compressed_SRGB_Alpha_BPTC_Unorm   = gl.COMPRESSED_SRGB_ALPHA_BPTC_UNORM,
	Compressed_RGB_BPTC_Signed_Float   = gl.COMPRESSED_RGB_BPTC_SIGNED_FLOAT,
	Compressed_RGB_BPTC_Unsigned_Float = gl.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT,
}

Tex_Image_3D_Format :: Pixel_Data_Format
Pixel_Data_Format :: enum u32 {
	Stencil_Index   = gl.STENCIL_INDEX,
	Depth_Component = gl.DEPTH_COMPONENT,
	Depth_Stencil   = gl.DEPTH_STENCIL,
	Red             = gl.RED,
	Green           = gl.GREEN,
	Blue            = gl.BLUE,
	RG              = gl.RG,
	RGB             = gl.RGB,
	RGBA            = gl.RGBA,
	BGR             = gl.BGR,
	BGRA            = gl.BGRA,
	Red_Integer     = gl.RED_INTEGER,
	Green_Integer   = gl.GREEN_INTEGER,
	Blue_Integer    = gl.BLUE_INTEGER,
	RG_Integer      = gl.RG_INTEGER,
	RGB_Integer     = gl.RGB_INTEGER,
	RGBA_Integer    = gl.RGBA_INTEGER,
	BGR_Integer     = gl.BGR_INTEGER,
	BGRA_Integer    = gl.BGRA_INTEGER,
}

Tex_Image_3D_Type :: Pixel_Data_Type
Pixel_Data_Type :: enum u32 {
	Unsigned_Byte                  = gl.UNSIGNED_BYTE,
	Byte                           = gl.BYTE,
	Unsigned_Short                 = gl.UNSIGNED_SHORT,
	Short                          = gl.SHORT,
	Unsigned_Int                   = gl.UNSIGNED_INT,
	Int                            = gl.INT,
	Half_Float                     = gl.HALF_FLOAT,
	Float                          = gl.FLOAT,
	Unsigned_Byte_3_3_2            = gl.UNSIGNED_BYTE_3_3_2,
	Unsigned_Byte_2_3_3_Rev        = gl.UNSIGNED_BYTE_2_3_3_REV,
	Unsigned_Short_5_6_5           = gl.UNSIGNED_SHORT_5_6_5,
	Unsigned_Short_5_6_5_Rev       = gl.UNSIGNED_SHORT_5_6_5_REV,
	Unsigned_Short_4_4_4_4         = gl.UNSIGNED_SHORT_4_4_4_4,
	Unsigned_Short_4_4_4_4_Rev     = gl.UNSIGNED_SHORT_4_4_4_4_REV,
	Unsigned_Short_5_5_5_1         = gl.UNSIGNED_SHORT_5_5_5_1,
	Unsigned_Short_1_5_5_5_Rev     = gl.UNSIGNED_SHORT_1_5_5_5_REV,
	Unsigned_Int_8_8_8_8           = gl.UNSIGNED_INT_8_8_8_8,
	Unsigned_Int_8_8_8_8_Rev       = gl.UNSIGNED_INT_8_8_8_8_REV,
	Unsigned_Int_10_10_10_2        = gl.UNSIGNED_INT_10_10_10_2,
	Unsigned_Int_2_10_10_10_Rev    = gl.UNSIGNED_INT_2_10_10_10_REV,
	Unsigned_Int_24_8              = gl.UNSIGNED_INT_24_8,
	Unsigned_Int_10f_11f_11f_Rev   = gl.UNSIGNED_INT_10F_11F_11F_REV,
	Unsigned_Int_5_9_9_9_Rev       = gl.UNSIGNED_INT_5_9_9_9_REV,
	Float_32_Unsigned_Int_24_8_Rev = gl.FLOAT_32_UNSIGNED_INT_24_8_REV,
}

// NOTE(tarik): internalformat was turned from int to u32, whereas it's casted to i32 when passed to impl_*
/* void TexImage2D(enum target, int level, int internalformat, sizei width, sizei height, int border, enum format, enum type, const void *data); */
// internalformat: Texture_Internalformat
// format:         Pixel_Data_Format
// type:           Pixel_Data_Type

Tex_Image_2D_Target :: enum u32 {
	Texture_2D                  = gl.TEXTURE_2D,
	Texture_1D_Array            = gl.TEXTURE_1D_ARRAY,
	Texture_Rectangle           = gl.TEXTURE_RECTANGLE,
	Texture_Cube_Map_Positive_X = gl.TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y = gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z = gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X = gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z,
	Proxy_Texture_2D            = gl.PROXY_TEXTURE_2D,
	Proxy_Texture_1D_Array      = gl.PROXY_TEXTURE_1D_ARRAY,
	Proxy_Texture_Rectangle     = gl.PROXY_TEXTURE_RECTANGLE,
	Proxy_Texture_Cube_Map      = gl.PROXY_TEXTURE_CUBE_MAP,
}

// NOTE(tarik): internalformat was turned from int to u32, whereas it's casted to i32 when passed to impl_*
/* void TexImage1D(enum target, int level, int internalformat, sizei width, int border, enum format, enum type, const void *data); */
// internalformat: Texture_Internalformat
// format:         Pixel_Data_Format
// type:           Pixel_Data_Type

Tex_Image_1D_Target :: enum u32 {
	Texture_1D       = gl.TEXTURE_1D,
	Proxy_Texture_1D = gl.PROXY_TEXTURE_1D,
}


/* Alternate Texture Image Spec. [8.6] */

/* void CopyTexImage2D(enum target, int level, enum internalformat, int x, int y, sizei width, sizei height, int border); */
// internalformat: Texture_Internalformat

Copy_Tex_Image_2D_Target :: enum u32 {
	Texture_2D                  = gl.TEXTURE_2D,
	Texture_1D_Array            = gl.TEXTURE_1D_ARRAY,
	Texture_Rectangle           = gl.TEXTURE_RECTANGLE,
	Texture_Cube_Map_Positive_X = gl.TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y = gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z = gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X = gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z,
}

/* void CopyTexImage1D(enum target, int level, enum internalformat, int x, int y, sizei width, int border); */
// internalformat: Texture_Internalformat

Copy_Tex_Image_1D_Target :: enum u32 {
	Texture_1D = gl.TEXTURE_1D,
}

/* void TexSubImage3D(enum target, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, enum format, enum type, const void *data); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

Tex_Sub_Image_3D_Target :: enum u32 {
	Texture_3D             = gl.TEXTURE_3D,
	Texture_2D_Array       = gl.TEXTURE_2D_ARRAY,
	Texture_Cube_Map_Array = gl.TEXTURE_CUBE_MAP_ARRAY,
}

/* void TexSubImage2D(enum target, int level, int xoffset, int yoffset, sizei width, sizei height, enum format, enum type, const void *data); */
// target: Copy_Tex_Image_2D_Target
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void TexSubImage1D(enum target, int level, int xoffset, sizei width, enum format, enum type, const void *data); */
// target: Copy_Tex_Image_1D_Target
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void CopyTexSubImage3D(enum target, int level, int xoffset, int yoffset, int zoffset, int x, int y, sizei width, sizei height); */
// target: Tex_Sub_Image_3D_Target

/* void CopyTexSubImage2D(enum target, int level, int xoffset, int yoffset, int x, int y, sizei width, sizei height); */
// target: Tex_Image_2D_Target

/* void CopyTexSubImage1D(enum target, int level, int xoffset, int x, int y, sizei width); */
// target: Copy_Tex_Image_1D_Target

/* void TextureSubImage3D(uint texture, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, enum format, enum type, const void *pixels); */
// format: Pixel_Data_Format
// type: : Pixel_Data_Type

/* void TextureSubImage2D(uint texture, int level, int xoffset, int yoffset, sizei width, sizei height, enum format, enum type, const void *pixels); */
// format: Pixel_Data_Format
// type: : Pixel_Data_Type

/* void TextureSubImage1D(uint texture, int level, int xoffset, sizei width, enum format, enum type, const void *pixels); */
// format: Pixel_Data_Format
// type: : Pixel_Data_Type


/* Compressed Texture Images [8.7] */

/* void CompressedTexImage3D(enum target, int level, enum internalformat, sizei width, sizei height, sizei depth, int border, sizei imageSize, const void *data); */
// target: Tex_Image_3D_Target 

Compressed_Internalformat :: enum u32 {
	// Generic, Copyable
	Compressed_Red        = gl.COMPRESSED_RED,
	Compressed_RG         = gl.COMPRESSED_RG,
	Compressed_RGB        = gl.COMPRESSED_RGB,
	Compressed_RGBA       = gl.COMPRESSED_RGBA,
	Compressed_SRGB       = gl.COMPRESSED_SRGB,
	Compressed_SRGB_Alpha = gl.COMPRESSED_SRGB_ALPHA,
	
	// Specific, Copyable
	Compressed_Red_RGTC1               = gl.COMPRESSED_RED_RGTC1,
	Compressed_Signed_Red_RGTC1        = gl.COMPRESSED_SIGNED_RED_RGTC1,
	Compressed_RG_RGTC2                = gl.COMPRESSED_RG_RGTC2,
	Compressed_Signed_RG_RGTC2         = gl.COMPRESSED_SIGNED_RG_RGTC2,
	Compressed_RGBA_BPTC_Unorm         = gl.COMPRESSED_RGBA_BPTC_UNORM,
	Compressed_SRGB_Alpha_BPTC_Unorm   = gl.COMPRESSED_SRGB_ALPHA_BPTC_UNORM,
	Compressed_RGB_BPTC_Signed_Float   = gl.COMPRESSED_RGB_BPTC_SIGNED_FLOAT,
	Compressed_RGB_BPTC_Unsigned_Float = gl.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT,

	// Specific, Not Copyable
	Compressed_RGB8_ETC2                      = gl.COMPRESSED_RGB8_ETC2,
	Compressed_SRGB8_ETC2                     = gl.COMPRESSED_SRGB8_ETC2,
	Compressed_RGB8_Punchthrough_Alpha1_ETC2  = gl.COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2,
	Compressed_SRGB8_Punchthrough_Alpha1_ETC2 = gl.COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2,
	Compressed_RGBA8_ETC2_EAC                 = gl.COMPRESSED_RGBA8_ETC2_EAC,
	Compressed_SRGB8_Alpha8_ETC2_EAC          = gl.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC,
	Compressed_R11_EAC                        = gl.COMPRESSED_R11_EAC,
	Compressed_Signed_R11_EAC                 = gl.COMPRESSED_SIGNED_R11_EAC,
	Compressed_RG11_EAC                       = gl.COMPRESSED_RG11_EAC,
	Compressed_Signed_RG11_EAC                = gl.COMPRESSED_SIGNED_RG11_EAC,
}


/* void CompressedTexImage2D(enum target, int level, enum internalformat, sizei width, sizei height, int border, sizei imageSize, const void *data); */
// internalformat: Compressed_Internalformat

Compressed_Tex_Image_2D_Target :: enum u32 {
	Texture_2D                  = gl.TEXTURE_2D,
	Texture_1D_Array            = gl.TEXTURE_1D_ARRAY,
	Texture_Cube_Map_Positive_X = gl.TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y = gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z = gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X = gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z,
	Proxy_Texture_2D            = gl.PROXY_TEXTURE_2D,
	Proxy_Texture_1D_Array      = gl.PROXY_TEXTURE_1D_ARRAY,
	Proxy_Texture_Cube_Map      = gl.PROXY_TEXTURE_CUBE_MAP,
}


/* void CompressedTexImage1D(enum target, int level, enum internalformat, sizei width, int border, sizei imageSize, const void *data); */
// target:         Tex_Image_1D_Target
// internalformat: Texture_Internalformat

/* void CompressedTexSubImage3D(enum target, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, enum format, sizei imageSize, const void *data); */
// target: Tex_Sub_Image_3D_Target
// format: Compressed_Internalformat

/* void CompressedTexSubImage2D(enum target, int level, int xoffset, int yoffset, sizei width, sizei height, enum format, sizei imageSize, cont void *data); */
// target: Copy_Tex_Image_2D_Target
// format: Compressed_Internalformat

/* void CompressedTexSubImage1D(enum target, int level, int xoffset, sizei width, enum format, sizei imageSize, const void *data); */
// target: Copy_Tex_Image_1D_Target
// format: Texture_Internalformat

/* void CompressedTextureSubImage3D(uint texture, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, enum format, sizei imageSize, const void *data); */
// format: Compressed_Internalformat

/* void CompressedTextureSubImage2D(uint texture, int level, int xoffset, int yoffset, sizei width, sizei height, enum format, sizei imageSize, cont void *data); */
// format: Compressed_Internalformat

/* void CompressedTextureSubImage1D(uint texture, int level, int xoffset, sizei width, enum format, sizei imageSize, const void *data); */
// format: Texture_Internalformat


/* Multisample Textures [8.8] */

/* void TexImage3DMultisample(enum target, sizei samples, enum internalformat, sizei width, sizei height, sizei depth, boolean fixedsamplelocations); */
Tex_3D_Multisample_Target :: enum u32 {
	Texture_2D_Multisample_Array       = gl.TEXTURE_2D_MULTISAMPLE_ARRAY,
	Proxy_Texture_2D_Multisample_Array = gl.PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY,
}

Color_Depth_Stencil_Renderable_Format :: enum u32 {
	// TODO(tarik): Marked fields are part of the enum as per my limited
	//              understanding of the Spec. (see page 234, 327,...),
	//              however they're not included in the Ref. Card. This
	//              makes the name of this enum questionable.
	//              Further, Ref. Card speaks of RGBA32, which doesn't
	//              exist. Thus, I assume RGBA32i was meant and leave it in.
	// 
	//              Probably the best is to use all.

	// Color-Renderable
	Red                = gl.RED,
	RG                 = gl.RG,
	RGB                = gl.RGB,
	RGBA               = gl.RGBA,
	R8                 = gl.R8,                 // *
	R8_Snorm           = gl.R8_SNORM,           // *
	R16                = gl.R16,                // *
	R16_Snorm          = gl.R16_SNORM,          // *
	RG8                = gl.RG8,                // *
	RG8_Snorm          = gl.RG8_SNORM,          // *
	RG16               = gl.RG16,               // *
	RG16_Snorm         = gl.RG16_SNORM,         // *
	R3_G3_B2           = gl.R3_G3_B2,           // *
	RGB4               = gl.RGB4,               // *
	RGB5               = gl.RGB5,               // *
	RGB565             = gl.RGB5,               // *
	RGB8               = gl.RGB8,               // *
	RGB8_Snorm         = gl.RGB8_SNORM,         // *
	RGB10              = gl.RGB10,              // *
	RGB12              = gl.RGB12,              // *
	RGB16              = gl.RGB16,              // *
	RGB16_Snorm        = gl.RGB16_SNORM,        // *
	RGBA2              = gl.RGBA2,              // *
	RGBA4              = gl.RGBA4,              // *
	RGB5_A1            = gl.RGB5_A1,            // *
	RGBA8              = gl.RGBA8,              // *
	RGBA8_Snorm        = gl.RGBA8_SNORM,        // *
	RGB10_A2           = gl.RGB10_A2,           // *
	RGB10_A2ui         = gl.RGB10_A2UI,         // *
	RGBA12             = gl.RGBA12,             // *
	RGBA16             = gl.RGBA16,             // *
	RGBA16_Snorm       = gl.RGBA16_SNORM,       // *
	SRGB8              = gl.SRGB8,              // *
	SRGB8_Alpha8       = gl.SRGB8_ALPHA8,       // *
	R16f               = gl.R16F,               // *
	RG16f              = gl.RG16F,              // *
	RGB16f             = gl.RGB16F,             // *
	RGBA16f            = gl.RGBA16F,            // *
	R32f               = gl.R32F,               // *
	RG32f              = gl.RG32F,              // *
	RGB32f             = gl.RGB32F,             // *
	RGBA32f            = gl.RGBA32F,            // *
	R11f_G11f_B10f     = gl.R11F_G11F_B10F,     // *
	R8i                = gl.R8I,                // *
	R8ui               = gl.R8UI,               // *
	R16i               = gl.R16I,               // *
	R16ui              = gl.R16UI,              // *
	R32i               = gl.R32I,               // *
	R32ui              = gl.R32UI,              // *
	RG8i               = gl.RG8I,               // *
	RG8ui              = gl.RG8UI,              // *
	RG16i              = gl.RG16I,              // *
	RG16ui             = gl.RG16UI,             // *
	RG32i              = gl.RG32I,              // *
	RG32ui             = gl.RG32UI,             // *
	RGB8i              = gl.RGB8I,              // *
	RGB8ui             = gl.RGB8UI,             // *
	RGB16i             = gl.RGB16I,             // *
	RGB16ui            = gl.RGB16UI,            // *
	RGB32i             = gl.RGB32I,             // *
	RGB32ui            = gl.RGB32UI,            // *
	RGBA8i             = gl.RGBA8I,             // *
	RGBA8ui            = gl.RGBA8UI,            // *
	RGBA16i            = gl.RGBA16I,            // *
	RGBA16ui           = gl.RGBA16UI,           // *
	RGBA32i            = gl.RGBA32I,
	RGBA32ui           = gl.RGBA32UI,

	// Depth-Renderable
	Depth_Component    = gl.DEPTH_COMPONENT,
	Depth_Component16  = gl.DEPTH_COMPONENT16,
	Depth_Component24  = gl.DEPTH_COMPONENT24,
	Depth_Component32  = gl.DEPTH_COMPONENT32,
	Depth_Component32f = gl.DEPTH_COMPONENT32F,
	Depth_Stencil      = gl.DEPTH_STENCIL,      // *
	Depth24_Stencil8   = gl.DEPTH24_STENCIL8,
	Depth32f_Stencil8  = gl.DEPTH32F_STENCIL8,

	// Stencil-Renderable
	Stencil_Index      = gl.STENCIL_INDEX,      // *
	Stencil_Index1     = gl.STENCIL_INDEX1,
	Stencil_Index4     = gl.STENCIL_INDEX4,
	Stencil_Index8     = gl.STENCIL_INDEX8,
	Stencil_Index16    = gl.STENCIL_INDEX16,
}

/* void TexImage2DMultisample(enum target, sizei samples, enum internalformat, sizei width, sizei height, boolean fixedsamplelocations); */
// internalformat: Color_Depth_Stencil_Renderable_Format

Tex_2D_Multisample_Target :: enum u32 {
	Texture_2D_Multisample       = gl.TEXTURE_2D_MULTISAMPLE,
	Proxy_Texture_2D_Multisample = gl.PROXY_TEXTURE_2D_MULTISAMPLE,
}


/* Buffer Textures [8.9] */

/* void TexBufferRange(enum target, enum internalFormat, uint buffer, intptr offset, sizeiptr size); */
Tex_Buffer_Target :: enum u32 {
	Texture_Buffer = gl.TEXTURE_BUFFER,
}

Tex_Buffer_Internalformat :: enum u32 {
	R8       = gl.R8,
	R16      = gl.R16,
	R16f     = gl.R16F,
	R32f     = gl.R32F,
	R8i      = gl.R8I,
	R16i     = gl.R16I,
	R32i     = gl.R32I,
	R8ui     = gl.R8UI,
	R16ui    = gl.R16UI,
	R32ui    = gl.R32UI,
	RG8      = gl.RG8,
	RG16     = gl.RG16,
	RG16f    = gl.RG16F,
	RG32f    = gl.RG32F,
	RG8i     = gl.RG8I,
	RG16i    = gl.RG16I,
	RG32i    = gl.RG32I,
	RG8ui    = gl.RG8UI,
	RG16ui   = gl.RG16UI,
	RG32ui   = gl.RG32UI,
	RGB32f   = gl.RGB32F,
	RGB32i   = gl.RGB32I,
	RGB32ui  = gl.RGB32UI,
	RGBA8    = gl.RGBA8,
	RGBA16   = gl.RGBA16,
	RGBA16f  = gl.RGBA16F,
	RGBA32f  = gl.RGBA32F,
	RGBA8i   = gl.RGBA8I,
	RGBA16i  = gl.RGBA16I,
	RGBA32i  = gl.RGBA32I,
	RGBA8ui  = gl.RGBA8UI,
	RGBA16ui = gl.RGBA16UI,
	RGBA32ui = gl.RGBA32UI,
}

/* void TextureBufferRange(uint texture, enum internalFormat, uint buffer, intptr offset, sizeiptr size); */
// internalformat: Tex_Buffer_Internalformat

/* void TexBuffer(enum target, enum internalformat, uint buffer); */
// target: Tex_Buffer_Target
// internalformat: Tex_Buffer_Internalformat

/* void TextureBuffer(uint texture, enum internalformat, uint buffer); */
// internalformat: Tex_Buffer_Internalformat


/* Texture Parameters [8.10] */

/* void TexParameteri(enum target, enum pname, T param); */
Texture_Parameter_Target :: enum u32 {
// NOTE(tarik): This differs from Texture_Target by not having TEXTURE_BUFFER.
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
Texture_Parameter :: enum u32 {
	Depth_Stencil_Texture_Mode = gl.DEPTH_STENCIL_TEXTURE_MODE,
	Texture_Wrap_S             = gl.TEXTURE_WRAP_S,
	Texture_Wrap_T             = gl.TEXTURE_WRAP_T,
	Texture_Wrap_R             = gl.TEXTURE_WRAP_R,
	Texture_Border_Color       = gl.TEXTURE_BORDER_COLOR,
	Texture_Min_Filter         = gl.TEXTURE_MIN_FILTER,
	Texture_Mag_Filter         = gl.TEXTURE_MAG_FILTER,
	Texture_LOD_Bias           = gl.TEXTURE_LOD_BIAS,
	Texture_Min_LOD            = gl.TEXTURE_MIN_LOD,
	Texture_Max_LOD            = gl.TEXTURE_MAX_LOD,
	Texture_Base_Level         = gl.TEXTURE_BASE_LEVEL,
	Texture_Max_Level          = gl.TEXTURE_MAX_LEVEL,
	Texture_Swizzle_R          = gl.TEXTURE_SWIZZLE_R,
	Texture_Swizzle_G          = gl.TEXTURE_SWIZZLE_G,
	Texture_Swizzle_B          = gl.TEXTURE_SWIZZLE_B,
	Texture_Swizzle_A          = gl.TEXTURE_SWIZZLE_A,
	Texture_Swizzle_RGBA       = gl.TEXTURE_SWIZZLE_RGBA,
	Texture_Compare_Mode       = gl.TEXTURE_COMPARE_MODE,
	Texture_Compare_Func       = gl.TEXTURE_COMPARE_FUNC,
	// TODO(tarik): This one is only in the Spec:
	Texture_Max_Anisotropy     = gl.TEXTURE_MAX_ANISOTROPY,
}

/* void TexParameterf(enum target, enum pname, T param); */
// target: Texture_Parameter_Target
// pname:  Texture_Parameter

/* void TexParameteriv(enum target, enum pname, const T *params); */
// target: Texture_Parameter_Target
// pname:  Texture_Parameter

/* void TexParameterfv(enum target, enum pname, const T *params); */
// target: Texture_Parameter_Target
// pname:  Texture_Parameter

/* void TexParameterIiv(enum target, enum pname, const T *params); */
// target: Texture_Parameter_Target
// pname:  Texture_Parameter

/* void TexParameterIuiv(enum target, enum pname, const T *params); */
// target: Texture_Parameter_Target
// pname:  Texture_Parameter

/* void TextureParameteri(uint texture, enum pname, T param); */
// pname: Texture_Parameter

/* void TextureParameterf(uint texture, enum pname, T param); */
// pname: Texture_Parameter

/* void TextureParameteriv(uint texture, enum pname, const T *params); */
// pname: Texture_Parameter

/* void TextureParameterfv(uint texture, enum pname, const T *params); */
// pname: Texture_Parameter

/* void TextureParameterIiv(uint texture, enum pname, const T *params); */
// pname: Texture_Parameter

/* void TextureParameterIuiv(uint texture, enum pname, const T *params); */
// pname: Texture_Parameter


/* Texture Queries [8.11] */

/* void GetTexParameteriv(enum target, enum pname, T * params); */
// target: Texture_Parameter_Target

Get_Texture_Parameter :: enum u32 {
	Image_Format_Compatibility_Type = gl.IMAGE_FORMAT_COMPATIBILITY_TYPE,
	Texture_Immutable_Format        = gl.TEXTURE_IMMUTABLE_FORMAT,
	Texture_Immutable_Levels        = gl.TEXTURE_IMMUTABLE_LEVELS,
	Texture_Target                  = gl.TEXTURE_TARGET,
	Texture_View_Min_Level          = gl.TEXTURE_VIEW_MIN_LEVEL,
	Texture_View_Num_Levels         = gl.TEXTURE_VIEW_NUM_LEVELS,
	Texture_View_Min_Layer          = gl.TEXTURE_VIEW_MIN_LAYER,
	Texture_View_Num_Layers         = gl.TEXTURE_VIEW_NUM_LAYERS,

	Depth_Stencil_Texture_Mode      = gl.DEPTH_STENCIL_TEXTURE_MODE,
	Texture_Wrap_S                  = gl.TEXTURE_WRAP_S,
	Texture_Wrap_T                  = gl.TEXTURE_WRAP_T,
	Texture_Wrap_R                  = gl.TEXTURE_WRAP_R,
	Texture_Border_Color            = gl.TEXTURE_BORDER_COLOR,
	Texture_Min_Filter              = gl.TEXTURE_MIN_FILTER,
	Texture_Mag_Filter              = gl.TEXTURE_MAG_FILTER,
	Texture_LOD_Bias                = gl.TEXTURE_LOD_BIAS,
	Texture_Min_LOD                 = gl.TEXTURE_MIN_LOD,
	Texture_Max_LOD                 = gl.TEXTURE_MAX_LOD,
	Texture_Base_Level              = gl.TEXTURE_BASE_LEVEL,
	Texture_Max_Level               = gl.TEXTURE_MAX_LEVEL,
	Texture_Swizzle_R               = gl.TEXTURE_SWIZZLE_R,
	Texture_Swizzle_G               = gl.TEXTURE_SWIZZLE_G,
	Texture_Swizzle_B               = gl.TEXTURE_SWIZZLE_B,
	Texture_Swizzle_A               = gl.TEXTURE_SWIZZLE_A,
	Texture_Swizzle_RGBA            = gl.TEXTURE_SWIZZLE_RGBA,
	Texture_Compare_Mode            = gl.TEXTURE_COMPARE_MODE,
	Texture_Compare_Func            = gl.TEXTURE_COMPARE_FUNC,
	// TODO(tarik): This one is only in the Spec:
	Texture_Max_Anisotropy          = gl.TEXTURE_MAX_ANISOTROPY,
}

/* void GetTexParameterfv(enum target, enum pname, T * params); */
// target: Texture_Parameter_Target
// pname:  Get_Texture_Parameter

/* void GetTexParameterIiv(enum target, enum pname, T * params); */
// target: Texture_Parameter_Target
// pname:  Get_Texture_Parameter

/* void GetTexParameterIuiv(enum target, enum pname, T * params); */
// target: Texture_Parameter_Target
// pname:  Get_Texture_Parameter

/* void GetTextureParameteriv(uint texture, enum pname, T *data); */
// pname:  Get_Texture_Parameter

/* void GetTextureParameterfv(uint texture, enum pname, T *data); */
// pname:  Get_Texture_Parameter

/* void GetTextureParameterIiv(uint texture, enum pname, T *data); */
// pname:  Get_Texture_Parameter

/* void GetTextureParameterIuiv(uint texture, enum pname, T *data); */
// pname:  Get_Texture_Parameter

/* void GetTexLevelParameteriv(enum target, int level, enum pname, T *params); */
Tex_Level_Parameter_Target :: enum u32 {
	Texture_1D                         = gl.TEXTURE_1D,
	Texture_2D                         = gl.TEXTURE_2D,
	Texture_3D                         = gl.TEXTURE_3D,
	Texture_1D_Array                   = gl.TEXTURE_1D_ARRAY,
	Texture_2D_Array                   = gl.TEXTURE_2D_ARRAY,
	Texture_Cube_Map_Array             = gl.TEXTURE_CUBE_MAP_ARRAY,
	Texture_Rectangle                  = gl.TEXTURE_RECTANGLE,
	Texture_Buffer                     = gl.TEXTURE_BUFFER,
	Texture_2D_Multisample             = gl.TEXTURE_2D_MULTISAMPLE,
	Texture_2D_Multisample_Array       = gl.TEXTURE_2D_MULTISAMPLE_ARRAY,
	Proxy_Texture_1D                   = gl.PROXY_TEXTURE_1D,
	Proxy_Texture_2D                   = gl.PROXY_TEXTURE_2D,
	Proxy_Texture_3D                   = gl.PROXY_TEXTURE_3D,
	Proxy_Texture_1D_Array             = gl.PROXY_TEXTURE_1D_ARRAY,
	Proxy_Texture_2D_Array             = gl.PROXY_TEXTURE_2D_ARRAY,
	Proxy_Texture_Cube_Map_Array       = gl.PROXY_TEXTURE_CUBE_MAP_ARRAY,
	Proxy_Texture_Rectangle            = gl.PROXY_TEXTURE_RECTANGLE,
	Proxy_Texture_Cube_Map             = gl.PROXY_TEXTURE_CUBE_MAP,
	Proxy_Texture_2D_Multisample       = gl.PROXY_TEXTURE_2D_MULTISAMPLE,
	Proxy_Texture_2D_Multisample_Array = gl.PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY,

	Texture_Cube_Map_Positive_X       = gl.TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y       = gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z       = gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X       = gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y       = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z       = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z,
}

Tex_Level_Parameter :: enum u32 {
	Texture_Width                     = gl.TEXTURE_WIDTH,
	Texture_Height                    = gl.TEXTURE_HEIGHT,
	Texture_Depth                     = gl.TEXTURE_DEPTH,
	Texture_Samples                   = gl.TEXTURE_SAMPLES,
	Texture_Fixed_Sample_Locations    = gl.TEXTURE_FIXED_SAMPLE_LOCATIONS,
	Texture_Internal_Format           = gl.TEXTURE_INTERNAL_FORMAT,
	Texture_Red_Size                  = gl.TEXTURE_RED_SIZE,
	Texture_Green_Size                = gl.TEXTURE_GREEN_SIZE,
	Texture_Blue_Size                 = gl.TEXTURE_BLUE_SIZE,
	Texture_Alpha_Size                = gl.TEXTURE_ALPHA_SIZE,
	Texture_Depth_Size                = gl.TEXTURE_DEPTH_SIZE,
	Texture_Stencil_Size              = gl.TEXTURE_STENCIL_SIZE,
	Texture_Compressed                = gl.TEXTURE_COMPRESSED,
	Texture_Compressed_Image_Size     = gl.TEXTURE_COMPRESSED_IMAGE_SIZE,
	Texture_Buffer_Data_Store_Binding = gl.TEXTURE_BUFFER_DATA_STORE_BINDING,
	Texture_Buffer_Offset             = gl.TEXTURE_BUFFER_OFFSET,
	Texture_Buffer_Size               = gl.TEXTURE_BUFFER_SIZE,
}

/* void GetTexLevelParameterfv(enum target, int level, enum pname, T *params); */
// target: Tex_Level_Parameter_Target
// pname:  Tex_Level_Parameter

/* void GetTextureLevelParameteriv(uint texture, int level, enum pname, T *params); */
// pname: Tex_Level_Parameter

/* void GetTextureLevelParameterfv(uint texture, int level, enum pname, T *params); */
// pname: Tex_Level_Parameter

/* void GetTexImage(enum target, int level, enum format, enum type, void *pixels); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

Get_Tex_Image_Target :: enum u32 {
	Texture_1D                  = gl.TEXTURE_1D,
	Texture_2D                  = gl.TEXTURE_2D,
	Texture_3D                  = gl.TEXTURE_3D,
	Texture_1D_Array            = gl.TEXTURE_1D_ARRAY,
	Texture_2D_Array            = gl.TEXTURE_2D_ARRAY,
	Texture_Cube_Map_Array      = gl.TEXTURE_CUBE_MAP_ARRAY,
	Texture_Rectangle           = gl.TEXTURE_RECTANGLE,
	Texture_Cube_Map_Positive_X = gl.TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y = gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z = gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X = gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z,
}

/* void GetTextureImage(uint texture, int level, enum format, enum type, sizei bufSize, void *pixels); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void GetnTexImage(enum tex, int level, enum format, enum type, sizei bufSize, void *pixels); */
// target: Get_Tex_Image_Target
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void GetTextureSubImage(uint texture, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, enum format, enum type, sizei bufSize, void *pixels); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void GetCompressedTexImage(enum target, int level, void *pixels); */
// target: Get_Tex_Image_Target

// TODO(tarik): Remove this if no enum for int level will be created
/* void GetCompressedTextureImage(uint texture, int level, sizei bufSize, void *pixels); */

/* void GetnCompressedTexImage(enum target, int level, sizei bufsize, void *pixels); */
// target: Get_Tex_Image_Target

// TODO(tarik): Remove this if no enum for int level will be created
/* void GetCompressedTextureSubImage(uint texture, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, sizei bufSize, void *pixels); */


/* Manual Mipmap Generation [8.14.4] */

/* void GenerateMipmap(enum target); */
Generate_Mipmap_Target :: enum u32 {
	Texture_1D             = gl.TEXTURE_1D,
	Texture_2D             = gl.TEXTURE_2D,
	Texture_3D             = gl.TEXTURE_3D,
	Texture_1D_Array       = gl.TEXTURE_1D_ARRAY,
	Texture_2D_Array       = gl.TEXTURE_2D_ARRAY,
	Texture_Cube_Map       = gl.TEXTURE_CUBE_MAP,
	Texture_Cube_Map_Array = gl.TEXTURE_CUBE_MAP_ARRAY,
}


/* Texture Views [8.18] */

/* void TextureView(uint texture, enum target, uint origtexture, enum internalformat, uint minlevel, uint numlevels, uint minlayer, uint numlayers); */
Texture_View_Target :: enum u32 {
	Texture_1D                   = gl.TEXTURE_1D,
	Texture_1D_Array             = gl.TEXTURE_1D_ARRAY,
	Texture_2D                   = gl.TEXTURE_2D,
	Texture_2D_Array             = gl.TEXTURE_2D_ARRAY,
	Texture_Rectangle            = gl.TEXTURE_RECTANGLE,
	Texture_3D                   = gl.TEXTURE_3D,
	Texture_Cube_Map             = gl.TEXTURE_CUBE_MAP,
	Texture_Cube_Map_Array       = gl.TEXTURE_CUBE_MAP_ARRAY,
	Texture_2D_Multisample       = gl.TEXTURE_2D_MULTISAMPLE,
	Texture_2D_Multisample_Array = gl.TEXTURE_2D_MULTISAMPLE_ARRAY,
}

Texture_View_Internalformat :: enum u32 {
	RGBA32f                            = gl.RGBA32F,
	RGBA32ui                           = gl.RGBA32UI,
	RGBA32i                            = gl.RGBA32I,
	RGB32f                             = gl.RGB32F,
	RGB32ui                            = gl.RGB32UI,
	RGB32i                             = gl.RGB32I,
	RGBA16f                            = gl.RGBA16F,
	RG32f                              = gl.RG32F,
	RGBA16ui                           = gl.RGBA16UI,
	RG32ui                             = gl.RG32UI,
	RGBA16i                            = gl.RGBA16I,
	RG32i                              = gl.RG32I,
	RGBA16                             = gl.RGBA16,
	RGBA16_Snorm                       = gl.RGBA16_SNORM,
	RGB16                              = gl.RGB16,
	RGB16_Snorm                        = gl.RGB16_SNORM,
	RGB16f                             = gl.RGB16F,
	RGB16ui                            = gl.RGB16UI,
	RGB16i                             = gl.RGB16I,
	RG16f                              = gl.RG16F,
	R11f_G11f_B10f                     = gl.R11F_G11F_B10F,
	R32f                               = gl.R32F,
	RGB10_A2ui                         = gl.RGB10_A2UI,
	RGBA8ui                            = gl.RGBA8UI,
	RG16ui                             = gl.RG16UI,
	R32ui                              = gl.R32UI,
	RGBA8i                             = gl.RGBA8I,
	RG16i                              = gl.RG16I,
	R32i                               = gl.R32I,
	RGB10_A2                           = gl.RGB10_A2,
	RGBA8                              = gl.RGBA8,
	RG16                               = gl.RG16,
	RGBA8_Snorm                        = gl.RGBA8_SNORM,
	RG16_Snorm                         = gl.RG16_SNORM,
	SRGB8_Alpha8                       = gl.SRGB8_ALPHA8,
	RGB9_E5                            = gl.RGB9_E5,
	RGB8                               = gl.RGB8,
	RGB8_Snorm                         = gl.RGB8_SNORM,
	SRGB8                              = gl.SRGB8,
	RGB8ui                             = gl.RGB8UI,
	RGB8i                              = gl.RGB8I,
	R16f                               = gl.R16F,
	RG8ui                              = gl.RG8UI,
	R16ui                              = gl.R16UI,
	RG8i                               = gl.RG8I,
	R16i                               = gl.R16I,
	RG8                                = gl.RG8,
	R16                                = gl.R16,
	RG8_Snorm                          = gl.RG8_SNORM,
	R16_Snorm                          = gl.R16_SNORM,
	R8ui                               = gl.R8UI,
	R8i                                = gl.R8I,
	R8                                 = gl.R8,
	R8_Snorm                           = gl.R8_SNORM,
	Compressed_Red_RGTC1               = gl.COMPRESSED_RED_RGTC1,
	Compressed_Signed_Red_RGTC1        = gl.COMPRESSED_SIGNED_RED_RGTC1,
	Compressed_RG_RGTC2                = gl.COMPRESSED_RG_RGTC2,
	Compressed_Signed_RG_RGTC2         = gl.COMPRESSED_SIGNED_RG_RGTC2,
	Compressed_Rgba_BPTC_Unorm         = gl.COMPRESSED_RGBA_BPTC_UNORM,
	Compressed_SRGB_Alpha_BPTC_Unorm   = gl.COMPRESSED_SRGB_ALPHA_BPTC_UNORM,
	Compressed_RGB_BPTC_Signed_Float   = gl.COMPRESSED_RGB_BPTC_SIGNED_FLOAT,
	Compressed_RGB_BPTC_Unsigned_Float = gl.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT,
}


/* Immutable-Format Tex. Images [8.19] */

/* void TexStorage1D(enum target, sizei levels, enum internalformat, sizei width); */
Tex_Storage_1D_Target :: enum u32 {
	Texture_1D       = gl.TEXTURE_1D,
	Proxy_Texture_1D = gl.PROXY_TEXTURE_1D,
}

Tex_Storage_Internalformat :: enum u32 {
	// Color-Renderable
	Red                = gl.RED,
	RG                 = gl.RG,
	RGB                = gl.RGB,
	RGBA               = gl.RGBA,
	R8                 = gl.R8,
	R8_Snorm           = gl.R8_SNORM,
	R16                = gl.R16,
	R16_Snorm          = gl.R16_SNORM,
	RG8                = gl.RG8,
	RG8_Snorm          = gl.RG8_SNORM,
	RG16               = gl.RG16,
	RG16_Snorm         = gl.RG16_SNORM,
	R3_G3_B2           = gl.R3_G3_B2,
	RGB4               = gl.RGB4,
	RGB5               = gl.RGB5,
	RGB565             = gl.RGB5,
	RGB8               = gl.RGB8,
	RGB8_Snorm         = gl.RGB8_SNORM,
	RGB10              = gl.RGB10,
	RGB12              = gl.RGB12,
	RGB16              = gl.RGB16,
	RGB16_Snorm        = gl.RGB16_SNORM,
	RGBA2              = gl.RGBA2,
	RGBA4              = gl.RGBA4,
	RGB5_A1            = gl.RGB5_A1,
	RGBA8              = gl.RGBA8,
	RGBA8_Snorm        = gl.RGBA8_SNORM,
	RGB10_A2           = gl.RGB10_A2,
	RGB10_A2ui         = gl.RGB10_A2UI,
	RGBA12             = gl.RGBA12,
	RGBA16             = gl.RGBA16,
	RGBA16_Snorm       = gl.RGBA16_SNORM,
	SRGB8              = gl.SRGB8,
	SRGB8_Alpha8       = gl.SRGB8_ALPHA8,
	R16f               = gl.R16F,
	RG16f              = gl.RG16F,
	RGB16f             = gl.RGB16F,
	RGBA16f            = gl.RGBA16F,
	R32f               = gl.R32F,
	RG32f              = gl.RG32F,
	RGB32f             = gl.RGB32F,
	RGBA32f            = gl.RGBA32F,
	R11f_G11f_B10f     = gl.R11F_G11F_B10F,
	R8i                = gl.R8I,
	R8ui               = gl.R8UI,
	R16i               = gl.R16I,
	R16ui              = gl.R16UI,
	R32i               = gl.R32I,
	R32ui              = gl.R32UI,
	RG8i               = gl.RG8I,
	RG8ui              = gl.RG8UI,
	RG16i              = gl.RG16I,
	RG16ui             = gl.RG16UI,
	RG32i              = gl.RG32I,
	RG32ui             = gl.RG32UI,
	RGB8i              = gl.RGB8I,
	RGB8ui             = gl.RGB8UI,
	RGB16i             = gl.RGB16I,
	RGB16ui            = gl.RGB16UI,
	RGB32i             = gl.RGB32I,
	RGB32ui            = gl.RGB32UI,
	RGBA8i             = gl.RGBA8I,
	RGBA8ui            = gl.RGBA8UI,
	RGBA16i            = gl.RGBA16I,
	RGBA16ui           = gl.RGBA16UI,
	RGBA32i            = gl.RGBA32I,
	RGBA32ui           = gl.RGBA32UI,

	// TODO(tarik): Marked fields are a not required format and not included
	// in the Ref. Card. Read 8.5.1 for more info.

	// Depth-Renderable
	Depth_Component16  = gl.DEPTH_COMPONENT16,
	Depth_Component24  = gl.DEPTH_COMPONENT24,
	// Depth_Component32  = gl.DEPTH_COMPONENT32, // *
	Depth_Component32f = gl.DEPTH_COMPONENT32F,
	Depth24_Stencil8   = gl.DEPTH24_STENCIL8,
	Depth32f_Stencil8  = gl.DEPTH32F_STENCIL8,

	// Stencil-Renderable
	// Stencil_Index1     = gl.STENCIL_INDEX1,    // *
	// Stencil_Index4     = gl.STENCIL_INDEX4,    // *
	Stencil_Index8     = gl.STENCIL_INDEX8,
	// Stencil_Index16    = gl.STENCIL_INDEX16,   // *
}

/* void TexStorage2D(enum target, sizei levels, enum internalformat, sizei width, sizei height); */
// internalformat: Tex_Storage_Internalformat

Tex_Storage_2D_Target :: enum u32 {
	Texture_1D_Array        = gl.TEXTURE_1D_ARRAY,
	Texture_2D              = gl.TEXTURE_2D,
	Texture_Rectangle       = gl.TEXTURE_RECTANGLE,
	Texture_Cube_Map        = gl.TEXTURE_CUBE_MAP,
	Proxy_Texture_1D_Array  = gl.PROXY_TEXTURE_1D_ARRAY,
	Proxy_Texture_2D        = gl.PROXY_TEXTURE_2D,
	Proxy_Texture_Rectangle = gl.PROXY_TEXTURE_RECTANGLE,
	Proxy_Texture_Cube_Map  = gl.PROXY_TEXTURE_CUBE_MAP,
}

/* void TexStorage3D(enum target, sizei levels, enum internalformat, sizei width, sizei height, sizei depth); */
// internalformat: Tex_Storage_Internalformat

Tex_Storage_3D_Target :: enum u32 {
	Texture_2D_Array             = gl.TEXTURE_2D_ARRAY,
	Texture_3D                   = gl.TEXTURE_3D,
	Texture_Cube_Map_Array       = gl.TEXTURE_CUBE_MAP_ARRAY,
	Proxy_Texture_2D_Array       = gl.PROXY_TEXTURE_2D_ARRAY,
	Proxy_Texture_3D             = gl.PROXY_TEXTURE_3D,
	Proxy_Texture_Cube_Map_Array = gl.PROXY_TEXTURE_CUBE_MAP_ARRAY,
}

/* void TextureStorage1D(uint texture, sizei levels, enum internalformat, sizei width); */
// internalformat: Tex_Storage_Internalformat

/* void TextureStorage2D(uint texture, sizei levels, enum internalformat, sizei width, sizei height); */
// internalformat: Tex_Storage_Internalformat

/* void TextureStorage3D(uint texture, sizei levels, enum internalformat, sizei width, sizei height, sizei depth); */
// internalformat: Tex_Storage_Internalformat

/* void TexStorage2DMultisample(enum target, sizei samples, enum internalformat, sizei width, sizei height, boolean fixedsamplelocations); */
// target: Tex_2D_Multisample_Target
// internalformat: Tex_Storage_Internalformat

/* void TexStorage3DMultisample(enum target, sizei samples, enum internalformat, sizei width, sizei height, sizei depth, boolean fixedsamplelocations); */
// target: Tex_3D_Multisample_Target
// internalformat: Tex_Storage_Internalformat

/* void TextureStorage2DMultisample(uint texture, sizei samples, enum internalformat, sizei width, sizei height, boolean fixedsamplelocations); */
// internalformat: Tex_Storage_Internalformat

/* void TextureStorage3DMultisample(uint texture, sizei samples, enum internalformat, sizei width, sizei height, sizei depth, boolean fixedsamplelocations); */
// internalformat: Tex_Storage_Internalformat


/* Clear Texture Image Data [8.21] */

/* void ClearTexSubImage(uint texture, int level, int xoffset, int yoffset, int zoffset, sizei width, sizei height, sizei depth, enum format, enum type, const void *data); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type

/* void ClearTexImage(uint texture, int level, enum format, enum type, const void *data); */
// format: Pixel_Data_Format
// type:   Pixel_Data_Type


/* Texture Image Loads/Stores [8.26] */

/* void BindImageTexture(uint index, uint texture, int level, boolean layered, int layer, enum access, enum format); */
// access: Access (from other file)

Image_Unit_Format :: enum u32 {
	RGBA32f        = gl.RGBA32F,
	RGBA16f        = gl.RGBA16F,
	RG32f          = gl.RG32F,
	RG16f          = gl.RG16F,
	R11f_G11f_B10f = gl.R11F_G11F_B10F,
	R32f           = gl.R32F,
	R16f           = gl.R16F,
	RGBA32ui       = gl.RGBA32UI,
	RGBA16ui       = gl.RGBA16UI,
	RGB10_A2ui     = gl.RGB10_A2UI,
	RGBA8ui        = gl.RGBA8UI,
	RG32ui         = gl.RG32UI,
	RG16ui         = gl.RG16UI,
	RG8ui          = gl.RG8UI,
	R32ui          = gl.R32UI,
	R16ui          = gl.R16UI,
	R8ui           = gl.R8UI,
	RGBA32i        = gl.RGBA32I,
	RGBA16i        = gl.RGBA16I,
	RGBA8i         = gl.RGBA8I,
	RG32i          = gl.RG32I,
	RG16i          = gl.RG16I,
	RG8i           = gl.RG8I,
	R32i           = gl.R32I,
	R16i           = gl.R16I,
	R8i            = gl.R8I,
	RGBA16         = gl.RGBA16,
	RGB10_A2       = gl.RGB10_A2,
	RGBA8          = gl.RGBA8,
	RG16           = gl.RG16,
	RG8            = gl.RG8,
	R16            = gl.R16,
	R8             = gl.R8,
	RGBA16_Snorm   = gl.RGBA16_SNORM,
	RGBA8_Snorm    = gl.RGBA8_SNORM,
	RG16_Snorm     = gl.RG16_SNORM,
	RG8_Snorm      = gl.RG8_SNORM,
	R16_Snorm      = gl.R16_SNORM,
	R8_Snorm       = gl.R8_SNORM,
}
