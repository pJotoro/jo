package app

import win32 "core:sys/windows"

// A native OS event.
Event :: struct {
    message: win32.UINT, 
    w_param: win32.WPARAM, 
    l_param: win32.LPARAM,
    result: win32.LRESULT,
}