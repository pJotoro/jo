package vendor_gl

/* Transform Feedback [13.2] */

/* void BindTransformFeedback(enum target, uint id); */
Transform_Feedback_Target :: enum u32 {
	Transform_Feedback = TRANSFORM_FEEDBACK,
}

/* void BeginTransformFeedback(enum primitiveMode); */
Transform_Feedback_Primitive_Mode :: enum u32 {
	Triangles = TRIANGLES,
	Lines     = LINES,
	Points    = POINTS,
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
	First_Vertex_Convention = FIRST_VERTEX_CONVENTION,
	Last_Vertex_Convention  = LAST_VERTEX_CONVENTION,
}


/* Primitive Clipping [13.5] */

/* void ClipControl(enum origin, enum depth); */
Clip_Control_Origin :: enum u32 {
	Lower_Left = LOWER_LEFT,
	Upper_Left = UPPER_LEFT,
}

Clip_Control_Depth :: enum u32 {
	Negative_One_To_One = NEGATIVE_ONE_TO_ONE,
	Zero_To_One         = ZERO_TO_ONE,
}
