package vkma

import vk "vendor:vulkan"
import "core:mem"
import "core:slice"

Unallocated_Buffer :: struct {
	buffer: vk.Buffer,
	memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags,
}

Unallocated_Image :: struct {
	image: vk.Image,
	memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags,
}

Allocator :: struct {
	device: vk.Device,

	_memory_properties: vk.PhysicalDeviceMemoryProperties,
	memory_types: []vk.MemoryType,
	memory_heaps: []vk.MemoryHeap,

	buffer_allocations: map[vk.Buffer]vk.DeviceMemory,
	image_allocations: map[vk.Image]vk.DeviceMemory,
	unallocated_buffers: [dynamic]Unallocated_Buffer,
	unallocated_images: [dynamic]Unallocated_Image,

	host_allocator: mem.Allocator,
}

create_allocator :: proc(physical_device: vk.PhysicalDevice, device: vk.Device, host_allocator := context.allocator) -> (allocator: Allocator) {
	allocator.host_allocator = host_allocator
	context.allocator = host_allocator

	allocator.device = device

	vk.GetPhysicalDeviceMemoryProperties(physical_device, &allocator._memory_properties)
	allocator.memory_types = make([]vk.MemoryType, allocator._memory_properties.memoryTypeCount)
	copy(allocator.memory_types, allocator._memory_properties.memoryTypes[:len(allocator.memory_types)])
	allocator.memory_heaps = make([]vk.MemoryHeap, allocator._memory_properties.memoryHeapCount)
	copy(allocator.memory_heaps, allocator._memory_properties.memoryHeaps[:len(allocator.memory_heaps)])

	allocator.buffer_allocations = make(map[vk.Buffer]vk.DeviceMemory, 512)
	allocator.image_allocations = make(map[vk.Image]vk.DeviceMemory, 512)
	allocator.unallocated_buffers = make([dynamic]Unallocated_Buffer, 0, 128)
	allocator.unallocated_images = make([dynamic]Unallocated_Image, 0, 128)

	return
}

create_buffer :: proc(using allocator: ^Allocator, size: vk.DeviceSize, usage: vk.BufferUsageFlags, memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags) -> (buffer: vk.Buffer, result: vk.Result) {
	context.allocator = allocator.host_allocator

	info := vk.BufferCreateInfo{
		sType = .BUFFER_CREATE_INFO,
		size = size,
		usage = usage,
	}
	result = vk.CreateBuffer(device, &info, nil, &buffer)
	
	append(&unallocated_buffers, Unallocated_Buffer{buffer, memory_properties_include, memory_properties_exclude})
	return
}

create_image :: proc(using allocator: ^Allocator, format: vk.Format, width, height, depth, mip_levels, array_layers: u32, samples: vk.SampleCountFlags, usage: vk.ImageUsageFlags, initial_layout: vk.ImageLayout, memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags) -> (image: vk.Image, result: vk.Result) {
	context.allocator = allocator.host_allocator

	image_type: vk.ImageType = .D1
	height := height > 1 ? height : 1
	depth := depth > 1 ? depth : 1
	if height != 1 do image_type = .D2
	if depth != 1 do image_type = .D3
	info := vk.ImageCreateInfo{
		sType = .IMAGE_CREATE_INFO,
		imageType = image_type,
		format = format,
		extent = {width, height, 1},
		mipLevels = mip_levels,
		arrayLayers = array_layers,
		samples = samples,
		tiling = .OPTIMAL,
		usage = usage,
		initialLayout = initial_layout,
	}
	result = vk.CreateImage(device, &info, nil, &image)
	append(&unallocated_images, Unallocated_Image{image, memory_properties_include, memory_properties_exclude})
	return
}

