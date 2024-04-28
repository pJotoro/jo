package misc

import win32 "core:sys/windows"
import "base:runtime"

get_last_error_message :: proc() -> (string, runtime.Allocator_Error) #optional_allocator_error {
    error := win32.GetLastError()
    buf: [1024]u16 = ---
    win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
    return win32.wstring_to_utf8(raw_data(buf[:]), -1)
}

get_hresult_message :: proc(hr: win32.HRESULT) -> (string, runtime.Allocator_Error) #optional_allocator_error {
    buf: [1024]u16 = ---
    win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, u32(hr), 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
    return win32.wstring_to_utf8(raw_data(buf[:]), -1)
}