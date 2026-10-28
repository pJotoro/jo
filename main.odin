package jo

// Unless otherwise noted:
// - Time is measured in seconds.
// - Size and distance is measured in meters.

import "base:intrinsics"
import "base:runtime"
import "core:time"
import "core:strings"
import "core:math"
import "core:bytes"
import "core:io"
import "core:mem"
import "core:compress/zlib"
import "core:slice"

import win32 "core:sys/windows"
L :: intrinsics.constant_utf16_cstring

import ase "aseprite"

import vk "vendor:vulkan"

JO_DEBUG :: #config(JO_DEBUG, ODIN_DEBUG)
JO_FULLSCREEN :: #config(JO_FULLSCREEN, !JO_DEBUG)
JO_TOPMOST :: #config(JO_TOPMOST, JO_FULLSCREEN)
VULKAN_DEBUG :: #config(VULKAN_DEBUG, ODIN_DEBUG)

// Can be transmuted to win32.RECT
Rect :: struct {
	min: [2]i32,
	max: [2]i32,
}

width :: proc "contextless" (ctx: Context) -> int {
	when !JO_FULLSCREEN {
		return ctx.monitor.w/2
	} else {
		return ctx.monitor.w
	}
}

height :: proc "contextless" (ctx: Context) -> int {
	when !JO_FULLSCREEN {
		return ctx.monitor.h/2
	} else {
		return ctx.monitor.h
	}
}

Sprite_Cell :: struct {
	dst_buf: bytes.Buffer, // invalid after VulkanCreateStaticStagingBuffer.

	origin: [2]i32,
	size: [2]i32,
	z_idx: i32,
	layer_idx: u32,
}

Sprite_Frame :: struct {
	/**
	 * Why have multiple cells in each frame? The reason is because that's how Aseprite does 
	 * things. In Aseprite, a sprite is made up of an array of frames, and each frame is made up 
	 * of an array of cells. Each cell contains its own compressed image data, which is what 
	 * SpriteCell::dst_buf stores. When it comes time to actually render the sprite, we render 
	 * each cell as its own texture. This is actually plenty fast, because we don't store a 
	 * different texture for each cell; instead, we make each sprite have one texture array, 
	 * where each cell is one element of the texture array.
	 * 
	 * Now, you might ask: but why not merge the image data from each cell into one image before 
	 * uploading to the GPU? That way, you don't have to render each cell separately, every single 
	 * time; instead, you just do it all on the CPU beforehand. I'm sure this would be faster, but 
	 * it would also be more complicated and less flexible. What if I wanted to apply a shader to 
	 * just one cell? For example, a fire effect to just the player's sword. As it stands, this 
	 * would be pretty trivial.
	 */
	cells: []Sprite_Cell,

	/**
	 * Not every frame necessarily has a hitbox. If it exists, it is literally drawn inside of
	 * Aseprite in a layer called "Hitbox". See EntityGetHitbox to find out how a hitbox is
	 * selected for an entity.
	 */
	hitbox: Rect,

	/**
	 * The duration of the frame. See AnimUpdate to find out how this is used.
	 */
	dur: f32,
}

Sprite_Desc :: struct {
	origin: [2]i32,
	size: [2]i32,
	frames: []Sprite_Frame,
	
	vk_image: vk.Image,
	vk_image_view: vk.ImageView,
	vk_image_array_layers: uint,
	vk_descriptor_set: vk.DescriptorSet,
}

Sprite :: distinct string

Anim :: struct {
	sprite: Sprite,
	dt_accumulator: f32,
	frame_idx: u32,
	ended: bool,
}

Entity_Type :: enum {
	Player,
	Boar,
}

Entity_State :: enum {
	Inactive,
	Die,
	Attack,
	Fall,
	Jump,
	Free,
	Hurt,	
}

