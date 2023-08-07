//+private
package gdr

import vk "vendor:vulkan"
import "core:slice"

@(private="file")
Vulkan_Struct_Start :: struct {
	type: vk.StructureType,
	next: rawptr,
}

Next_Chain_Entry :: struct {
	extension_name: cstring,
	struct_address: rawptr, // Vulkan_Struct_Start
}

set_next_chain :: proc(extensions: []cstring, start: rawptr, entries: ..Next_Chain_Entry) {
	start := (^Vulkan_Struct_Start)(start)
	for entry in entries {
		if slice.contains(extensions, entry.extension_name) {
			start.next = entry.struct_address
			start = (^Vulkan_Struct_Start)(entry.struct_address)
		}
	}
}