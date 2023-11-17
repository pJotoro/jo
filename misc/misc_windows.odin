// +build windows
package misc

import win32 "core:sys/windows"
import "core:runtime"

panic :: proc(loc := #caller_location) {
    when !ODIN_DISABLE_ASSERT {
        error := win32.GetLastError()
        buf: [1024]u16 = ---
        win32.FormatMessageW(win32.FORMAT_MESSAGE_FROM_SYSTEM, nil, error, 0, raw_data(buf[:]), size_of(buf), nil)
        message, _ := win32.wstring_to_utf8(raw_data(buf[:]), len(buf))
        runtime.panic(message, loc)
    }
}