Entity :: struct {
	anim: Anim,

	pos: [2]i32,
	start_pos: [2]i32,
	pos_remainder: [2]f32,
	vel: [2]f32,
	dir: i32,

	type: Entity_Type,
	state: Entity_State,
}

MAX_ENTITIES :: 128
MAX_TILE_LAYERS :: 8
TILE_SIZE :: 32

Tile :: distinct [2]i32

Tile_Layer :: struct {
	size: [2]i32,
	tiles: [^]Tile, // [size.x*size.y]Tile
}

Level :: struct {
	size: [2]i32,
	entities: [dynamic; MAX_ENTITIES]Entity,
	tile_layers: [dynamic; MAX_TILE_LAYERS]Tile_Layer,
}

Context :: struct {
	running: bool,
	monitor: struct {
		w, h: int,
	},
	gamepad: Gamepad,
	sprites: map[Sprite]Sprite_Desc,
	arena: mem.Allocator, // TODO: Actually make this somewhere.
	num_sprites: int,
	fixed_dt: f32,
	variable_dt: f32,
	level: Level, // TODO: We should have multiple levels!
}

sprite_player_idle: Sprite
sprite_player_run: Sprite
sprite_player_jump_start: Sprite
sprite_player_jump_end: Sprite
sprite_player_attack: Sprite
sprite_player_die: Sprite

sprite_boar_idle: Sprite
sprite_boar_walk: Sprite
sprite_boar_run: Sprite
sprite_boar_hit: Sprite

sprite_tiles: Sprite

// TODO: Shouldn't we be handling io errors?

