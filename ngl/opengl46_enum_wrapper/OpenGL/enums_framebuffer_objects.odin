package vendor_gl

/* Binding and Managing [9.2] */

/* void BindFramebuffer(enum target, uint framebuffer); */
Framebuffer_Target :: enum u32 {
	Draw_Framebuffer = DRAW_FRAMEBUFFER,
	Read_Framebuffer = READ_FRAMEBUFFER,
	Framebuffer      = FRAMEBUFFER,
}


/* Framebuffer Object Parameters [9.2.1] */

/* void FramebufferParameteri(enum target, enum pname, int param); */
// target: Framebuffer_Target

Framebuffer_Parameteri :: enum u32 {
	Framebuffer_Default_Width                  = FRAMEBUFFER_DEFAULT_WIDTH,
	Framebuffer_Default_Height                 = FRAMEBUFFER_DEFAULT_HEIGHT,
	Framebuffer_Default_Layers                 = FRAMEBUFFER_DEFAULT_LAYERS,
	Framebuffer_Default_Samples                = FRAMEBUFFER_DEFAULT_SAMPLES,
	Framebuffer_Default_Fixed_Sample_Locations = FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS,
}

/* void NamedFramebufferParameteri(uint framebuffer, enum pname, int param); */
// pname: Framebuffer_Parameteri


/* Framebuffer Object Queries [9.2.3] */

/* void GetFramebufferParameteriv(enum target, enum pname, int *params); */
// target: Framebuffer_Target

Framebuffer_Parameteriv :: enum u32 {
	Framebuffer_Default_Width                  = FRAMEBUFFER_DEFAULT_WIDTH,
	Framebuffer_Default_Height                 = FRAMEBUFFER_DEFAULT_HEIGHT,
	Framebuffer_Default_Layers                 = FRAMEBUFFER_DEFAULT_LAYERS,
	Framebuffer_Default_Samples                = FRAMEBUFFER_DEFAULT_SAMPLES,
	Framebuffer_Default_Fixed_Sample_Locations = FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS,

	Doublebuffer                               = DOUBLEBUFFER,
	Implementation_Color_Read_Format           = IMPLEMENTATION_COLOR_READ_FORMAT,
	Implementation_Color_Read_Type             = IMPLEMENTATION_COLOR_READ_TYPE,
	Samples                                    = SAMPLES,
	Sample_Buffers                             = SAMPLE_BUFFERS,
	Stereo                                     = STEREO,
}

/* void GetNamedFramebufferParameteriv(uint framebuffer, enum pname, int *params); */
// pname: Framebuffer_Parameteriv

/* void GetFramebufferAttachmentParameteriv(enum target, enum attachment, enum pname, int *params); */
// target: Framebuffer_Target

