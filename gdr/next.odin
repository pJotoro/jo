// +private
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

set_next_chain1 :: proc(extensions: []cstring, start: rawptr, entries: ..Next_Chain_Entry) {
	start := (^Vulkan_Struct_Start)(start)
	for entry in entries {
		if slice.contains(extensions, entry.extension_name) {
			start.next = entry.struct_address
			start = (^Vulkan_Struct_Start)(entry.struct_address)
		}
	}
}

set_next_chain2 :: proc(extensions1: []cstring, extensions2: []cstring, start: rawptr, entries: ..Next_Chain_Entry) {
	start := (^Vulkan_Struct_Start)(start)
	for entry in entries {
		if slice.contains(extensions1, entry.extension_name) || slice.contains(extensions2, entry.extension_name) {
			start.next = entry.struct_address
			start = (^Vulkan_Struct_Start)(entry.struct_address)
		}
	}
	start.next = nil
}

set_next_chain :: proc{set_next_chain1, set_next_chain2}