// Sprite should just be the name of the sprite, without the rest of the path (folders, file extension).
sprite_load :: proc(ctx: ^Context, $path: string) -> Sprite {
	buf := #load(path)
	return _sprite_load(ctx, path, buf)

	_sprite_load :: proc(ctx: ^Context, path: string, buf: []byte) -> Sprite {
		sd: Sprite_Desc

		bytes_reader: bytes.Reader
		rd := bytes.reader_init(&bytes_reader, buf)

		header: ase.Header
		io.read_ptr(rd, &header, size_of(header))
		assert(header.magic_number == 0xA5E0)

		assert(header.color_depth == 32)
		assert((header.pixel_w == 0 || header.pixel_w == 1) && (header.pixel_h == 0 || header.pixel_h == 1))
		assert(header.grid_x == 0)
		assert(header.grid_y == 0)
		assert(header.grid_w == 0 || header.grid_w == 16)
		assert(header.grid_h == 0 || header.grid_h == 16)

		sd.size.x = i32(header.w)
		sd.size.y = i32(header.h)

		sd.frames = make([]Sprite_Frame, header.num_frames, ctx.arena)

		// The hitbox layer and origin layer are specialized layers whose image data is not to be used for rendering.
		// We must search for them so that we can extract information out of them.
		hitbox_layer_idx := max(u16)
		origin_layer_idx := max(u16)

		for &frame, frame_idx in sd.frames {
			ase_frame: ase.Frame
			io.read_ptr(rd, &ase_frame, size_of(ase_frame))
			assert(ase_frame.magic_number == 0xF1FA)

			// Would mean this aseprite file is very old.
			assert(ase_frame.num_chunks != 0)

			frame.dur = f32(ase_frame.frame_dur) / f32(time.Millisecond)

			rd_pos, _ := io.seek(rd, 0, .Current)

			// NOTE: According to the Aseprite spec, all layer chunks are found in the first frame, but not necessarily before everything else in that frame.
			// https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md#layer-chunk-0x2004
			if frame_idx == 0 {
				for chunk_idx, layer_idx := u32(0), u16(0); chunk_idx < ase_frame.num_chunks; chunk_idx += 1 {
					raw_chunk, chunk_type := ase_read_chunk(rd)
					defer delete(raw_chunk)
					if (chunk_type == .Layer) 
					{
						chunk := (^ase.Layer_Chunk)(raw_data(raw_chunk))
						assert(chunk.layer_name.len > 0)

						layer_name := ase_string(&chunk.layer_name)
						if layer_name == "Hitbox" {
							hitbox_layer_is_unique := hitbox_layer_idx == max(u16)
							assert(hitbox_layer_is_unique)
							hitbox_layer_idx = layer_idx
						} else if layer_name == "Origin" {
							origin_layer_is_unique := origin_layer_idx == max(u16)
							assert(origin_layer_is_unique)
							origin_layer_idx = layer_idx;					
						}
						layer_idx += 1;
					}
				}

				io.seek(rd, rd_pos, .Start)
			}

			num_cells := 0

			for chunk_idx := u32(0); chunk_idx < ase_frame.num_chunks; chunk_idx += 1 {
				raw_chunk, chunk_type := ase_read_chunk(rd)
				defer delete(raw_chunk)

				if chunk_type == .Cell {
					chunk := (^ase.Cell_Chunk)(raw_data(raw_chunk))
					if chunk.layer_idx == hitbox_layer_idx {
						sd.frames[frame_idx].hitbox = Rect{
							min = {i32(chunk.x), i32(chunk.y)},
							max = {i32(chunk.x) + i32(chunk.w), i32(chunk.y) + i32(chunk.h)},
						}
					} else if chunk.layer_idx == origin_layer_idx {
						if frame_idx == 0 {
							sd.origin = {i32(chunk.x), i32(chunk.y)}
						}
					} else {
						num_cells += 1
						assert(chunk.type == .Compressed_Image)
					}
				}
			}

			if num_cells > 0 {
				sd.frames[frame_idx].cells = make([]Sprite_Cell, num_cells, ctx.arena)

				cell_idx := 0

				io.seek(rd, rd_pos, .Current)

				for chunk_idx in 0..<ase_frame.num_chunks {
					raw_chunk, chunk_type := ase_read_chunk(rd)

					chunk := (^ase.Cell_Chunk)(raw_data(raw_chunk))
					if (chunk_type == .Cell && 
						chunk.layer_idx != hitbox_layer_idx && 
						chunk.layer_idx != origin_layer_idx) {

						cell := Sprite_Cell{
							origin = {i32(chunk.x), i32(chunk.y)},
							z_idx = i32(chunk.z_idx),
							layer_idx = u32(chunk.layer_idx),
							size = {i32(chunk.w), i32(chunk.h)},
						}

						assert(cell.size.x != 0 && cell.size.y != 0)
						bytes.buffer_init_allocator(&cell.dst_buf, 0, int(cell.size.x*cell.size.y) * size_of(u32))

						// It's the zero-sized array at the end of ASE_CellChunk.
						src_buf_size := len(raw_chunk) - size_of(ase.Cell_Chunk) - 2;
						src_buf_ptr := rawptr(uintptr(&chunk.h) + size_of(chunk.h))
						src_buf := slice.from_ptr((^u8)(src_buf_ptr), src_buf_size)

						// Decompress the image data.
						res := zlib.inflate_from_byte_array_raw(src_buf, &cell.dst_buf, true, int(cell.size.x*cell.size.y) * size_of(u32))
						assert(res.(zlib.ZLIB_Error) == .None)

						assert(cell_idx < len(sd.frames[frame_idx].cells))
						sd.frames[frame_idx].cells[cell_idx] = cell
						cell_idx += 1
					}
				}

				// Makes the cells draw in the correct order.
				slice.sort_by(sd.frames[frame_idx].cells, compare_sprite_cells)
			}
		}

		ctx.num_sprites += 1


		sprite := sprite_from_path(path)
		ctx.sprites[sprite] = sd
		return sprite
	}
}