Framebuffer_Attachment :: enum u32 {
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

Framebuffer_Attachment_Parameter :: enum u32 {
	Framebuffer_Attachment_Red_Size              = FRAMEBUFFER_ATTACHMENT_RED_SIZE,
	Framebuffer_Attachment_Green_Size            = FRAMEBUFFER_ATTACHMENT_GREEN_SIZE,
	Framebuffer_Attachment_Blue_Size             = FRAMEBUFFER_ATTACHMENT_BLUE_SIZE,
	Framebuffer_Attachment_Alpha_Size            = FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE,
	Framebuffer_Attachment_Depth_Size            = FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE,
	Framebuffer_Attachment_Stencil_Size          = FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE,
	Framebuffer_Attachment_Component_Type        = FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE,
	Framebuffer_Attachment_Color_Encoding        = FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING,
	Framebuffer_Attachment_Object_Name           = FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
	Framebuffer_Attachment_Object_Type           = FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
	Framebuffer_Attachment_Texture_Level         = FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL,
	Framebuffer_Attachment_Texture_Cube_Map_Face = FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE,
	Framebuffer_Attachment_Layered               = FRAMEBUFFER_ATTACHMENT_LAYERED,
	Framebuffer_Attachment_Texture_Layer         = FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER,
}

/* void GetNamedFramebufferAttachmentParameteriv(uint framebuffer, enum attachment, enum pname, int *params); */
// attachment: Framebuffer_Attachment
// pname:      Framebuffer_Attachment_Parameter


/* Renderbuffer Objects [9.2.4] */

/* void BindRenderbuffer(enum target, uint renderbuffer); */
Renderbuffer_Target :: enum u32 {
	Renderbuffer = RENDERBUFFER,
}

/* void RenderbufferStorageMultisample(enum target, sizei samples, enum internalformat, sizei width, sizei height); */
// target:         Renderbuffer_Target
// internalformat: Color_Depth_Stencil_Renderable_Format (from other file)

/* void NamedRenderbufferStorageMultisample(uint renderbuffer, sizei samples, enum internalformat, sizei width, sizei height); */
// internalformat: Color_Depth_Stencil_Renderable_Format (from other file)

/* void RenderbufferStorage(enum target, enum internalformat, sizei width, sizei height); */
// target:         Renderbuffer_Target
// internalformat: Color_Depth_Stencil_Renderable_Format (from other file)

/* void NamedRenderbufferStorage(uint renderbuffer, enum internalformat, sizei width, sizei height); */
// internalformat: Color_Depth_Stencil_Renderable_Format (from other file)


/* Renderbuffer Object Queries [9.2.6] */

/* void GetRenderbufferParameteriv(enum target, enum pname, int *params); */
// target: Renderbuffer_Target
Renderbuffer_Parameter :: enum u32 {
	Renderbuffer_Width           = RENDERBUFFER_WIDTH,
	Renderbuffer_Height          = RENDERBUFFER_HEIGHT,
	Renderbuffer_Internal_Format = RENDERBUFFER_INTERNAL_FORMAT,
	Renderbuffer_Red_Size        = RENDERBUFFER_RED_SIZE,
	Renderbuffer_Green_Size      = RENDERBUFFER_GREEN_SIZE,
	Renderbuffer_Blue_Size       = RENDERBUFFER_BLUE_SIZE,
	Renderbuffer_Alpha_Size      = RENDERBUFFER_ALPHA_SIZE,
	Renderbuffer_Depth_Size      = RENDERBUFFER_DEPTH_SIZE,
	Renderbuffer_Stencil_Size    = RENDERBUFFER_STENCIL_SIZE,
	Renderbuffer_Samples         = RENDERBUFFER_SAMPLES,
}

/* void GetNamedRenderbufferParameteriv(uint renderbuffer, enum pname, int *params); */
// pname: Renderbuffer_Parameter


/* Attaching Renderbuffer Images [9.2.7] */

/* void FramebufferRenderbuffer(enum target, enum attachment, enum renderbuffertarget, uint renderbuffer); */
// target:             Framebuffer_Target
// renderbuffertarget: Renderbuffer_Target

Framebuffer_Renderbuffer_Attachment :: enum u32 {
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

/* void NamedFramebufferRenderbuffer(uint framebuffer, enum attachment, enum renderbuffertarget, uint renderbuffer); */
// attachment:         Framebuffer_Renderbuffer_Attachment
// renderbuffertarget: Renderbuffer_Target


/* Attaching Texture Images [9.2.8] */

/* void FramebufferTexture(enum target, enum attachment, uint texture, int level); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

/* void NamedFramebufferTexture(uint framebuffer, enum attachment, uint texture, int level); */
// attachment: Framebuffer_Renderbuffer_Attachment

/* void FramebufferTexture1D(enum target, enum attachment, enum textarget, uint texture, int level); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

Framebuffer_Texture_1D_Target :: enum u32 {
	Texture_1D = TEXTURE_1D,
}

/* void FramebufferTexture2D(enum target, enum attachment, enum textarget, uint texture, int level); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

Framebuffer_Texture_2D_Target :: enum u32 {
	Texture_2D                  = TEXTURE_2D,
	Texture_2D_Multisample      = TEXTURE_2D_MULTISAMPLE,
	Texture_Rectangle           = TEXTURE_RECTANGLE,
	Texture_Cube_Map_Positive_X = TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y = TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z = TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X = TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y = TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z = TEXTURE_CUBE_MAP_NEGATIVE_Z,
}

/* void FramebufferTexture3D(enum target, enum attachment, enum textarget, uint texture, int level, int layer); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

Framebuffer_Texture_3D_Target :: enum u32 {
	Texture_3D = TEXTURE_3D,
}

/* void FramebufferTextureLayer(enum target, enum attachment, uint texture, int level, int layer); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

/* void NamedFramebufferTextureLayer(uint framebuffer, enum attachment, uint texture, int level, int layer); */
// attachment: Framebuffer_Renderbuffer_Attachment


/* Framebuffer Completeness [9.4.2] */

/* enum CheckFramebufferStatus(enum target); */
// target: Framebuffer_Target

Framebuffer_Status :: enum u32 {
	Framebuffer_Complete                      = FRAMEBUFFER_COMPLETE,
	Framebuffer_Undefined                     = FRAMEBUFFER_UNDEFINED,
	Framebuffer_Incomplete_Attachment         = FRAMEBUFFER_INCOMPLETE_ATTACHMENT,
	Framebuffer_Incomplete_Missing_Attachment = FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,
	Framebuffer_Unsupported                   = FRAMEBUFFER_UNSUPPORTED,
	Framebuffer_Incomplete_Multisample        = FRAMEBUFFER_INCOMPLETE_MULTISAMPLE,
	Framebuffer_Incomplete_Layer_Targets      = FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS,
}

/* enum CheckNamedFramebufferStatus(uint framebuffer, enum target); */
// target:  Framebuffer_Target
// returns: Framebuffer_Status
