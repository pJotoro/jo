package allocators

import "core:mem"

@(private="file")
Key :: struct {
    file_path: string,
    line: i32,
}

Allocation :: []byte

Persistent_Allocator :: struct {
    allocations: map[Key]Allocation,
    backing_allocator: mem.Allocator,
}

persistent_allocator_init :: proc(persistent_allocator: ^Persistent_Allocator, backing_allocator: mem.Allocator, loc := #caller_location) {
    features := mem.query_features(backing_allocator)
    assert(.Alloc in features, "bogus allocator", loc)
    persistent_allocator.backing_allocator = backing_allocator
    context.allocator = backing_allocator
    persistent_allocator.allocations = make(map[Key]Allocation)
}

persistent_allocator :: proc(persistent_allocator: ^Persistent_Allocator, loc := #caller_location) -> mem.Allocator {
    assert(persistent_allocator.allocations != nil, "forgot to initialize persistent allocator", loc)
    return {persistent_allocator_proc, persistent_allocator}
}

persistent_allocator_proc :: proc(data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, loc := #caller_location) -> ([]byte, mem.Allocator_Error) {
    data := (^Persistent_Allocator)(data)
    context.allocator = data.backing_allocator
    key := Key{loc.file_path, loc.line}
    allocation, ok := data.allocations[key]
    features := mem.query_features(context.allocator)
    switch mode {
        case .Alloc:
            if !ok {
                err: mem.Allocator_Error
                data.allocations[key], err = mem.make_aligned([]byte, size, alignment)
                return data.allocations[key], err
            } else if len(allocation) >= size {
                mem.zero_slice(allocation[:size])
                return allocation[:size], nil
            } else {
                delete(allocation)
                err: mem.Allocator_Error
                data.allocations[key], err = mem.make_aligned([]byte, size, alignment)
                return data.allocations[key], err
            }
        case .Free:
            if !ok do return nil, .Invalid_Pointer
            else {
                if .Free not_in features do return nil, .Mode_Not_Implemented
                delete(allocation)
                delete_key(&data.allocations, key)
                return nil, nil
            }
        case .Free_All:
            if .Free_All not_in features do return nil, .Mode_Not_Implemented
            clear(&data.allocations)
            err := free_all()
            return nil, err
        case .Resize:
            if !ok do return nil, .Invalid_Pointer
            else if raw_data(allocation) != old_memory do return nil, .Invalid_Pointer
            else if len(allocation) >= size {
                return allocation[:size], nil
            } else {
                if .Resize not_in features do return nil, .Mode_Not_Implemented
                err: mem.Allocator_Error
                data.allocations[key], err = context.allocator.procedure(context.allocator.data, .Resize, size, alignment, old_memory, old_size, loc)
                return data.allocations[key], err
            }
        case .Query_Features:
            set := (^mem.Allocator_Mode_Set)(old_memory)
            set^ = features
            return nil, nil
        case .Query_Info:
            if .Query_Info not_in features do return nil, .Mode_Not_Implemented
            info := (^mem.Allocator_Query_Info)(old_memory)
            info^ = mem.query_info(info, context.allocator)
            return nil, nil
        case .Alloc_Non_Zeroed:
            if !ok {
                if .Alloc_Non_Zeroed not_in features do return nil, .Mode_Not_Implemented
                err: mem.Allocator_Error
                data.allocations[key], err = context.allocator.procedure(context.allocator.data, .Alloc_Non_Zeroed, size, alignment, old_memory, old_size, loc)
                return data.allocations[key], err
            } else if len(allocation) >= size {
                return allocation[:size], nil
            } else {
                if .Alloc_Non_Zeroed not_in features do return nil, .Mode_Not_Implemented
                delete(allocation)
                err: mem.Allocator_Error
                data.allocations[key], err = context.allocator.procedure(context.allocator.data, .Alloc_Non_Zeroed, size, alignment, old_memory, old_size, loc)
                return data.allocations[key], err
            }
    }
    return nil, nil
}