// assets/legacy_fantasy_high_forest/Folder1/Folder2/Folder2.aseprite => Folder1/Folder2
sprite_from_path :: proc(path: string) -> Sprite {
	lo := len("assets/legacy_fantasy_high_forest/")
	hi := len(path) - len(".aseprite")
	for path[hi] != '/' {
		hi -= 1
	}
	return Sprite(path[lo:hi])
}

main :: proc() {
	ctx: Context
	arena := mem.Arena{data = make([]u8, mem.Gigabyte)}
	ctx.arena = mem.arena_allocator(&arena)

	win32_cursor := win32.GetCursor()

	dpi_aware := false
	if win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_SYSTEM_AWARE) {
		dpi_aware = true
	}
	dpi := win32.GetDpiForSystem()

	win32_instance := win32.HINSTANCE(win32.GetModuleHandleW(nil))
	ensure(win32_instance != nil, win32_last_error_message())

	window_class := win32.WNDCLASSEXW{
	   cbSize = size_of(win32.WNDCLASSEXW),
	   lpfnWndProc = _win32_event_proc,
	   hInstance = win32.HANDLE(win32_instance),
	   lpszClassName = L("jo_class"),
	}
	{
	   res := win32.RegisterClassExW(&window_class)
	   ensure(res != 0, win32_last_error_message())
	}

	// screen dimensions
	{
	   monitor := win32.MonitorFromPoint({0, 0}, .MONITOR_DEFAULTTOPRIMARY)
	   monitor_info := win32.MONITORINFO{cbSize = size_of(win32.MONITORINFO)}
	   res := win32.GetMonitorInfoW(monitor, &monitor_info)
	   ensure(res == true, win32_last_error_message())
	   ctx.monitor.w = int(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left)
	   ctx.monitor.h = int(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top)
	}

	// window
	win32_window: win32.HWND
	title := "jo"
	{
	   window_style, window_ex_style: u32
	   window_rect: Rect
	   when !JO_FULLSCREEN {
		   window_style = win32.WS_CAPTION | win32.WS_SYSMENU
		   window_ex_style = 0

		   win32_rect := win32.RECT{i32(ctx.monitor.w/4), i32(ctx.monitor.h/4), i32(ctx.monitor.w/4*3), i32(ctx.monitor.h/4*3)}

		   res := win32.AdjustWindowRectExForDpi(&win32_rect, window_style, false, window_ex_style, u32(dpi))
		   ensure(res == true, win32_last_error_message())

		   window_rect = transmute(Rect)win32_rect
	   } else {
		   window_rect.max.x = ctx.monitor.w
		   window_rect.max.y = ctx.monitor.h
		   window_style = win32.WS_POPUP
		   window_ex_style = 0
	   }
	   when JO_TOPMOST {
		   window_ex_style |= win32.WS_EX_TOPMOST
	   }

	   win32_window = win32.CreateWindowExW(
		   window_ex_style, 
		   window_class.lpszClassName, 
		   win32.utf8_to_wstring(title),
		   window_style, 
		   window_rect.min.x, 
		   window_rect.min.y, 
		   window_rect.max.x - window_rect.min.x, 
		   window_rect.max.y - window_rect.min.y, 
		   nil, 
		   nil,
		   win32.HANDLE(win32_instance), 
		   nil)
	   ensure(win32_window != nil, win32_last_error_message())
	}

	// set event callback user data
	{
		win32.SetLastError(0)
		win32.SetWindowLongPtrW(win32_window, win32.GWLP_USERDATA, transmute(win32.LONG_PTR)&ctx)
		ensure(win32.GetLastError() == 0, win32_last_error_message())
	}

	{
	   dev_mode := win32.DEVMODEW{dmSize = size_of(win32.DEVMODEW)}
	   res := win32.EnumDisplaySettingsW(nil, win32.ENUM_CURRENT_SETTINGS, &dev_mode)
	   ensure(res == true, "Failed to enumerate display settings.")
	   refresh_rate := dev_mode.dmDisplayFrequency
	   ctx.fixed_dt = 1.0/f32(refresh_rate)
	}

	when JO_FULLSCREEN {
	   win32.SetCursor(nil)
	}

	try_connect_gamepad(&ctx)

	sprite_player_idle = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Character/Idle/Idle.aseprite")
	sprite_player_run = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Character/Run/Run.aseprite")
	sprite_player_jump_start = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Character/Jump-Start/Jump-Start.aseprite")
	sprite_player_jump_end = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Character/Jump-End/Jump-End.aseprite")
	sprite_player_attack = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Character/Attack-01/Attack-01.aseprite")
	sprite_player_die = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Character/Dead/Dead.aseprite")

	sprite_boar_idle = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Idle/Idle.aseprite")
	sprite_boar_walk = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Walk/Walk-Base.aseprite")
	sprite_boar_run = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Run/Run.aseprite")
	sprite_boar_hit = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Hit-Vanish/Hit.aseprite")

	sprite_tiles = sprite_load(&ctx, "assets/legacy_fantasy_high_forest/Assets/Tiles.aseprite")

	sd_player_idle := ctx.sprites[sprite_player_idle]
	sd_player_run := ctx.sprites[sprite_player_run]
	sd_player_jump_start := ctx.sprites[sprite_player_jump_start]

	last_tick := time.tick_now()

	ctx.running = true
	for ctx.running {
		if ctx.gamepad.connected {
		   try_connect_gamepad(&ctx)
		}

		@static window_ready := -1
		if window_ready == -1 {
			window_ready += 1
		} else if window_ready == 0 {
			window_ready += 1
			win32.ShowWindow(win32_window, win32.SW_SHOW)
		}

		for {
			message: win32.MSG
			if win32.PeekMessageW(&message, win32_window, 0, 0, win32.PM_REMOVE) {
			   win32.TranslateMessage(&message)
			   win32.DispatchMessageW(&message)
			   continue
			}
			break
		}

		tick := time.tick_now()
		dt_dur := time.tick_diff(last_tick, tick)
		last_tick = tick
		ctx.variable_dt = f32(dt_dur)/f32(time.Second)

		// TODO: update
	}

}


