package allocators

import win32 "core:sys/windows"
import "core:os"
import "core:mem"
import "core:mem/virtual"

Arena :: struct {
    data: []byte,
    end: rawptr,
}

arena_init :: proc(arena: ^Arena, size: uint = mem.Gigabyte) -> mem.Allocator_Error {
    arena.data = virtual.reserve_and_commit(size) or_return
    arena.end = raw_data(arena.data)
    return .None
}

arena_allocator :: proc(arena: ^Arena) -> mem.Allocator {
    return {arena_proc, arena}
}

arena_proc :: proc(data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, loc := #caller_location) -> ([]byte, mem.Allocator_Error) {
    arena := (^Arena)(data)

    #partial switch mode {
        case .Alloc, .Alloc_Non_Zeroed:
            arena.end = mem.align_forward(arena.end, uintptr(alignment))
            ptr := arena.end
            arena.end = rawptr(uintptr(arena.end) + uintptr(size))
            return ([^]byte)(ptr)[:size], .None
        
        case .Free_All:
            arena.end = raw_data(arena.data)
            return nil, .None
            
        case .Query_Features:
            set := (^mem.Allocator_Mode_Set)(old_memory)
            if set != nil {
                set^ = {.Alloc, .Alloc_Non_Zeroed, .Free_All, .Query_Features}
            }
            return nil, nil
    }

    return nil, .Mode_Not_Implemented
}