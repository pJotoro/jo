package jo

import "base:intrinsics"
import "base:runtime"
import "core:time"
import "core:strings"
import "core:math"
import "core:bytes"
import "core:io"

import win32 "core:sys/windows"
L :: intrinsics.constant_utf16_cstring

import ase "aseprite"

JO_DEBUG :: #config(JO_DEBUG, ODIN_DEBUG)
JO_FULLSCREEN :: #config(JO_FULLSCREEN, !JO_DEBUG)
JO_TOPMOST :: #config(JO_TOPMOST, JO_FULLSCREEN)
VULKAN_DEBUG :: #config(VULKAN_DEBUG, ODIN_DEBUG)

Rect :: struct {
	x, y, w, h: int,
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
	dst_buf: rawptr, // invalid after VulkanCreateStaticStagingBuffer.

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
	origin: [2]i32;
	size: [2]i32;
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

Context :: struct {
	running: bool,
	monitor: struct {
		w, h: int,
	},
	gamepad: Gamepad,
	sprites: map[Sprite]Sprite_Desc,
}

spr_player_idle: Sprite
spr_player_run: Sprite
spr_player_jump_start: Sprite
spr_player_jump_end: Sprite
spr_player_attack: Sprite
spr_player_die: Sprite

spr_boar_idle: Sprite
spr_boar_walk: Sprite
spr_boar_run: Sprite
spr_boar_hit: Sprite

spr_tiles: Sprite

// Sprite should just be the name of the sprite, without the rest of the path (folders, file extension).
sprite_load :: proc(ctx: ^Context, $path: string) -> Sprite {
	buf := #load(path)
	return _sprite_load(ctx, path, buf)

	_sprite_load :: proc(ctx: ^Context, path: string, buf: []byte) {
		sprite := sprite_from_path(path) // TODO
		ctx.sprites[sprite] = {}

		bytes_reader: bytes.Reader
		rd := bytes.reader_init(&bytes_reader, buf)

		header: Ase_Header
		io.read_ptr(rd, &header, size_of(header))
		SDL_ReadStructChecked(fs, &header);
		SDL_assert(header.magic_number == 0xA5E0);

		SDL_assert(header.color_depth == 32);
		SDL_assert((header.pixel_w == 0 || header.pixel_w == 1) && (header.pixel_h == 0 || header.pixel_h == 1));
		SDL_assert(header.grid_x == 0);
		SDL_assert(header.grid_y == 0);
		SDL_assert(header.grid_w == 0 || header.grid_w == 16);
		SDL_assert(header.grid_h == 0 || header.grid_h == 16);

		sd->size.x = (int32_t)header.w;
		sd->size.y = (int32_t)header.h;

		sd->num_frames = header.num_frames;
		sd->frames = ArenaAlloc(&ctx->arena, sd->num_frames, SpriteFrame);

		// The hitbox layer and origin layer are specialized layers whose image data is not to be used for rendering.
		// We must search for them so that we can extract information out of them.
		uint16_t hitbox_layer_idx = UINT16_MAX;
		uint16_t origin_layer_idx = UINT16_MAX;

		for (size_t frame_idx = 0; frame_idx < sd->num_frames; frame_idx += 1) 
		{
			ASE_Frame frame;
			SDL_ReadStructChecked(fs, &frame);
			SDL_assert(frame.magic_number == 0xF1FA);

			// Would mean this aseprite file is very old.
			SDL_assert(frame.num_chunks != 0);

			sd->frames[frame_idx].dur = ((float)frame.frame_dur)/(1000.0f/60.0f);

			int64_t fs_pos = SDL_TellIO(fs);

			// NOTE: According to the Aseprite spec, all layer chunks are found in the first frame, but not necessarily before everything else in that frame.
			// https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md#layer-chunk-0x2004
			if (frame_idx == 0) 
			{
				for (size_t chunk_idx = 0, layer_idx = 0; chunk_idx < frame.num_chunks; chunk_idx += 1) 
				{
					void* raw_chunk; 
					size_t raw_chunk_size;
					ASE_ChunkType chunk_type = ASE_ReadChunk(fs, &ctx->stack, &raw_chunk, &raw_chunk_size);
					if (chunk_type == ASE_ChunkType_Layer) 
					{
						ASE_LayerChunk* chunk = raw_chunk;
						SDL_assert(chunk->layer_name.len > 0);

						char* layer_name = StackAlloc(&ctx->stack, chunk->layer_name.len + 1, char);
						SDL_strlcpy(layer_name, (const char*)(chunk+1), chunk->layer_name.len + 1);

						if (SDL_strcmp(layer_name, "Hitbox") == 0) 
						{
							bool hitbox_layer_is_unique = (hitbox_layer_idx == UINT16_MAX);
							SDL_assert(hitbox_layer_is_unique);
							hitbox_layer_idx = (uint16_t)layer_idx;
						} 
						else if (SDL_strcmp(layer_name, "Origin") == 0) 
						{
							bool origin_layer_is_unique = (origin_layer_idx == UINT16_MAX);
							SDL_assert(origin_layer_is_unique);
							origin_layer_idx = (uint16_t)layer_idx;					
						}
						layer_idx += 1;

						StackFree(&ctx->stack, layer_name);
					}

					StackFree(&ctx->stack, raw_chunk);
				}

				SDL_SeekIO(fs, fs_pos, SDL_IO_SEEK_SET);
			}
			
			for (size_t chunk_idx = 0; chunk_idx < frame.num_chunks; chunk_idx += 1)
			{
				void* raw_chunk;
				size_t raw_chunk_size;
				ASE_ChunkType chunk_type = ASE_ReadChunk(fs, &ctx->stack, &raw_chunk, &raw_chunk_size);

				if (chunk_type == ASE_ChunkType_Cell)
				{
					ASE_CellChunk* chunk = raw_chunk;
					if (chunk->layer_idx == hitbox_layer_idx)
					{
						sd->frames[frame_idx].hitbox = (Rect)
						{
							.min.x = (int32_t)chunk->x,
							.min.y = (int32_t)chunk->y,
							.max.x = (int32_t)(chunk->x + chunk->w),
							.max.y = (int32_t)(chunk->y + chunk->h),
						};
					} 
					else if (chunk->layer_idx == origin_layer_idx) 
					{
						if (frame_idx == 0)
						{
							sd->origin = (ivec2s){(int32_t)chunk->x, (int32_t)chunk->y};
						}
					} 
					else 
					{
						sd->frames[frame_idx].num_cells += 1;
						SDL_assert(chunk->type == ASE_CellType_CompressedImage);
					}
				}

				StackFree(&ctx->stack, raw_chunk);
			}

			if (sd->frames[frame_idx].num_cells > 0) 
			{
				sd->frames[frame_idx].cells = ArenaAlloc(&ctx->arena, sd->frames[frame_idx].num_cells, SpriteCell);
				size_t cell_idx = 0;

				SDL_SeekIO(fs, fs_pos, SDL_IO_SEEK_SET);

				for (size_t chunk_idx = 0; chunk_idx < frame.num_chunks; chunk_idx += 1) 
				{
					void* raw_chunk; 
					size_t raw_chunk_size;
					ASE_ChunkType chunk_type = ASE_ReadChunk(fs, &ctx->stack, &raw_chunk, &raw_chunk_size);

					ASE_CellChunk* chunk = raw_chunk;
					if (chunk_type == ASE_ChunkType_Cell && 
						chunk->layer_idx != hitbox_layer_idx && 
						chunk->layer_idx != origin_layer_idx) 
					{

						SpriteCell cell = 
						{
							.origin.x = (int32_t)chunk->x,
							.origin.y = (int32_t)chunk->y,
							.z_idx = chunk->z_idx,
							.layer_idx = (uint32_t)chunk->layer_idx,
							.size.x = (int32_t)chunk->w,
							.size.y = (int32_t)chunk->h,
						};

						SDL_assert(cell.size.x != 0 && cell.size.y != 0);
						size_t dst_buf_size = cell.size.x*cell.size.y * sizeof(uint32_t);
						cell.dst_buf = SDL_malloc(dst_buf_size); SDL_CHECK(cell.dst_buf);

						// But I thought calling malloc was bad! What gives?
						// In this case, it's fine, because each destination buffer is getting allocated one after the other, only to later be freed one after the other.
						// Which is to say, there is no way for heap fragmentation to happen given the way I'm using it.

						// It's the zero-sized array at the end of ASE_CellChunk.
						size_t src_buf_size = raw_chunk_size - sizeof(ASE_CellChunk) - 2;
						void* src_buf = (void*)((&chunk->h)+1);

						// Decompress the image data.
						SPALL_BUFFER_BEGIN_NAME("INFL_ZInflate");
						size_t res = INFL_ZInflate(cell.dst_buf, dst_buf_size, src_buf, src_buf_size);
						SPALL_BUFFER_END();
						SDL_assert(res > 0);

						SDL_assert(cell_idx < sd->frames[frame_idx].num_cells);
						sd->frames[frame_idx].cells[cell_idx++] = cell;
					}

					StackFree(&ctx->stack, raw_chunk);
				}

				// Makes the cells draw in the correct order.
				SDL_assert(frame_idx < sd->num_frames);
				SDL_qsort(
					sd->frames[frame_idx].cells, 
					sd->frames[frame_idx].num_cells, 
					sizeof(SpriteCell), 
					(SDL_CompareCallback)CompareSpriteCells);
			}
		}

		SDL_CloseIO(fs);
		SPALL_BUFFER_END();
		ctx->num_sprites++;
		return sprite;
	}
}

main :: proc() {
	ctx: Context

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
	refresh_rate: int
	{
	   window_style, window_ex_style: u32
	   window_rect: Rect
	   when !JO_FULLSCREEN {
		   window_style = win32.WS_CAPTION | win32.WS_SYSMENU
		   window_ex_style = 0

		   win32_rect := win32.RECT{i32(ctx.monitor.w/4), i32(ctx.monitor.h/4), i32(ctx.monitor.w/4*3), i32(ctx.monitor.h/4*3)}

		   res := win32.AdjustWindowRectExForDpi(&win32_rect, window_style, false, window_ex_style, u32(dpi))
		   ensure(res == true, win32_last_error_message())

		   window_rect = Rect {
			   x = int(win32_rect.left),
			   y = int(win32_rect.top),
			   w = int(win32_rect.right - win32_rect.left),
			   h = int(win32_rect.bottom - win32_rect.top),
		   }
	   } else {
		   window_rect.w = ctx.monitor.w
		   window_rect.h = ctx.monitor.h
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
		   i32(window_rect.x), 
		   i32(window_rect.y), 
		   i32(window_rect.w), 
		   i32(window_rect.h), 
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
	   refresh_rate = int(dev_mode.dmDisplayFrequency)
	}

	when JO_FULLSCREEN {
	   win32.SetCursor(nil)
	}

	try_connect_gamepad(&ctx, 0)

	spr_player_idle = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Character/Idle/Idle.aseprite")
	spr_player_run = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Character/Run/Run.aseprite")
	spr_player_jump_start = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Character/Jump-Start/Jump-Start.aseprite")
	spr_player_jump_end = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Character/Jump-End/Jump-End.aseprite")
	spr_player_attack = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Character/Attack-01/Attack-01.aseprite")
	spr_player_die = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Character/Dead/Dead.aseprite")

	spr_boar_idle = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Idle/Idle.aseprite")
	spr_boar_walk = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Walk/Walk-Base.aseprite")
	spr_boar_run = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Run/Run.aseprite")
	spr_boar_hit = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Mob/Boar/Hit-Vanish/Hit.aseprite")

	spr_tiles = sprite_load(ctx, "assets/legacy_fantasy_high_forest/Assets/Tiles.aseprite")

	last_tick := time.tick_now()
	dt: f32

	ctx.running = true
	for ctx.running {
		if ctx.gamepad.connected {
		   try_connect_gamepad(0)
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
		dt = f32(dt_dur)/f32(time.Second)

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

win32_last_error_message :: proc() -> (string, runtime.Allocator_Error) #optional_allocator_error {
	error := win32.GetLastError()
	buf: [512]u16 = ---
	win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
	res, err := win32.wstring_to_utf8(cstring16(raw_data(buf[:])), -1)
	return strings.trim_suffix(res, "\n"), err
}

win32_hresult_message :: proc(hr: win32.HRESULT) -> (string, runtime.Allocator_Error) #optional_allocator_error {
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

try_connect_gamepad :: proc "contextless" (ctx: ^Context, g_idx: int) {
	state: win32.XINPUT_STATE = ---
	
	result := win32.XInputGetState(win32.XUSER(g_idx), &state)
	if result != .SUCCESS {
		ctx.gamepads[g_idx] = {}
		return
	}
	xinput_gamepad := state.Gamepad

	g := &ctx.gamepads[g_idx]
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

gamepad_set_vibration :: proc(ctx: ^Context, g_idx: int, left_motor, right_motor: f32, loc := #caller_location) {
	left_motor := left_motor
	right_motor := right_motor
	assert(left_motor >= 0 && left_motor <= 1 && right_motor >= 0 && right_motor <= 1, "Motors must be in range [0.0, 1.0].", loc)
	if !ctx.gamepads[g_idx].connected {
		return
	}

	xinput_vibration: win32.XINPUT_VIBRATION
	xinput_vibration.wLeftMotorSpeed = win32.WORD(left_motor * f32(max(u16)))
	xinput_vibration.wRightMotorSpeed = win32.WORD(right_motor * f32(max(u16)))
	res := win32.XInputSetState(win32.XUSER(g_idx), &xinput_vibration) == .SUCCESS

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
	dur := sd.frames[anim.frame_idx].dur;
	num_frames := sd.num_frames;

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

reset_game :: proc(ctx: ^Context) 
{
	player := &ctx.level.entities[0]
	
	anim_reset(&player.anim)
	anim_set_sprite(&player.anim, player_idle)
	player.pos = player.start_pos
	player.state = .Free
	player.vel = {}
	player.dir = 1

	for entity_idx := 1; entity_idx < len(ctx.level.entities); entity_idx += 1 {
		enemy := &ctx.level.entities[entity_idx]

		anim_reset(&enemy.anim)
		if (enemy.type == .Boar) {
			anim_set_sprite(&enemy.anim, boar_idle)
		} 
		// else if (entity.type == .Whatever) {}
		enemy.pos = enemy.start_pos
		enemy.state = .Free
		enemy.vel = {}
		enemy.dir = 1
	}	
}

static ivec2s GetTilesetDimensions(Context* ctx, Sprite tileset) 
{
	SpriteDesc* sd = SpriteGetDesc(ctx, tileset);
	SDL_assert(sd->num_frames == 1);
	SDL_assert(sd->frames[0].num_cells == 1);
	return sd->size;
}

static bool GetSpriteHitbox(Context* ctx, Sprite sprite, size_t frame_idx, int32_t dir, Rect* hitbox) 
{
	bool res = false;
	SpriteDesc* sd = SpriteGetDesc(ctx, sprite); SDL_assert(sd);
	SDL_assert(frame_idx < sd->num_frames); 
	SpriteFrame* frame = &sd->frames[frame_idx];
	SDL_assert(hitbox);
	*hitbox = frame->hitbox;
	if (dir == -1) 
	{
		hitbox->min.x = -frame->hitbox.max.x + sd->size.x;
		hitbox->max.x = -frame->hitbox.min.x + sd->size.x;
	}
	if (hitbox->max.x > hitbox->min.x && hitbox->max.y > hitbox->min.y) 
	{
		res = true;
	}
	return res;
}

static Rect EntityGetHitbox(Context* ctx, Entity* entity) 
{
	SPALL_BUFFER_BEGIN();
	Rect hitbox = {0};
	SpriteDesc* sd = SpriteGetDesc(ctx, entity->anim.sprite);

	/**
	 * First, try to find the hitbox at the current frame index or earlier.
	 * If that doesn't work, try to find the hitbox at the current frame index plus one or later.
	 * If that doesn't work, trigger an assertion.
	 */
	bool res = false;
	for (
		ssize_t frame_idx = (ssize_t)entity->anim.frame_idx; 
		frame_idx >= 0 && !res; 
		frame_idx -= 1) 
	{
		res = GetSpriteHitbox(ctx, entity->anim.sprite, (size_t)frame_idx, entity->dir, &hitbox); 
	}
	if (!res) 
	{
		for (
			size_t frame_idx = entity->anim.frame_idx + 1; 
			frame_idx < sd->num_frames && !res; 
			frame_idx += 1) 
		{
			res = GetSpriteHitbox(ctx, entity->anim.sprite, frame_idx, entity->dir, &hitbox);
		}
	}
	SDL_assert(res);

	SPALL_BUFFER_END();
	return hitbox;
}

static Rect EntityGetRect(Context* ctx, Entity* entity)
{
	Rect res = EntityGetHitbox(ctx, entity);
	res.min = glms_ivec2_add(res.min, entity->pos); 
	res.max = glms_ivec2_add(res.max, entity->pos);
	ivec2s origin = EntityGetOrigin(ctx, entity); 
	res.min = glms_ivec2_sub(res.min, origin); 
	res.max = glms_ivec2_sub(res.max, origin); 
	return res;
}

static bool EntitiesIntersect(Context* ctx, Entity* a, Entity* b) 
{
	SPALL_BUFFER_BEGIN();
	bool res = false;

    if (a->state != EntityState_Inactive && b->state != EntityState_Inactive)
    {
    	Rect ha = EntityGetRect(ctx, a);
    	Rect hb = EntityGetRect(ctx, b);
    	res = RectsIntersect(ha, hb);
    } 

    SPALL_BUFFER_END();
    return res;
}