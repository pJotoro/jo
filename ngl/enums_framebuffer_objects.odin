package ngl

import gl "vendor:OpenGL"

/* Binding and Managing [9.2] */

/* void BindFramebuffer(enum target, uint framebuffer); */
Framebuffer_Target :: enum u32 {
	Draw_Framebuffer = gl.DRAW_FRAMEBUFFER,
	Read_Framebuffer = gl.READ_FRAMEBUFFER,
	Framebuffer      = gl.FRAMEBUFFER,
}


/* Framebuffer Object Parameters [9.2.1] */

/* void FramebufferParameteri(enum target, enum pname, int param); */
// target: Framebuffer_Target

Framebuffer_Parameteri :: enum u32 {
	Framebuffer_Default_Width                  = gl.FRAMEBUFFER_DEFAULT_WIDTH,
	Framebuffer_Default_Height                 = gl.FRAMEBUFFER_DEFAULT_HEIGHT,
	Framebuffer_Default_Layers                 = gl.FRAMEBUFFER_DEFAULT_LAYERS,
	Framebuffer_Default_Samples                = gl.FRAMEBUFFER_DEFAULT_SAMPLES,
	Framebuffer_Default_Fixed_Sample_Locations = gl.FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS,
}

/* void NamedFramebufferParameteri(uint framebuffer, enum pname, int param); */
// pname: Framebuffer_Parameteri


/* Framebuffer Object Queries [9.2.3] */

/* void GetFramebufferParameteriv(enum target, enum pname, int *params); */
// target: Framebuffer_Target

Framebuffer_Parameteriv :: enum u32 {
	Framebuffer_Default_Width                  = gl.FRAMEBUFFER_DEFAULT_WIDTH,
	Framebuffer_Default_Height                 = gl.FRAMEBUFFER_DEFAULT_HEIGHT,
	Framebuffer_Default_Layers                 = gl.FRAMEBUFFER_DEFAULT_LAYERS,
	Framebuffer_Default_Samples                = gl.FRAMEBUFFER_DEFAULT_SAMPLES,
	Framebuffer_Default_Fixed_Sample_Locations = gl.FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS,

	Doublebuffer                               = gl.DOUBLEBUFFER,
	Implementation_Color_Read_Format           = gl.IMPLEMENTATION_COLOR_READ_FORMAT,
	Implementation_Color_Read_Type             = gl.IMPLEMENTATION_COLOR_READ_TYPE,
	Samples                                    = gl.SAMPLES,
	Sample_Buffers                             = gl.SAMPLE_BUFFERS,
	Stereo                                     = gl.STEREO,
}

/* void GetNamedFramebufferParameteriv(uint framebuffer, enum pname, int *params); */
// pname: Framebuffer_Parameteriv

/* void GetFramebufferAttachmentParameteriv(enum target, enum attachment, enum pname, int *params); */
// target: Framebuffer_Target

