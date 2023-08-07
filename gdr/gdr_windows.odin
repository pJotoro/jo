// +build windows
package gdr

import vk "vendor:vulkan"
import win32 "core:sys/windows"
import "../app"

VK_library_name :: "vulkan-1.dll"
VK_KHR_platform_surface :: "VK_KHR_win32_surface"

@(private)
create_surface :: proc() -> vk.Result {
	surface_info := vk.Win32SurfaceCreateInfoKHR{
		sType = .WIN32_SURFACE_CREATE_INFO_KHR,
		hinstance = win32.HANDLE(win32.GetModuleHandleW(nil)),
		hwnd = win32.HWND(app.window()),
	}
	return vk.CreateWin32SurfaceKHR(ctx.instance, &surface_info, nil, &ctx.surface)
}