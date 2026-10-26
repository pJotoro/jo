package aseprite

Fixed :: struct {
	val[2]: u16,
}

String :: struct {
	len: u16,
	// buf: []byte,
}

Point :: [2]i32
Size :: [2]i32

Rect :: struct
{
	origin: Point,
	size: Size,
}

Pixel :: struct #raw_union {
	rgba: [4]u8,
	grayscale: [2]u8,
	index: u8,
}

Flag :: enum {
	Layer_Opacity_Valid,
	Layer_Opacity_Valid_For_Groups,
	Layers_Have_UUID,
}
Flags :: distinct bit_set[Flag; u32]

Header :: struct {
	file_size: u32,
	magic_number: u16,
	num_frames: u16,
	w: u16,
	h: u16,
	color_depth: u16,
	flags: Flags,
	reserved0: u16,
	reserved1: u32,
	reserved2: u32,
	transparent_color_entry: u8,
	reserved3: [3]u8,
	num_colors: u16,
	pixel_w: u8,
	pixel_h: u8,
	grid_x: i16,
	grid_y: i16,
	grid_w: u16,
	grid_h: u16,
	reserved4: [84]u8,
}
static_assert(sizeof(Header) == 128);

Frame :: struct
{
	num_bytes: u32,
	magic_number: u16,
	reserved0: u16,
	frame_dur: u16,
	reserved1: [2]u8,
	num_chunks: u32,
}
static_assert(sizeof(Frame) == 16);

Chunk_Type :: enum u16 {
	Old_Palette = 0x0004,
	Old_Palette2 = 0x0011,
	Layer = 0x2004,
	Cell = 0x2005,
	Cell_Extra = 0x2006,
	Color_Profile = 0x2007,
	External_Files = 0x2008,
	Deprecated_Mask = 0x2016,
	Path = 0x2017,
	Tags = 0x2018,
	Palette = 0x2019,
	User_Data = 0x2020,
	Slice = 0x2022,
	Tileset = 0x2023,
}

Chunk_Header :: struct
{
	size: u32,
	type: Chunk_Type,
}

Layer_Chunk_Flags :: enum u16 {
	Visible = 1,
	Editable = 2,
	LockMovement = 4,
	Background = 8,
	PreferLinkedCells = 16,
	DisplayCollapsed = 32,
	ReferenceLayer = 64,
}

Layer_Type :: enum u16 {
	Normal = 0,
	Group = 1,
	Tilemap = 2,
}

Blend_Mode :: enum u16 {
	Normal = 0,
	Multiply = 1,
	Screen = 2,
	Overlay = 3,
	Darken = 4,
	Lighten = 5,
	ColorDodge = 6,
	ColorBurn = 7,
	HardLight = 8,
	SoftLight = 9,
	Difference = 10,
	Exclusion = 11,
	Hue = 12,
	Saturation = 13,
	Color = 14,
	Luminosity = 15,
	Addition = 16,
	Subtract = 17,
	Divide = 18,
}

LayerChunk :: struct
{
	flags: ASE_LayerChunkFlags,
	layer_type: ASE_LayerType,
	layer_child_level: u16,
	reserved0: u16,
	reserved1: u16,
	blend_mode: ASE_BlendMode,
	opacity: u8,
	reserved2: [3]u8,
	layer_name: ASE_String,
	#if 0
	tileset_idx: u32,
	uuid: [16]u8,
	#endif
}

ASE_CellType :: enum u16 {
	ASE_CellType_Raw = 0,
	ASE_CellType_Linked = 1,
	ASE_CellType_CompressedImage = 2,
	ASE_CellType_CompressedTilemap = 3,
}

CellChunk :: struct
{
	layer_idx: u16,
	x: i16,
	y: i16,
	opacity: u8,
	type: ASE_CellType,
	z_idx: i16,
	reserved0: [5]u8,
	w: u16,
	h: u16,
#if 0
	pixels: []ASE_Pixel,
#endif
}

ASE_CellExtraChunkFlags :: enum u32 {
	ASE_CellExtraChunkFlags_PreciseBounds = 1,
}

CellExtraChunk :: struct
{
	flags: ASE_CellExtraChunkFlags,
	x: ASE_Fixed,
	y: ASE_Fixed,
	w: ASE_Fixed,
	h: ASE_Fixed,
	reserved0: [16]u8,
}

ASE_ColorProfileType :: enum u16 {
	ASE_ColorProfileType_None = 0,
	ASE_ColorProfileType_SRGB = 1,
	ASE_ColorProfileType_EmbeddedICC = 2,
}

ASE_ColorProfileFlags :: enum u16 {
	ASE_ColorProfileFlags_SpecialFixedGamma = 1,
}

ColorProfileChunk :: struct
{
	type: ASE_ColorProfileType,
	flags: ASE_ColorProfileFlags,
	fixed_gamma: ASE_Fixed,
	reserved0: [8]u8,
	icc_profile_data_len: u32,
#if 0
	icc_profile_data[]: u8,
#endif
}

ASE_ExternalFilesEntryType :: enum u8 {
	ASE_ExternalFilesEntryType_ExternalPalette = 0,
	ASE_ExternalFilesEntryType_ExternalTileset = 1,
	ASE_ExternalFilesEntryType_ExtensionNameForProperties = 2,
	ASE_ExternalFilesEntryType_ExtensionNameForTileManagement = 3,
}

ExternalFilesEntry :: struct
{
	id: u32,
	type: ASE_ExternalFilesEntryType,
	reserved0[7]: u8,
	union 
	{
	external_file_name: 	ASE_String,
	extension_id: 	ASE_String,
	}
}

ExternalFilesChunk :: struct
{
	num_entries: u32,
	reserved0: [8]u8,
#if 0
	entries: []ASE_ExternalFilesEntry,
#endif
}

ASE_LoopAnimDir :: enum u8 {
	ASE_LoopAnimDir_Forward = 0,
	ASE_LoopAnimDir_Reverse = 1,
	ASE_LoopAnimDir_PingPong = 2,
	ASE_LoopAnimDir_PingPongReverse = 3,
}

Tag :: struct
{
	from_frame: u16,
	to_frame: u16,
	loop_anim_dir: ASE_LoopAnimDir,
	repeat: u16,
	reserved0: [6]u8,
	reserved1: [3]u8,
	reserved2: u8,
	name: ASE_String,
}

TagsChunk :: struct
{
	num_tags: u16,
#if 0
	tags: []ASE_Tag,
#endif
}

ASE_PaletteEntryFlags :: enum u16 {
	HasName = 1,
}

PaletteEntry :: struct
{
	flags: PaletteEntryFlags,
	r: u8,
	g: u8,
	b: u8,
	a: u8,
#if 0
	color_name: String,
#endif
}

PaletteChunk :: struct
{
	num_entries: u32,
	first_color_idx_to_change: u32,
	last_color_idx_to_change: u32,
	reserved0: [8]u8,
#if 0
	entries[]: PaletteEntry,
#endif
}