Framebuffer_Attachment :: enum u32 {
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

Framebuffer_Attachment_Parameter :: enum u32 {
	Framebuffer_Attachment_Red_Size              = gl.FRAMEBUFFER_ATTACHMENT_RED_SIZE,
	Framebuffer_Attachment_Green_Size            = gl.FRAMEBUFFER_ATTACHMENT_GREEN_SIZE,
	Framebuffer_Attachment_Blue_Size             = gl.FRAMEBUFFER_ATTACHMENT_BLUE_SIZE,
	Framebuffer_Attachment_Alpha_Size            = gl.FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE,
	Framebuffer_Attachment_Depth_Size            = gl.FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE,
	Framebuffer_Attachment_Stencil_Size          = gl.FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE,
	Framebuffer_Attachment_Component_Type        = gl.FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE,
	Framebuffer_Attachment_Color_Encoding        = gl.FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING,
	Framebuffer_Attachment_Object_Name           = gl.FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
	Framebuffer_Attachment_Object_Type           = gl.FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE,
	Framebuffer_Attachment_Texture_Level         = gl.FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL,
	Framebuffer_Attachment_Texture_Cube_Map_Face = gl.FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE,
	Framebuffer_Attachment_Layered               = gl.FRAMEBUFFER_ATTACHMENT_LAYERED,
	Framebuffer_Attachment_Texture_Layer         = gl.FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER,
}

/* void GetNamedFramebufferAttachmentParameteriv(uint framebuffer, enum attachment, enum pname, int *params); */
// attachment: Framebuffer_Attachment
// pname:      Framebuffer_Attachment_Parameter


/* Renderbuffer Objects [9.2.4] */

/* void BindRenderbuffer(enum target, uint renderbuffer); */
Renderbuffer_Target :: enum u32 {
	Renderbuffer = gl.RENDERBUFFER,
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
	Renderbuffer_Width           = gl.RENDERBUFFER_WIDTH,
	Renderbuffer_Height          = gl.RENDERBUFFER_HEIGHT,
	Renderbuffer_Internal_Format = gl.RENDERBUFFER_INTERNAL_FORMAT,
	Renderbuffer_Red_Size        = gl.RENDERBUFFER_RED_SIZE,
	Renderbuffer_Green_Size      = gl.RENDERBUFFER_GREEN_SIZE,
	Renderbuffer_Blue_Size       = gl.RENDERBUFFER_BLUE_SIZE,
	Renderbuffer_Alpha_Size      = gl.RENDERBUFFER_ALPHA_SIZE,
	Renderbuffer_Depth_Size      = gl.RENDERBUFFER_DEPTH_SIZE,
	Renderbuffer_Stencil_Size    = gl.RENDERBUFFER_STENCIL_SIZE,
	Renderbuffer_Samples         = gl.RENDERBUFFER_SAMPLES,
}

/* void GetNamedRenderbufferParameteriv(uint renderbuffer, enum pname, int *params); */
// pname: Renderbuffer_Parameter


/* Attaching Renderbuffer Images [9.2.7] */

/* void FramebufferRenderbuffer(enum target, enum attachment, enum renderbuffertarget, uint renderbuffer); */
// target:             Framebuffer_Target
// renderbuffertarget: Renderbuffer_Target

// TODO(tarik): Find better name
Framebuffer_Renderbuffer_Attachment :: enum u32 {
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
	Texture_1D = gl.TEXTURE_1D,
}

/* void FramebufferTexture2D(enum target, enum attachment, enum textarget, uint texture, int level); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

Framebuffer_Texture_2D_Target :: enum u32 {
	Texture_2D                  = gl.TEXTURE_2D,
	Texture_2D_Multisample      = gl.TEXTURE_2D_MULTISAMPLE,
	Texture_Rectangle           = gl.TEXTURE_RECTANGLE,
	Texture_Cube_Map_Positive_X = gl.TEXTURE_CUBE_MAP_POSITIVE_X,
	Texture_Cube_Map_Positive_Y = gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
	Texture_Cube_Map_Positive_Z = gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
	Texture_Cube_Map_Negative_X = gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
	Texture_Cube_Map_Negative_Y = gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
	Texture_Cube_Map_Negative_Z = gl.TEXTURE_CUBE_MAP_NEGATIVE_Z,
}

/* void FramebufferTexture3D(enum target, enum attachment, enum textarget, uint texture, int level, int layer); */
// target:     Framebuffer_Target
// attachment: Framebuffer_Renderbuffer_Attachment

Framebuffer_Texture_3D_Target :: enum u32 {
	Texture_3D = gl.TEXTURE_3D,
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
	Framebuffer_Complete                      = gl.FRAMEBUFFER_COMPLETE,
	Framebuffer_Undefined                     = gl.FRAMEBUFFER_UNDEFINED,
	Framebuffer_Incomplete_Attachment         = gl.FRAMEBUFFER_INCOMPLETE_ATTACHMENT,
	Framebuffer_Incomplete_Missing_Attachment = gl.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,
	Framebuffer_Unsupported                   = gl.FRAMEBUFFER_UNSUPPORTED,
	Framebuffer_Incomplete_Multisample        = gl.FRAMEBUFFER_INCOMPLETE_MULTISAMPLE,
	Framebuffer_Incomplete_Layer_Targets      = gl.FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS,
}

/* enum CheckNamedFramebufferStatus(uint framebuffer, enum target); */
// target:  Framebuffer_Target
// returns: Framebuffer_Status
