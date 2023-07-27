package ngl

import "core:os"
import "core:runtime"

read_entire_file_aligned_from_filename :: proc(name: string, alignment: int, allocator := context.allocator, loc := #caller_location) -> (data: []byte, success: bool) {
	context.allocator = allocator

	fd, err := os.open(name, os.O_RDONLY, 0)
	if err != 0 {
		return nil, false
	}
	defer os.close(fd)

	return read_entire_file_aligned_from_handle(fd, alignment, allocator, loc)
}

read_entire_file_aligned_from_handle :: proc(fd: os.Handle, alignment: int, allocator := context.allocator, loc := #caller_location) -> (data: []byte, success: bool) {
	context.allocator = allocator

	length: i64
	err: os.Errno
	if length, err = os.file_size(fd); err != 0 {
	    return nil, false
	}

	if length <= 0 {
		return nil, true
	}

	data = runtime.make_aligned([]byte, int(length), alignment, allocator, loc)
	if data == nil {
	    return nil, false
	}

	bytes_read, read_err := os.read_full(fd, data)
	if read_err != os.ERROR_NONE {
		delete(data)
		return nil, false
	}
	return data[:bytes_read], true
}

// TODO(pJotoro): Convince gingerBill to put this in core:os.
read_entire_file_aligned :: proc {
	read_entire_file_aligned_from_filename,
	read_entire_file_aligned_from_handle,
}