alloc :: proc(using allocator: ^Allocator) -> vk.Result {
	context.allocator = allocator.host_allocator

	if len(unallocated_buffers) == 0 && len(unallocated_images) == 0 do return .SUCCESS

	bind_buffer_memory_infos := make([dynamic]vk.BindBufferMemoryInfo, 0, len(unallocated_buffers), context.temp_allocator)
	bind_image_memory_infos := make([dynamic]vk.BindImageMemoryInfo, 0, len(unallocated_images), context.temp_allocator)

	buffer_memory_requirements := make([dynamic]vk.MemoryRequirements2, len(unallocated_buffers), context.temp_allocator)
	for buffer_index := 0; buffer_index < len(unallocated_buffers); buffer_index += 1 {
		buffer_dedicated_memory_requirements := vk.MemoryDedicatedRequirements{
			sType = .MEMORY_DEDICATED_REQUIREMENTS,
		}
		buffer_memory_requirements[buffer_index].sType = .MEMORY_REQUIREMENTS_2
		buffer_memory_requirements[buffer_index].pNext = &buffer_dedicated_memory_requirements
		info := vk.BufferMemoryRequirementsInfo2{
			sType = .BUFFER_MEMORY_REQUIREMENTS_INFO_2,
			buffer = unallocated_buffers[buffer_index].buffer,
		}
		vk.GetBufferMemoryRequirements2(device, &info, &buffer_memory_requirements[buffer_index])

		if buffer_dedicated_memory_requirements.prefersDedicatedAllocation || buffer_dedicated_memory_requirements.requiresDedicatedAllocation {
			memory_dedicated_allocate_info := vk.MemoryDedicatedAllocateInfo{
				sType = .MEMORY_DEDICATED_ALLOCATE_INFO,
				buffer = unallocated_buffers[buffer_index].buffer,
			}
			memory_allocate_info := vk.MemoryAllocateInfo{
				sType = .MEMORY_ALLOCATE_INFO,
				pNext = &memory_dedicated_allocate_info,
				allocationSize = buffer_memory_requirements[buffer_index].memoryRequirements.size,
				memoryTypeIndex = max(u32),
			}
			for memory_type, memory_type_index in memory_types {
				memory_type_bit := u32(1 << u32(memory_type_index))
				memory_type_bits := buffer_memory_requirements[buffer_index].memoryRequirements.memoryTypeBits
				memory_properties_include := unallocated_buffers[buffer_index].memory_properties_include
				memory_properties_exclude := unallocated_buffers[buffer_index].memory_properties_exclude
				memory_properties := memory_type.propertyFlags

				if memory_type_bits & memory_type_bit != 0 && memory_properties_include <= memory_properties && !(memory_properties_exclude <= memory_properties) {
					memory_allocate_info.memoryTypeIndex = u32(memory_type_index)
					break
				}
			}
			assert(memory_allocate_info.memoryTypeIndex != max(u32))

			memory: vk.DeviceMemory = ---
			vk.AllocateMemory(device, &memory_allocate_info, nil, &memory) or_return
			buffer_allocations[unallocated_buffers[buffer_index].buffer] = memory

			bind_buffer_memory_info := vk.BindBufferMemoryInfo{
				sType = .BIND_BUFFER_MEMORY_INFO,
				buffer = unallocated_buffers[buffer_index].buffer,
				memory = memory,
			}
			append(&bind_buffer_memory_infos, bind_buffer_memory_info)

			ordered_remove(&unallocated_buffers, buffer_index)
			ordered_remove(&buffer_memory_requirements, buffer_index)
			buffer_index -= 1
		}
	}

	image_memory_requirements := make([dynamic]vk.MemoryRequirements2, len(unallocated_images), context.temp_allocator)
	for image_index := 0; image_index < len(unallocated_images); image_index += 1 {
		image_dedicated_memory_requirements := vk.MemoryDedicatedRequirements{
			sType = .MEMORY_DEDICATED_REQUIREMENTS,
		}
		image_memory_requirements[image_index].sType = .MEMORY_REQUIREMENTS_2
		image_memory_requirements[image_index].pNext = &image_dedicated_memory_requirements
		info := vk.ImageMemoryRequirementsInfo2{
			sType = .IMAGE_MEMORY_REQUIREMENTS_INFO_2,
			image = unallocated_images[image_index].image,
		}
		vk.GetImageMemoryRequirements2(device, &info, &image_memory_requirements[image_index])

		if image_dedicated_memory_requirements.prefersDedicatedAllocation || image_dedicated_memory_requirements.requiresDedicatedAllocation {
			memory_dedicated_allocate_info := vk.MemoryDedicatedAllocateInfo{
				sType = .MEMORY_DEDICATED_ALLOCATE_INFO,
				image = unallocated_images[image_index].image,
			}
			memory_allocate_info := vk.MemoryAllocateInfo{
				sType = .MEMORY_ALLOCATE_INFO,
				pNext = &memory_dedicated_allocate_info,
				allocationSize = image_memory_requirements[image_index].memoryRequirements.size,
				memoryTypeIndex = max(u32),
			}
			for memory_type, memory_type_index in memory_types {
				memory_type_bit := u32(1 << u32(memory_type_index))
				memory_type_bits := image_memory_requirements[image_index].memoryRequirements.memoryTypeBits
				memory_properties_include := unallocated_images[image_index].memory_properties_include
				memory_properties_exclude := unallocated_images[image_index].memory_properties_exclude
				memory_properties := memory_type.propertyFlags

				if memory_type_bits & memory_type_bit != 0 && memory_properties_include <= memory_properties && !(memory_properties_exclude <= memory_properties) {
					memory_allocate_info.memoryTypeIndex = u32(memory_type_index)
					break
				}
			}
			assert(memory_allocate_info.memoryTypeIndex != max(u32))

			memory: vk.DeviceMemory = ---
			vk.AllocateMemory(device, &memory_allocate_info, nil, &memory) or_return
			image_allocations[unallocated_images[image_index].image] = memory

			bind_image_memory_info := vk.BindImageMemoryInfo{
				sType = .BIND_IMAGE_MEMORY_INFO,
				image = unallocated_images[image_index].image,
				memory = memory,
			}
			append(&bind_image_memory_infos, bind_image_memory_info)

			ordered_remove(&unallocated_images, image_index)
			ordered_remove(&image_memory_requirements, image_index)
			image_index -= 1
		}
	}

	for len(unallocated_buffers) > 0 || len(unallocated_images) > 0 {
		assert(len(unallocated_buffers) == len(buffer_memory_requirements))
		assert(len(unallocated_images) == len(image_memory_requirements))

		max_count := 0
		max_index := -1
		for memory_type, memory_type_index in memory_types {
			count := 0
			memory_type_bit := u32(1 << u32(memory_type_index))

			for buffer_index := 0; buffer_index < len(unallocated_buffers); buffer_index += 1 {
				memory_type_bits := buffer_memory_requirements[buffer_index].memoryRequirements.memoryTypeBits
				memory_properties_include := unallocated_buffers[buffer_index].memory_properties_include
				memory_properties_exclude := unallocated_buffers[buffer_index].memory_properties_exclude
				memory_properties := memory_type.propertyFlags

				if memory_type_bits & memory_type_bit != 0 && memory_properties_include <= memory_properties && !(memory_properties_exclude <= memory_properties) {
					count += 1
				}
			}

			for image_index := 0; image_index < len(unallocated_images); image_index += 1 {
				memory_type_bits := image_memory_requirements[image_index].memoryRequirements.memoryTypeBits
				memory_properties_include := unallocated_images[image_index].memory_properties_include
				memory_properties_exclude := unallocated_images[image_index].memory_properties_exclude
				memory_properties := memory_type.propertyFlags

				if memory_type_bits & memory_type_bit != 0 && memory_properties_include <= memory_properties && !(memory_properties_exclude <= memory_properties) {
					count += 1
				}
			}

			if count > max_count {
				max_count = count
				max_index = memory_type_index
			}
		}

		memory_type_index := max_index
		memory_type := memory_types[memory_type_index]
		memory_type_bit := u32(1 << u32(memory_type_index))

		memory_offset := vk.DeviceSize(0)

		bind_buffer_memory_info_start_index := len(bind_buffer_memory_infos)
		bind_image_memory_info_start_index := len(bind_image_memory_infos)

		for buffer_index := 0; buffer_index < len(unallocated_buffers); buffer_index += 1 {
			memory_type_bits := buffer_memory_requirements[buffer_index].memoryRequirements.memoryTypeBits
			memory_properties_include := unallocated_buffers[buffer_index].memory_properties_include
			memory_properties_exclude := unallocated_buffers[buffer_index].memory_properties_exclude

			if memory_type_bits & memory_type_bit != 0 && memory_properties_include <= memory_type.propertyFlags && !(memory_properties_exclude <= memory_type.propertyFlags) {
				memory_offset = align_forward_device_size(memory_offset, buffer_memory_requirements[buffer_index].memoryRequirements.alignment)

				bind_buffer_memory_info := vk.BindBufferMemoryInfo{
					sType = .BIND_BUFFER_MEMORY_INFO,
					buffer = unallocated_buffers[buffer_index].buffer,
					memoryOffset = memory_offset,
				}
				append(&bind_buffer_memory_infos, bind_buffer_memory_info)

				memory_offset += buffer_memory_requirements[buffer_index].memoryRequirements.size

				ordered_remove(&unallocated_buffers, buffer_index)
				ordered_remove(&buffer_memory_requirements, buffer_index)
				buffer_index -= 1
			}
		}

		for image_index := 0; image_index < len(unallocated_images); image_index += 1 {
			memory_type_bits := image_memory_requirements[image_index].memoryRequirements.memoryTypeBits
			memory_properties_include := unallocated_images[image_index].memory_properties_include
			memory_properties_exclude := unallocated_images[image_index].memory_properties_exclude

			if memory_type_bits & memory_type_bit != 0 && memory_properties_include <= memory_type.propertyFlags && !(memory_properties_exclude <= memory_type.propertyFlags) {
				memory_offset = align_forward_device_size(memory_offset, image_memory_requirements[image_index].memoryRequirements.alignment)

				bind_image_memory_info := vk.BindImageMemoryInfo{
					sType = .BIND_IMAGE_MEMORY_INFO,
					image = unallocated_images[image_index].image,
					memoryOffset = memory_offset,
				}
				append(&bind_image_memory_infos, bind_image_memory_info)

				memory_offset += image_memory_requirements[image_index].memoryRequirements.size

				ordered_remove(&unallocated_images, image_index)
				ordered_remove(&image_memory_requirements, image_index)
				image_index -= 1
			}
		}

		memory_allocate_info := vk.MemoryAllocateInfo{
			sType = .MEMORY_ALLOCATE_INFO,
			memoryTypeIndex = u32(memory_type_index),
			allocationSize = memory_offset,
		}
		memory: vk.DeviceMemory = ---
		vk.AllocateMemory(device, &memory_allocate_info, nil, &memory) or_return

		if bind_buffer_memory_info_start_index != len(bind_buffer_memory_infos) {
			for &b in bind_buffer_memory_infos[bind_buffer_memory_info_start_index:] {
				b.memory = memory
				buffer_allocations[b.buffer] = memory
			}
		}
		if bind_image_memory_info_start_index != len(bind_image_memory_infos) {
			for &b in bind_image_memory_infos[bind_image_memory_info_start_index:] {
				b.memory = memory
				image_allocations[b.image] = memory
			}
		}
	}

	assert(len(unallocated_buffers) == len(buffer_memory_requirements))
	assert(len(unallocated_images) == len(image_memory_requirements))

	if len(bind_buffer_memory_infos) > 0 {
		vk.BindBufferMemory2(device, u32(len(bind_buffer_memory_infos)), raw_data(bind_buffer_memory_infos)) or_return
	}
	if len(bind_image_memory_infos) > 0 {
		vk.BindImageMemory2(device, u32(len(bind_image_memory_infos)), raw_data(bind_image_memory_infos)) or_return
	}

	return .SUCCESS
}

