package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_asynchronous_queries.odin

/* void CreateQueries(enum target, sizei n, uint *ids); */
Query_And_Timestamp_Target :: enum u32 {
	Any_Samples_Passed                    = gl.ANY_SAMPLES_PASSED,
	Any_Samples_Passed_Conservative       = gl.ANY_SAMPLES_PASSED_CONSERVATIVE,
	Primitives_Generated                  = gl.PRIMITIVES_GENERATED,
	Samples_Passed                        = gl.SAMPLES_PASSED,
	Time_Elapsed                          = gl.TIME_ELAPSED,
	Primitives_Submitted                  = gl.PRIMITIVES_SUBMITTED,
	Vertices_Submitted                    = gl.VERTICES_SUBMITTED,
	Transform_Feedback_Primitives_Written = gl.TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN,
	Transform_Feedback_Overflow           = gl.TRANSFORM_FEEDBACK_OVERFLOW,
	Transform_Feedback_Stream_Overflow    = gl.TRANSFORM_FEEDBACK_STREAM_OVERFLOW,
	Compute_Shader_Invocations            = gl.COMPUTE_SHADER_INVOCATIONS,
	Vertex_Shader_Invocations             = gl.VERTEX_SHADER_INVOCATIONS,
	Fragment_Shader_Invocations           = gl.FRAGMENT_SHADER_INVOCATIONS,
	Geometry_Shader_Invocations           = gl.GEOMETRY_SHADER_INVOCATIONS,
	Tess_Evaluation_Shader_Invocations    = gl.TESS_EVALUATION_SHADER_INVOCATIONS,
	Tess_Control_Shader_Patches           = gl.TESS_CONTROL_SHADER_PATCHES,
	Geometry_Shader_Primitives_Emitted    = gl.GEOMETRY_SHADER_PRIMITIVES_EMITTED,
	Clipping_Input_Primitives             = gl.CLIPPING_INPUT_PRIMITIVES,
	Clipping_Output_Primitives            = gl.CLIPPING_OUTPUT_PRIMITIVES,
	Timestamp                             = gl.TIMESTAMP,
}

/* void BeginQuery(enum target, uint id); */
Query_Target :: enum u32 {
	Any_Samples_Passed                    = gl.ANY_SAMPLES_PASSED,
	Any_Samples_Passed_Conservative       = gl.ANY_SAMPLES_PASSED_CONSERVATIVE,
	Primitives_Generated                  = gl.PRIMITIVES_GENERATED,
	Samples_Passed                        = gl.SAMPLES_PASSED,
	Time_Elapsed                          = gl.TIME_ELAPSED,
	Primitives_Submitted                  = gl.PRIMITIVES_SUBMITTED,
	Vertices_Submitted                    = gl.VERTICES_SUBMITTED,
	Transform_Feedback_Primitives_Written = gl.TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN,
	Transform_Feedback_Overflow           = gl.TRANSFORM_FEEDBACK_OVERFLOW,
	Transform_Feedback_Stream_Overflow    = gl.TRANSFORM_FEEDBACK_STREAM_OVERFLOW,
	Compute_Shader_Invocations            = gl.COMPUTE_SHADER_INVOCATIONS,
	Vertex_Shader_Invocations             = gl.VERTEX_SHADER_INVOCATIONS,
	Fragment_Shader_Invocations           = gl.FRAGMENT_SHADER_INVOCATIONS,
	Geometry_Shader_Invocations           = gl.GEOMETRY_SHADER_INVOCATIONS,
	Tess_Evaluation_Shader_Invocations    = gl.TESS_EVALUATION_SHADER_INVOCATIONS,
	Tess_Control_Shader_Patches           = gl.TESS_CONTROL_SHADER_PATCHES,
	Geometry_Shader_Primitives_Emitted    = gl.GEOMETRY_SHADER_PRIMITIVES_EMITTED,
	Clipping_Input_Primitives             = gl.CLIPPING_INPUT_PRIMITIVES,
	Clipping_Output_Primitives            = gl.CLIPPING_OUTPUT_PRIMITIVES,
}

/* void BeginQueryIndexed(enum target, uint index, uint id); */
// target: Query_Target

/* void EndQuery(enum target); */
// target: Query_Target

/* void EndQueryIndexed(enum target, uint index); */
// target: Query_Target

/* void GetQueryiv(enum target, enum pname, int *params); */
// target: Query_And_Timestamp_Target

Query_Parameter :: enum u32 {
	Current_Query      = gl.CURRENT_QUERY,
	Query_Counter_Bits = gl.QUERY_COUNTER_BITS,
}

/* void GetQueryIndexediv(enum target, uint index, enum pname, int *params); */
// target: Query_And_Timestamp_Target
// pname: Query_Parameter

/* void GetQueryObjectiv(uint id, enum pname, int *params); */
Query_Object_Parameter :: enum u32 {
	Query_Target           = gl.QUERY_TARGET,
	Query_Result           = gl.QUERY_RESULT,
	Query_Result_No_Wait   = gl.QUERY_RESULT_NO_WAIT,
	Query_Result_Available = gl.QUERY_RESULT_AVAILABLE,
}

/* void GetQueryObjectuiv(uint id, enum pname, uint *params); */
// pname: Query_Object_Parameter

/* void GetQueryObjecti64v(uint id, enum pname, int64 *params); */
// pname: Query_Object_Parameter

/* void GetQueryObjectui64v(uint id, enum pname, uint64 *params); */
// pname: Query_Object_Parameter

/* void GetQueryBufferObjectiv( uint id, uint buffer, enum pname, intptr offset ); */
// pname: Query_Object_Parameter

/* void GetQueryBufferObjectuiv( uint id, uint buffer, enum pname, intptr offset ); */
// pname: Query_Object_Parameter

/* void GetQueryBufferObjecti64v( uint id, uint buffer, enum pname, intptr offset ); */
// pname: Query_Object_Parameter

/* void GetQueryBufferObjectui64v( uint id, uint buffer, enum pname, intptr offset ); */
// pname: Query_Object_Parameter