_win32_event_proc :: proc "system" (window: win32.HWND, message: win32.UINT, w_param: win32.WPARAM, l_param: win32.LPARAM) -> win32.LRESULT {
	context = runtime.default_context()

	// It is possible that the window pointer has not been set yet, because Windows already pushed events before that.
	ctx := transmute(^Context)win32.GetWindowLongPtrW(window, win32.GWLP_USERDATA)
	if ctx == nil {
		return win32.DefWindowProcW(window, message, w_param, l_param)
	}

	result := win32.LRESULT(0)

	switch message {
		case win32.WM_CLOSE, win32.WM_DESTROY, win32.WM_QUIT:
			ctx.running = false

/*
		case win32.WM_KEYDOWN:

		case win32.WM_KEYUP:
*/  

		case:
			result = win32.DefWindowProcW(window, message, w_param, l_param)
			
	}

	return result
}

win32_last_error_message :: proc() -> (string, mem.Allocator_Error) #optional_allocator_error {
	error := win32.GetLastError()
	buf: [512]u16 = ---
	win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
	res, err := win32.wstring_to_utf8(cstring16(raw_data(buf[:])), -1)
	return strings.trim_suffix(res, "\n"), err
}

win32_hresult_message :: proc(hr: win32.HRESULT) -> (string, mem.Allocator_Error) #optional_allocator_error {
	buf: [512]u16 = ---
	win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, u32(hr), 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
	res, err := win32.wstring_to_utf8(cstring16(raw_data(buf[:])), -1)
	return strings.trim_suffix(res, "\n"), err
}

Gamepad_Button :: enum u16 {
	Dpad_Up,
	Dpad_Down,
	Dpad_Left,
	Dpad_Right,
	Menu_Left,
	Menu_Right,
	Left_Stick,
	Right_Stick,
	Left_Bumper,
	Right_Bumper,
	A = 12,
	B,
	X,
	Y,
}

