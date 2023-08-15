// +private
// +build windows
package gdr

import vk "vendor:vulkan"
import win32 "core:sys/windows"
import "../app"

VK_library_name :: "vulkan-1.dll"
VK_KHR_platform_surface :: "VK_KHR_win32_surface"

create_surface :: proc() -> vk.Result {
	surface_info := vk.Win32SurfaceCreateInfoKHR{
		sType = .WIN32_SURFACE_CREATE_INFO_KHR,
		hinstance = win32.HANDLE(win32.GetModuleHandleW(nil)),
		hwnd = win32.HWND(app.window()),
	}
	return vk.CreateWin32SurfaceKHR(ctx.instance, &surface_info, nil, &ctx.surface)
}

platform_exclusive_fullscreen_info :: proc "contextless" () -> vk.SurfaceFullScreenExclusiveWin32InfoEXT {
	return vk.SurfaceFullScreenExclusiveWin32InfoEXT{
		sType = .SURFACE_FULL_SCREEN_EXCLUSIVE_WIN32_INFO_EXT,
		hmonitor = win32.MonitorFromWindow(win32.HWND(app.window()), .MONITOR_DEFAULTTONEAREST),
	}
}

foreign import kernel32 "system:Kernel32.lib"

@(default_calling_convention="stdcall")
foreign kernel32 {
	IsDebuggerPresent :: proc() -> win32.BOOL ---
}

debugger_present :: proc "contextless" () -> bool {
	return bool(IsDebuggerPresent())
}

debug_print_string :: proc(s: string) {
	string16 := win32.utf8_to_wstring(s)
	win32.OutputDebugStringW(string16)
}