package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_vertex_post_processing.odin

/* Transform Feedback [13.2] */

/* void BindTransformFeedback(enum target, uint id); */
Transform_Feedback_Target :: enum u32 {
	Transform_Feedback = gl.TRANSFORM_FEEDBACK,
}

/* void BeginTransformFeedback(enum primitiveMode); */
Transform_Feedback_Primitive_Mode :: enum u32 {
	Triangles = gl.TRIANGLES,
	Lines     = gl.LINES,
	Points    = gl.POINTS,
}


/* Transform Feedback Drawing [13.2.3] */

/* void DrawTransformFeedback(enum mode, uint id); */
// mode: Draw_Mode (from other file)

/* void DrawTransformFeedbackInstanced(enum mode, uint id, sizei instancecount); */
// mode: Draw_Mode (from other file)

/* void DrawTransformFeedbackStream(enum mode, uint id, uint stream); */
// mode: Draw_Mode (from other file)

/* DrawTransformFeedbackStreamInstanced(enum mode, uint id, uint stream, sizei instancecount); */
// mode: Draw_Mode (from other file)


/* Flatshading [13.4] */

/* void ProvokingVertex(enum provokeMode); */
Provoking_Vertex_Mode :: enum u32 {
	First_Vertex_Convention = gl.FIRST_VERTEX_CONVENTION,
	Last_Vertex_Convention  = gl.LAST_VERTEX_CONVENTION,
}


/* Primitive Clipping [13.5] */

/* void ClipControl(enum origin, enum depth); */
Clip_Control_Origin :: enum u32 {
	Lower_Left = gl.LOWER_LEFT,
	Upper_Left = gl.UPPER_LEFT,
}

Clip_Control_Depth :: enum u32 {
	Negative_One_To_One = gl.NEGATIVE_ONE_TO_ONE,
	Zero_To_One         = gl.ZERO_TO_ONE,
}
