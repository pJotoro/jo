package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_debug_output.odin

/* Debug Message Callback [20.2] */

/* void DebugMessageCallback(DEBUGPROC callback, const void *userParam); */
Debug_Proc_T :: #type proc "c" (source: Debug_Source, type: Debug_Type, id: u32, severity: Debug_Severity, length: i32, message: cstring, userParam: rawptr)

Debug_Source :: enum u32 {
	Debug_Source_API             = gl.DEBUG_SOURCE_API,
	Debug_Source_Shader_Compiler = gl.DEBUG_SOURCE_SHADER_COMPILER,
	Debug_Source_Window_System   = gl.DEBUG_SOURCE_WINDOW_SYSTEM,
	Debug_Source_Third_Party     = gl.DEBUG_SOURCE_THIRD_PARTY,
	Debug_Source_Application     = gl.DEBUG_SOURCE_APPLICATION,
	Debug_Source_Other           = gl.DEBUG_SOURCE_OTHER,
	Dont_Care                    = gl.DONT_CARE,
}

Debug_Type :: enum u32 {
	Debug_Type_Error               = gl.DEBUG_TYPE_ERROR,
	Debug_Type_Deprecated_Behavior = gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR,
	Debug_Type_Undefined_Behavior  = gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR,
	Debug_Type_Performance         = gl.DEBUG_TYPE_PERFORMANCE,
	Debug_Type_Portability         = gl.DEBUG_TYPE_PORTABILITY,
	Debug_Type_Marker              = gl.DEBUG_TYPE_MARKER,
	Debug_Type_Push_Group          = gl.DEBUG_TYPE_PUSH_GROUP,
	Debug_Type_Pop_Group           = gl.DEBUG_TYPE_POP_GROUP,
	Debug_Type_Other               = gl.DEBUG_TYPE_OTHER,
	Dont_Care                      = gl.DONT_CARE,
}

Debug_Severity :: enum u32 {
	Debug_Severity_High         = gl.DEBUG_SEVERITY_HIGH,
	Debug_Severity_Medium       = gl.DEBUG_SEVERITY_MEDIUM,
	Debug_Severity_Low          = gl.DEBUG_SEVERITY_LOW,
	Debug_Severity_Notification = gl.DEBUG_SEVERITY_NOTIFICATION,
	Dont_Care                   = gl.DONT_CARE,
}


/* Controlling Debug Messages [20.4] */

/* void DebugMessageControl(enum source, enum type, enum severity, sizei count, const uint *ids, boolean enabled); */
// source:   Debug_Source
// type:     Debug_Type
// severity: Debug_Severity


/* Externally Generated Messages [20.5] */

/* void DebugMessageInsert(enum source, enum type, uint id, enum severity, int length, const char *buf); */
Debug_Insert_Source :: enum u32 {
	Debug_Source_Application = gl.DEBUG_SOURCE_APPLICATION,
	Debug_Source_Third_Party = gl.DEBUG_SOURCE_THIRD_PARTY,
}

Debug_Insert_Type :: enum u32 {
	Debug_Type_Error               = gl.DEBUG_TYPE_ERROR,
	Debug_Type_Deprecated_Behavior = gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR,
	Debug_Type_Undefined_Behavior  = gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR,
	Debug_Type_Performance         = gl.DEBUG_TYPE_PERFORMANCE,
	Debug_Type_Portability         = gl.DEBUG_TYPE_PORTABILITY,
	Debug_Type_Marker              = gl.DEBUG_TYPE_MARKER,
	Debug_Type_Push_Group          = gl.DEBUG_TYPE_PUSH_GROUP,
	Debug_Type_Pop_Group           = gl.DEBUG_TYPE_POP_GROUP,
	Debug_Type_Other               = gl.DEBUG_TYPE_OTHER,
}

Debug_Insert_Severity :: enum u32 {
	Debug_Severity_High         = gl.DEBUG_SEVERITY_HIGH,
	Debug_Severity_Medium       = gl.DEBUG_SEVERITY_MEDIUM,
	Debug_Severity_Low          = gl.DEBUG_SEVERITY_LOW,
	Debug_Severity_Notification = gl.DEBUG_SEVERITY_NOTIFICATION,
}


/* Debug Groups [20.6] */

/* void PushDebugGroup(enum source, uint id, sizei length, const char *message); */
Push_Debug_Group_Source :: Debug_Insert_Source

/* Debug Labels [20.7] */

/* void ObjectLabel(enum identifier, uint name, sizei length, const char *label); */
Object_Label_Identifier :: enum u32 {
	Buffer             = gl.BUFFER,
	Framebuffer        = gl.FRAMEBUFFER,
	Program_Pipeline   = gl.PROGRAM_PIPELINE,
	Program            = gl.PROGRAM,
	Query              = gl.QUERY,
	Renderbuffer       = gl.RENDERBUFFER,
	Sampler            = gl.SAMPLER,
	Shader             = gl.SHADER,
	Texture            = gl.TEXTURE,
	Transform_Feedback = gl.TRANSFORM_FEEDBACK,
	Vertex_Array       = gl.VERTEX_ARRAY,
}


/* Debug Output Queries [20.9] */

/* uint GetDebugMessageLog(uint count, sizei bufSize, enum *sources, enum *types, uint *ids, enum *severities, sizei lengths, char *messageLog); */
Debug_Log_Source   :: Debug_Insert_Source
Debug_Log_Type     :: Debug_Insert_Type
Debug_Log_Severity :: Debug_Insert_Severity

/* void GetObjectLabel(enum identifier, uint name, sizei bufSize, sizei *length, char *label); */
// identifier: Object_Label_Identifier