free_buffer :: proc(using allocator: ^Allocator, buffer: vk.Buffer) -> (ok: bool) {
	memory: vk.DeviceMemory = ---
	memory, ok = buffer_allocations[buffer]
	if !ok do return
	delete_key(&buffer_allocations, buffer)

	vk.DestroyBuffer(device, buffer, nil)

	for key, value in buffer_allocations {
		if value == memory do return
	}
	for key, value in image_allocations {
		if value == memory do return
	}
	vk.FreeMemory(device, memory, nil)

	return
}

free_image :: proc(using allocator: ^Allocator, image: vk.Image) -> (ok: bool) {
	memory: vk.DeviceMemory = ---
	memory, ok = image_allocations[image]
	if !ok do return
	delete_key(&image_allocations, image)

	vk.DestroyImage(device, image, nil)

	for key, value in buffer_allocations {
		if value == memory do return
	}
	for key, value in image_allocations {
		if value == memory do return
	}
	vk.FreeMemory(device, memory, nil)

	return
}

free :: proc{free_buffer, free_image}

is_power_of_two_device_size :: #force_inline proc(x: vk.DeviceSize) -> bool {
	if x <= 0 {
		return false
	}
	return (x & (x-1)) == 0
}

align_forward_device_size :: #force_inline proc(ptr, align: vk.DeviceSize) -> vk.DeviceSize {
	assert(is_power_of_two_device_size(align))

	p := ptr
	modulo := p & (align-1)
	if modulo != 0 {
		p += align - modulo
	}
	return p
}

