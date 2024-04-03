package ngl

import gl "vendor:OpenGL"

/* Generic Vertex Attribute Arrays [10.3.2] */

/* void VertexAttribFormat(uint attribindex, int size, enum type, boolean normalized, unit relativeoffset); */
Vertex_Attrib_Type :: enum u32 {
	Byte                         = gl.BYTE,
	Unsigned_Byte                = gl.UNSIGNED_BYTE,
	Short                        = gl.SHORT,
	Unsigned_Short               = gl.UNSIGNED_SHORT,
	Int                          = gl.INT,
	Unsigned_Int                 = gl.UNSIGNED_INT,
	Float                        = gl.FLOAT,
	Half_Float                   = gl.HALF_FLOAT,
	Double                       = gl.DOUBLE,
	Fixed                        = gl.FIXED,
	Int_2_10_10_10_Rev           = gl.INT_2_10_10_10_REV,
	Unsigned_Int_2_10_10_10_Rev  = gl.UNSIGNED_INT_2_10_10_10_REV,
	Unsigned_Int_10f_11f_11f_Rev = gl.UNSIGNED_INT_10F_11F_11F_REV,
}

/* void VertexAttribIFormat(uint attribindex, int size, enum type, unit relativeoffset); */
Vertex_AttribI_Type :: enum u32 {
	Byte           = gl.BYTE,
	Unsigned_Byte  = gl.UNSIGNED_BYTE,
	Short          = gl.SHORT,
	Unsigned_Short = gl.UNSIGNED_SHORT,
	Int            = gl.INT,
	Unsigned_Int   = gl.UNSIGNED_INT,
}

/* void VertexAttribLFormat(uint attribindex, int size, enum type, unit relativeoffset); */
Vertex_AttribL_Type :: enum u32 {
	Double = gl.DOUBLE,
}

/* void VertexArrayAttribFormat(uint vaobj, uint attribindex, int size, enum type, boolean normalized, uint relativeoffset); */
// type: Vertex_Attrib_Type

/* void VertexArrayAttribIFormat(uint vaobj, uint attribindex, int size, enum type, uint relativeoffset); */
// type: Vertex_AttribI_Type

/* void VertexArrayAttribLFormat(uint vaobj, uint attribindex, int size, enum type, uint relativeoffset); */
// type: Vertex_AttribL_Type

/* void VertexAttribPointer(uint index, int size, enum type, boolean normalized, sizei stride, const void *pointer); */
// type: Vertex_Attrib_Type

/* void VertexAttribIPointer(uint index, int size, enum type, sizei stride, const void *pointer); */
// type: Vertex_AttribI_Type

/* void VertexAttribLPointer(uint index, int size, enum type, sizei stride, const void*pointer); */
// type: Vertex_AttribL_Type


/* Drawing Commands [10.4] */

/* void DrawArrays(enum mode, int first, sizei count); */
Draw_Mode :: enum u32 {
	Points                   = gl.POINTS,
	Line_Strip               = gl.LINE_STRIP,
	Line_Loop                = gl.LINE_LOOP,
	Lines                    = gl.LINES,
	Triangle_Strip           = gl.TRIANGLE_STRIP,
	Triangle_Fan             = gl.TRIANGLE_FAN,
	Triangles                = gl.TRIANGLES,
	Lines_Adjacency          = gl.LINES_ADJACENCY,
	Line_Strip_Adjacency     = gl.LINE_STRIP_ADJACENCY,
	Triangles_Adjacency      = gl.TRIANGLES_ADJACENCY,
	Triangle_Strip_Adjacency = gl.TRIANGLE_STRIP_ADJACENCY,
	Patches                  = gl.PATCHES,
}

/* void DrawArraysInstancedBaseInstance(enum mode, int first, sizei count, sizei instancecount, uint baseinstance); */
// mode: Draw_Mode

/* void DrawArraysInstanced(enum mode, int first, sizei count, sizei instancecount); */
// mode: Draw_Mode

/* void DrawArraysIndirect(enum mode, const void *indirect); */
// mode: Draw_Mode