Gamepad_Buttons :: distinct bit_set[Gamepad_Button; u16]

Gamepad :: struct {
	connected: bool,

	buttons: Gamepad_Buttons,

	left_trigger: f32,
	right_trigger: f32,
	left_stick: [2]f32,
	right_stick: [2]f32,

	trigger_deadzone: f32,
	left_stick_deadzone: f32,
	right_stick_deadzone: f32,
}

try_connect_gamepad :: proc "contextless" (ctx: ^Context) {
	state: win32.XINPUT_STATE = ---
	
	result := win32.XInputGetState(win32.XUSER(0), &state)
	if result != .SUCCESS {
		ctx.gamepad = {}
		return
	}
	xinput_gamepad := state.Gamepad

	g := &ctx.gamepad
	g.connected = true

	g.buttons = transmute(Gamepad_Buttons)xinput_gamepad.wButtons
	
	g.left_trigger = f32(xinput_gamepad.bLeftTrigger)/f32(max(win32.BYTE))
	g.right_trigger = f32(xinput_gamepad.bRightTrigger)/f32(max(win32.BYTE))
	g.left_stick.x = f32(xinput_gamepad.sThumbLX)/f32(max(win32.SHORT))
	g.left_stick.y = f32(xinput_gamepad.sThumbLY)/f32(max(win32.SHORT))
	g.right_stick.x = f32(xinput_gamepad.sThumbRX)/f32(max(win32.SHORT))
	g.right_stick.y = f32(xinput_gamepad.sThumbRY)/f32(max(win32.SHORT))

	g.trigger_deadzone = f32(win32.XINPUT_GAMEPAD_TRIGGER_THRESHOLD)/f32(max(win32.BYTE))
	g.left_stick_deadzone = f32(win32.XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)/f32(max(win32.SHORT))
	g.right_stick_deadzone = f32(win32.XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)/f32(max(win32.SHORT))

	g.left_trigger = remove_deadzone(g.left_trigger, g.trigger_deadzone)
	g.right_trigger = remove_deadzone(g.right_trigger, g.trigger_deadzone)
	g.left_stick.x = remove_deadzone(g.left_stick.x, g.left_stick_deadzone)
	g.left_stick.y = remove_deadzone(g.left_stick.y, g.left_stick_deadzone)
	g.right_stick.x = remove_deadzone(g.right_stick.x, g.right_stick_deadzone)
	g.right_stick.y = remove_deadzone(g.right_stick.y, g.right_stick_deadzone)

	g.left_stick.x, g.left_stick.y = clamp_magnitude(g.left_stick.x, g.left_stick.y)
	g.right_stick.x, g.right_stick.y = clamp_magnitude(g.right_stick.x, g.right_stick.y)

	remove_deadzone :: proc "contextless" (v, d: f32) -> f32 {
		s := math.sign(v)
		v := abs(v)
		minv := max(v-d, 0)
		maxv := 1-d
		return s*v*minv/maxv
	}

	clamp_magnitude :: proc "contextless" (x0, y0: f32) -> (x1, y1: f32) {
		squared_magnitude := x0*x0 + y0*y0
		if squared_magnitude > 1 {
			scale := 1.0 / math.sqrt(squared_magnitude)
			x1 = x0 * scale
			y1 = y0 * scale
		} else {
			x1 = x0
			y1 = y0 
		}
		return
	}
}

gamepad_set_vibration :: proc(ctx: ^Context, left_motor, right_motor: f32, loc := #caller_location) {
	left_motor := left_motor
	right_motor := right_motor
	assert(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1, "Motors must be in range [0.0, 1.0].", loc)
	if !ctx.gamepad.connected {
		return
	}

	xinput_vibration: win32.XINPUT_VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	res := win32.XInputSetState(win32.XUSER(0), &xinput_vibration) == .SUCCESS

	assert(res, "Failed to set vibration.", loc)
}