get_memory_buffer :: proc "contextless" (using allocator: ^Allocator, buffer: vk.Buffer) -> (memory: vk.DeviceMemory, ok: bool) {
	memory, ok = buffer_allocations[buffer]
	return
}

get_memory_image :: proc "contextless" (using allocator: ^Allocator, image: vk.Image) -> (memory: vk.DeviceMemory, ok: bool) {
	memory, ok = image_allocations[image]
	return
}

get_memory :: proc{get_memory_buffer, get_memory_image}

map_memory_buffer :: proc(using allocator: ^Allocator, buffer: vk.Buffer, offset, size: vk.DeviceSize, flags: vk.MemoryMapFlags, loc := #caller_location) -> (data: []byte, result: vk.Result) {
	memory, ok := get_memory(allocator, buffer)
	assert(ok, "Failed to get buffer memory", loc)
	raw := mem.Raw_Slice{len = int(size)}
	result = vk.MapMemory(device, memory, offset, size, flags, &raw.data)
	data = transmute([]byte)raw
	return
}

map_memory_image :: proc(using allocator: ^Allocator, image: vk.Image, offset, size: vk.DeviceSize, flags: vk.MemoryMapFlags, loc := #caller_location) -> (data: []byte, result: vk.Result) {
	memory, ok := get_memory(allocator, image)
	assert(ok, "Failed to get image memory", loc)
	raw := mem.Raw_Slice{len = int(size)}
	result = vk.MapMemory(device, memory, offset, size, flags, &raw.data)
	data = transmute([]byte)raw
	return
}

map_memory :: proc{map_memory_buffer, map_memory_image}

unmap_memory_buffer :: proc(using allocator: ^Allocator, buffer: vk.Buffer, loc := #caller_location) {
	memory, ok := get_memory(allocator, buffer)
	assert(ok, "Failed to get buffer memory", loc)
	vk.UnmapMemory(device, memory)
}

unmap_memory_image :: proc(using allocator: ^Allocator, image: vk.Image, loc := #caller_location) {
	memory, ok := get_memory(allocator, image)
	assert(ok, "Failed to get image memory", loc)
	vk.UnmapMemory(device, memory)
}

unmap_memory :: proc{unmap_memory_buffer, unmap_memory_image}