package vendor_gl

/* void GetActiveAttrib(uint program, uint index, sizei bufSize, sizei *length, int *size, enum *type, char *name); */
Attribute_Type :: enum u32 {
	None              = NONE, // NOTE: Only according to Ref. Card.
	Float             = FLOAT,
	Float_Vec2        = FLOAT_VEC2,
	Float_Vec3        = FLOAT_VEC3,
	Float_Vec4        = FLOAT_VEC4,
	Float_Mat2        = FLOAT_MAT2,
	Float_Mat3        = FLOAT_MAT3,
	Float_Mat4        = FLOAT_MAT4,
	Float_Mat2x3      = FLOAT_MAT2x3,
	Float_Mat2x4      = FLOAT_MAT2x4,
	Float_Mat3x2      = FLOAT_MAT3x2,
	Float_Mat3x4      = FLOAT_MAT3x4,
	Float_Mat4x2      = FLOAT_MAT4x2,
	Float_Mat4x3      = FLOAT_MAT4x3,

	Int               = INT,
	Int_Vec2          = INT_VEC2,
	Int_Vec3          = INT_VEC3,
	Int_Vec4          = INT_VEC4,

	Unsigned_Int      = UNSIGNED_INT,
	Unsigned_Int_Vec2 = UNSIGNED_INT_VEC2,
	Unsigned_Int_Vec3 = UNSIGNED_INT_VEC3,
	Unsigned_Int_Vec4 = UNSIGNED_INT_VEC4,

	Double            = DOUBLE,
	Double_Vec2       = DOUBLE_VEC2,
	Double_Vec3       = DOUBLE_VEC3,
	Double_Vec4       = DOUBLE_VEC4,
	Double_Mat2       = DOUBLE_MAT2,
	Double_Mat3       = DOUBLE_MAT3,
	Double_Mat4       = DOUBLE_MAT4,
	Double_Mat2x3     = DOUBLE_MAT2x3,
	Double_Mat2x4     = DOUBLE_MAT2x4,
	Double_Mat3x2     = DOUBLE_MAT3x2,
	Double_Mat3x4     = DOUBLE_MAT3x4,
	Double_Mat4x2     = DOUBLE_MAT4x2,
	Double_Mat4x3     = DOUBLE_MAT4x3,
}


/* Transform Feedback Variables [11.1.2] */

/* void TransformFeedbackVaryings(uint program, sizei count, const char * const *varyings, enum bufferMode); */
Transform_Feedback_Buffer_Mode :: enum u32 {
	Interleaved_Attribs = INTERLEAVED_ATTRIBS,
	Separate_Attribs    = SEPARATE_ATTRIBS,
}

/* void GetTransformFeedbackVarying(uint program, uint index, sizei bufSize, sizei *length, sizei *size, enum *type, char *name); */
// type: Attribute_Type


/* Tessellation Prim. Generation [11.2.2] */

/* void PatchParameterfv(enum pname, const float *values); */
Patch_Parameterfv :: enum u32 {
	Patch_Default_Outer_Level = PATCH_DEFAULT_OUTER_LEVEL,
	Patch_Default_Inner_Level = PATCH_DEFAULT_INNER_LEVEL,
}
