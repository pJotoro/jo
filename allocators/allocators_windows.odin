package allocators

import "core:runtime"
import "core:mem"
import win32 "core:sys/windows"

Arena :: struct {
	data: [^]byte,
	size: uintptr,
	offset: uintptr,
	committed: uintptr,
}

arena_init :: proc(arena: ^Arena, size := mem.Gigabyte, loc := #caller_location) {
	assert(size % 4096 == 0, "size must be page aligned", loc)
	arena.data = win32.VirtualAlloc(nil, uint(size), win32.MEM_RESERVE, win32.PAGE_READWRITE)
	if arena.data == nil do panic(loc)
	arena.size = uintptr(size)
	arena.data = win32.VirtualAlloc(arena.data, 4096, win32.MEM_COMMIT, win32.PAGE_READWRITE)
	if arena.data == nil do panic(loc)
	arena.committed = 4096
}

@(require_results)
arena_allocator :: proc(arena: ^Arena) -> mem.Allocator {
	return Allocator{
		procedure = arena_allocator_procedure,
		data = arena,
	}
}

arena_allocator_proc :: proc(allocator_data: rawptr, mode: Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, location := #caller_location) -> ([]byte, Allocator_Error)  {
	arena := (^Arena)(allocator_data)

	switch mode {
		case .Alloc:
			arena.offset = mem.align_forward_uintptr(arena.offset, alignment)
			if arena.offset + uintptr(size) >= arena.size do return nil, .Out_Of_Memory
			if arena.offset + uintptr(size) >= arena.committed {
				arena.committed = mem.align_forward_uintptr(arena.offset + uintptr(size), arena.committed)
				arena.data = win32.VirtualAlloc(arena.data, uint(arena.committed), win32.MEM_COMMIT, win32.PAGE_READWRITE)
				if arena.data == nil do panic(location)
			}
			data := arena.data[int(arena.offset):int(arena.offset) + size]
			arena.offset += size
			return data, .None

		case .Free_All:
			mem.zero(arena.data, arena.offset)
			arena.data = win32.VirtualAlloc(arena.data, uint(arena.offset), win32.MEM_RESET, win32.PAGE_READWRITE)
			if arena.data == nil do panic(location)
			arena.offset = 0

		case .Query_Features:
			if old_memory != nil {
				set := (^mem.Allocator_Mode_Set)(old_memory)
				set^ = {.Alloc, .Free_All, .Query_Features}
			}
			return nil, nil

		case .Free, .Resize, .Query_Info, .Alloc_Non_Zeroed:
			return nil, .Mode_Not_Implemented
	}
}

panic :: proc(loc := #caller_location) {
    when !ODIN_DISABLE_ASSERT {
        error := win32.GetLastError()
        buf: [1024]u16 = ---
        win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), size_of(buf), nil)
        message, _ := win32.wstring_to_utf8(raw_data(buf[:]), len(buf))
        runtime.panic(message, loc)
    }
}