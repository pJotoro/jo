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
	_: u16,
	_: u32,
	_: u32,
	transparent_color_entry: u8,
	_: [3]u8,
	num_colors: u16,
	pixel_w: u8,
	pixel_h: u8,
	grid_x: i16,
	grid_y: i16,
	grid_w: u16,
	grid_h: u16,
	_: [84]u8,
}
static_assert(sizeof(Header) == 128);

Frame :: struct {
	num_bytes: u32,
	magic_number: u16,
	_: u16,
	frame_dur: u16,
	_: [2]u8,
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

Chunk_Header :: struct {
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

Layer_Chunk :: struct {
	flags: Layer_Chunk_Flags,
	layer_type: Layer_Type,
	layer_child_level: u16,
	_: u16,
	_: u16,
	blend_mode: Blend_Mode,
	opacity: u8,
	_: [3]u8,
	layer_name: String,
	// tileset_idx: u32,
	// uuid: [16]u8,
}

Cell_Type :: enum u16 {
	Raw = 0,
	Linked = 1,
	Compressed_Image = 2,
	Compressed_Tilemap = 3,
}

Cell_Chunk :: struct {
	layer_idx: u16,
	x: i16,
	y: i16,
	opacity: u8,
	type: Cell_Type,
	z_idx: i16,
	_: [5]u8,
	w: u16,
	h: u16,
	// pixels: []ASE_Pixel,
}

Cell_Extra_Chunk_Flag :: enum {
	Precise_Bounds,
}
Cell_Extra_Chunk_Flags :: distinct bit_set[Cell_Extra_Chunk_Flag; u32]

Cell_Extra_Chunk :: struct {
	flags: Cell_Extra_Chunk_Flags,
	x: Fixed,
	y: Fixed,
	w: Fixed,
	h: Fixed,
	_: [16]u8,
}

Color_Profile_Type :: enum u16 {
	None = 0,
	SRGB = 1,
	Embedded_ICC = 2,
}

Color_Profile_Flag :: enum {
	Special_Fixed_Gamma,
}
Color_Profile_Flags :: distinct bit_set[Color_Profile_Flag; u16]

Color_Profile_Chunk :: struct {
	type: Color_Profile_Type,
	flags: Color_Profile_Flags,
	fixed_gamma: Fixed,
	_: [8]u8,
	icc_profile_data_len: u32,
	// icc_profile_data[]: u8,
}

External_Files_Entry_Type :: enum u8 {
	External_Palette = 0,
	External_Tileset = 1,
	Extension_Name_For_Properties = 2,
	Extension_Name_For_Tile_Management = 3,
}

External_Files_Entry :: struct {
	id: u32,
	type: External_Files_Entry_Type,
	_: [7]u8,
	using _: struct #raw_union {
		external_file_name: String,
		extension_id: String,
	},
}

External_Files_Chunk :: struct {
	num_entries: u32,
	_: [8]u8,
	// entries: []External_Files_Entry,
}

Loop_Anim_Dir :: enum u8 {
	Forward = 0,
	Reverse = 1,
	Ping_Pong = 2,
	Ping_Pong_Reverse = 3,
}

Tag :: struct {
	from_frame: u16,
	to_frame: u16,
	loop_anim_dir: Loop_Anim_Dir,
	repeat: u16,
	_: [6]u8,
	_: [3]u8,
	_: u8,
	name: String,
}

Tags_Chunk :: struct {
	num_tags: u16,
	// tags: []ASE_Tag,
}

Palette_Entry_Flag :: enum {
	HasName,
}
Palette_Entry_Flags :: distinct bit_set[Palette_Entry_Flag; u16]

Palette_Entry :: struct {
	flags: Palette_Entry_Flags,
	r: u8,
	g: u8,
	b: u8,
	a: u8,
	// color_name: String,
}

Palette_Chunk :: struct {
	num_entries: u32,
	first_color_idx_to_change: u32,
	last_color_idx_to_change: u32,
	_: [8]u8,
	// entries[]: PaletteEntry,
}