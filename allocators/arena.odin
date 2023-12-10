package allocators

import win32 "core:sys/windows"
import "core:mem"

Arena :: struct {
    memory: rawptr,
    reserved: uint,
    committed: uint,
    offset: uint,
}

arena_init :: proc(arena: ^Arena, reserved: uint = mem.Gigabyte) -> bool {
    arena.reserved = reserved
    arena.memory = win32.VirtualAlloc(nil, arena.reserved, win32.MEM_RESERVE, win32.PAGE_READWRITE)
    if arena.memory == nil do return false
    arena.committed = 4096
    arena.memory = win32.VirtualAlloc(arena.memory, arena.committed, win32.MEM_COMMIT, win32.PAGE_READWRITE)
    if arena.memory == nil do return false
    arena.offset = 0
    return true
}

arena_allocator :: proc(arena: ^Arena) -> mem.Allocator {
    return {arena_proc, arena}
}

arena_proc :: proc(data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, loc := #caller_location) -> ([]byte, mem.Allocator_Error) {
    arena := (^Arena)(data)

    #partial switch mode {
        case .Alloc:
            ptr := rawptr(uintptr(arena.memory) + uintptr(arena.offset))
            ptr = mem.align_forward(ptr, uintptr(alignment))

            offset := uint(uintptr(ptr) - uintptr(arena.memory))
            offset += uint(size)
            if offset > arena.reserved do return nil, .Out_Of_Memory
            if offset > arena.committed {
                arena.committed = offset
                arena.committed = mem.align_forward_uint(arena.committed, 4096)
                arena.memory = win32.VirtualAlloc(arena.memory, arena.committed, win32.MEM_COMMIT, win32.PAGE_READWRITE)
                if arena.memory == nil do return nil, .Out_Of_Memory
            }
            arena.offset = offset

            return ([^]byte)(ptr)[:size], .None
        
        case .Free_All:
            mem.zero(arena.memory, int(arena.offset))
            arena.offset = 0
            return nil, .None
            
        case .Query_Features:
            set := (^mem.Allocator_Mode_Set)(old_memory)
            if set != nil {
                set^ = {.Alloc, .Free_All, .Query_Features}
            }
            return nil, nil
    }

    return nil, .Mode_Not_Implemented
}