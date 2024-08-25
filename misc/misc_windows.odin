package misc

import win32 "core:sys/windows"
import "base:runtime"
import "core:strings"

get_last_error_message :: proc() -> (string, runtime.Allocator_Error) #optional_allocator_error {
    error := win32.GetLastError()
    buf: [512]u16 = ---
    win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
    res, err := win32.wstring_to_utf8(raw_data(buf[:]), -1)
    return strings.trim_suffix(res, "\n"), err
}

get_hresult_message :: proc(hr: win32.HRESULT) -> (string, runtime.Allocator_Error) #optional_allocator_error {
    buf: [512]u16 = ---
    win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, u32(hr), 0, raw_data(buf[:]), win32.DWORD(len(buf)), nil)
    res, err := win32.wstring_to_utf8(raw_data(buf[:]), -1)
    return strings.trim_suffix(res, "\n"), err
}