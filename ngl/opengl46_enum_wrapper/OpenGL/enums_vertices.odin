package vendor_gl

/* Separate Patches [10.1.15] */

/* void PatchParameteri(enum pname, int value); */
Patch_Parameteri :: enum u32 {
	Patch_Vertices = PATCH_VERTICES,
}


/* Current Vertex Attribute Values [10.2] */

/* void VertexAttribP1ui(uint index, enum type, boolean normalized, uint value); */
Vertex_AttribP123_Type :: enum u32 {
	Int_2_10_10_10_Rev           = INT_2_10_10_10_REV,
	Unsigned_Int_2_10_10_10_Rev  = UNSIGNED_INT_2_10_10_10_REV,
	Unsigned_Int_10f_11f_11f_Rev = UNSIGNED_INT_10F_11F_11F_REV,
}
/* void VertexAttribP2ui(uint index, enum type, boolean normalized, uint value); */
// type: Vertex_AttribP123_Type

/* void VertexAttribP3ui(uint index, enum type, boolean normalized, uint value); */
// type: Vertex_AttribP123_Type

/* void VertexAttribP4ui(uint index, enum type, boolean normalized, uint value); */
Vertex_AttribP4_Type :: enum u32 {
	Int_2_10_10_10_Rev           = INT_2_10_10_10_REV,
	Unsigned_Int_2_10_10_10_Rev  = UNSIGNED_INT_2_10_10_10_REV,
}

// void VertexAttribP1uiv(uint index, enum type, boolean normalized, const uint *value);
// type: Vertex_AttribP123_Type

// void VertexAttribP2uiv(uint index, enum type, boolean normalized, const uint *value);
// type: Vertex_AttribP123_Type

// void VertexAttribP3uiv(uint index, enum type, boolean normalized, const uint *value);
// type: Vertex_AttribP123_Type

// void VertexAttribP4uiv(uint index, enum type, boolean normalized, const uint *value);
// type: Vertex_AttribP4_Type