/* void MultiDrawArrays(enum mode, const int *first, const sizei *count, sizei drawcount); */
// mode: Draw_Mode

/* void MultiDrawArraysIndirect(enum mode, const void *indirect, sizei drawcount, sizei stride); */
// mode: Draw_Mode

/* void MultiDrawArraysIndirectCount(enum mode, const void *indirect, intptr drawcount, intptr maxdrawcount, sizei stride); */
// mode: Draw_Mode

/* void DrawElements(enum mode, sizei count, enum type, const void *indices); */
// mode: Draw_Mode

Draw_Type :: enum u32 {
	Unsigned_Byte  = gl.UNSIGNED_BYTE,
	Unsigned_Short = gl.UNSIGNED_SHORT,
	Unsigned_Int   = gl.UNSIGNED_INT,
}

/* void DrawElementsInstancedBaseInstance(enum mode, sizei count, enum type, const void *indices, sizei instancecount, uint baseinstance); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawElementsInstanced(enum mode, sizei count, enum type, const void *indices, sizei instancecount); */
// mode: Draw_Mode
// type: Draw_Type

/* void MultiDrawElements(enum mode, const sizei *count, enum type, const void * const *indices, sizei drawcount); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawRangeElements(enum mode, uint start, uint end, sizei count, enum type, const void *indices); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawElementsBaseVertex(enum mode, sizei count, enum type, const void *indices, int basevertex); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawRangeElementsBaseVertex(enum mode, uint start, uint end, sizei count, enum type, const void *indices, int basevertex); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawElementsInstancedBaseVertex(enum mode, sizei count, enum type, const void *indices, sizei instancecount, int basevertex); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawElementsInstancedBaseVertexBaseInstance(enum mode, sizei count, enum type, const void *indices, sizei instancecount, int basevertex, uint baseinstance); */
// mode: Draw_Mode
// type: Draw_Type

/* void DrawElementsIndirect(enum mode, enum type, const void *indirect); */
// mode: Draw_Mode
// type: Draw_Type

/* void MultiDrawElementsIndirect(enum mode, enum type, const void *indirect, sizei drawcount, sizei stride); */
// mode: Draw_Mode
// type: Draw_Type

/* void MultiDrawElementsIndirectCount(enum mode, enum type, const void *indirect, intptr drawcount, sizei maxdrawcount, sizei stride); */
// mode: Draw_Mode
// type: Draw_Type

/* void MultiDrawElementsBaseVertex(enum mode, const sizei *count, enum type, const void *const *indices, sizei drawcount, const int *basevertex); */
// mode: Draw_Mode
// type: Draw_Type


/* Vertex Array Queries [10.5] */

/* void GetVertexArrayiv(uint vaobj, enum pname, int *param); */
GetVertexArrayiv_Parameter :: enum u32 {
	Element_Array_Buffer_Binding = gl.ELEMENT_ARRAY_BUFFER_BINDING,
}

/* void GetVertexArrayIndexediv(uint vaobj, uint index, enum pname, int *param); */
Vertex_Array_Indexediv_Parameter :: enum u32 {
	Vertex_Attrib_Array_Enabled        = gl.VERTEX_ATTRIB_ARRAY_ENABLED,
	Vertex_Attrib_Array_Size           = gl.VERTEX_ATTRIB_ARRAY_SIZE,
	Vertex_Attrib_Array_Stride         = gl.VERTEX_ATTRIB_ARRAY_STRIDE,
	Vertex_Attrib_Array_Type           = gl.VERTEX_ATTRIB_ARRAY_TYPE,
	Vertex_Attrib_Array_Normalized     = gl.VERTEX_ATTRIB_ARRAY_NORMALIZED,
	Vertex_Attrib_Array_Integer        = gl.VERTEX_ATTRIB_ARRAY_INTEGER,
	Vertex_Attrib_Array_Long           = gl.VERTEX_ATTRIB_ARRAY_LONG,
	Vertex_Attrib_Array_Divisor        = gl.VERTEX_ATTRIB_ARRAY_DIVISOR,
	Vertex_Attrib_Relative_Offset      = gl.VERTEX_ATTRIB_RELATIVE_OFFSET,
	Vertex_Attrib_Array_Buffer_Binding = gl.VERTEX_ATTRIB_ARRAY_BUFFER_BINDING,
	Vertex_Binding_Stride              = gl.VERTEX_BINDING_STRIDE,
	Vertex_Binding_Divisor             = gl.VERTEX_BINDING_DIVISOR,
	Vertex_Binding_Buffer              = gl.VERTEX_BINDING_BUFFER,
}