sprite_get_origin :: proc "contextless" (sd: Sprite_Desc, dir: i32) -> [2]i32 {
	origin := sd.origin
	if (dir == -1) 
	{
		origin.x = sd.size.x - origin.x;
	}
	return origin;
}

entity_get_origin :: proc "contextless" (ctx: ^Context, entity: ^Entity) -> [2]i32 {
	return sprite_get_origin(ctx.sprites[entity.anim.sprite], entity.dir)
}

get_origin :: proc {
	sprite_get_origin,
	entity_get_origin,
}

anim_reset :: proc(anim: ^Anim) {
	anim.frame_idx = 0
	anim.dt_accumulator = 0.0
	anim.ended = false
}

anim_set_sprite :: proc(anim: ^Anim, sprite: Sprite) -> bool {
    sprite_changed := false
    if (anim.sprite != sprite) 
    {
        sprite_changed = true;
        anim_reset(anim)
        anim.sprite = sprite
    }
    return sprite_changed
}

anim_update :: proc "contextless" (ctx: ^Context, anim: ^Anim, loop: bool) {
	sd := ctx.sprites[anim.sprite]
	dur := sd.frames[anim.frame_idx].dur
	dt := ctx.fixed_dt
	num_frames := len(sd.frames)

    if (loop || !anim.ended) 
    {
        anim.dt_accumulator += dt
        if (anim.dt_accumulator >= dur) 
        {
            anim.dt_accumulator = 0.0
            anim.frame_idx += 1
            if (int(anim.frame_idx) >= num_frames) 
            {
                if loop {
                	anim.frame_idx = 0
                } else {
                    anim.frame_idx -= 1
                    anim.ended = true
                }
            }
        }
    }
}

reset_game :: proc(ctx: ^Context) {
	player := &ctx.level.entities[0]
	
	anim_reset(&player.anim)
	anim_set_sprite(&player.anim, sprite_player_idle)
	player.pos = player.start_pos
	player.state = .Free
	player.vel = {}
	player.dir = 1

	for entity_idx := 1; entity_idx < len(ctx.level.entities); entity_idx += 1 {
		enemy := &ctx.level.entities[entity_idx]

		anim_reset(&enemy.anim)
		if (enemy.type == .Boar) {
			anim_set_sprite(&enemy.anim, sprite_boar_idle)
		} 
		// else if (entity.type == .Whatever) {}
		enemy.pos = enemy.start_pos
		enemy.state = .Free
		enemy.vel = {}
		enemy.dir = 1
	}	
}

ase_read_chunk :: proc(rd: io.Reader) -> (chunk: []byte, chunk_type: ase.Chunk_Type) {
	chunk_header: ase.Chunk_Header
	io.read_ptr(rd, &chunk_header, size_of(chunk_header))

	if chunk_header.size != size_of(ase.Chunk_Header) {
		chunk = make_aligned([]byte, chunk_header.size - size_of(ase.Chunk_Header), align_of(int))
		io.read(rd, chunk)
	}

	chunk_type = chunk_header.type

	return
}

compare_sprite_cells :: proc(a, b: Sprite_Cell) -> bool {
	a_order := i32(a.layer_idx) + a.z_idx
	b_order := i32(b.layer_idx) + b.z_idx
	if (a_order < b_order) || ((a_order == b_order) && (a.z_idx < b.z_idx)) {
	    return true
	} else if (b_order < a_order) || ((b_order == a_order) && (b.z_idx < a.z_idx)) {
	    return false
	}
	return true
}

ase_string :: proc(s: ^ase.String) -> string {
	p := uintptr(s)
	p += size_of(ase.String)
	l := int(s.len)
	return string(slice.bytes_from_ptr(rawptr(p), l))
}