/* void GetVertexArrayIndexed64iv(uint vaobj, uint index, enum pname, int64 *param); */
Vertex_Array_Indexed64iv_Parameter :: enum u32 {
	Vertex_Binding_Offset = gl.VERTEX_BINDING_OFFSET,
}

/* void GetVertexAttribdv(uint index, enum pname, T *params); */
Vertex_Attrib_Parameter :: enum u32 {
	Vertex_Attrib_Array_Buffer_Binding = gl.VERTEX_ATTRIB_ARRAY_BUFFER_BINDING,
	Vertex_Attrib_Array_Enabled        = gl.VERTEX_ATTRIB_ARRAY_ENABLED,
	Vertex_Attrib_Array_Size           = gl.VERTEX_ATTRIB_ARRAY_SIZE,
	Vertex_Attrib_Array_Stride         = gl.VERTEX_ATTRIB_ARRAY_STRIDE,
	Vertex_Attrib_Array_Type           = gl.VERTEX_ATTRIB_ARRAY_TYPE,
	Vertex_Attrib_Array_Normalized     = gl.VERTEX_ATTRIB_ARRAY_NORMALIZED,
	Vertex_Attrib_Array_Integer        = gl.VERTEX_ATTRIB_ARRAY_INTEGER,
	Vertex_Attrib_Array_Long           = gl.VERTEX_ATTRIB_ARRAY_LONG,
	Vertex_Attrib_Array_Divisor        = gl.VERTEX_ATTRIB_ARRAY_DIVISOR,
	Vertex_Attrib_Binding              = gl.VERTEX_ATTRIB_BINDING,
	Vertex_Attrib_Relative_Offset      = gl.VERTEX_ATTRIB_RELATIVE_OFFSET,
	Current_Vertex_Attrib              = gl.CURRENT_VERTEX_ATTRIB,
}

/* void GetVertexAttribfv(uint index, enum pname, T *params); */
// pname: Vertex_Attrib_Parameter

/* void GetVertexAttribiv(uint index, enum pname, T *params); */
// pname: Vertex_Attrib_Parameter

/* void GetVertexAttribIiv(uint index, enum pname, T *params); */
// pname: Vertex_Attrib_Parameter

/* void GetVertexAttribIuiv(uint index, enum pname, T *params); */
// pname: Vertex_Attrib_Parameter

/* void GetVertexAttribLdv(uint index, enum pname, double *params); */
// pname: Vertex_Attrib_Parameter

/* void GetVertexAttribPointerv(uint index, enum pname, const void **pointer); */
Vertex_Attrib_Pointer_Parameter :: enum u32 {
	Vertex_Attrib_Array_Pointer = gl.VERTEX_ATTRIB_ARRAY_POINTER,
}


/* Conditional Rendering [10.9] */

/* void BeginConditionalRender(uint id, enum mode); */
Conditional_Render_Mode :: enum u32 {
	Query_Wait                       = gl.QUERY_WAIT,
	Query_No_Wait                    = gl.QUERY_NO_WAIT,
	Query_By_Region_Wait             = gl.QUERY_BY_REGION_WAIT,
	Query_By_Region_No_Wait          = gl.QUERY_BY_REGION_NO_WAIT,
	Query_Wait_Inverted              = gl.QUERY_WAIT_INVERTED,
	Query_No_Wait_Inverted           = gl.QUERY_NO_WAIT_INVERTED,
	Query_By_Region_Wait_Inverted    = gl.QUERY_BY_REGION_WAIT_INVERTED,
	Query_By_Region_No_Wait_Inverted = gl.QUERY_BY_REGION_NO_WAIT_INVERTED,
}
