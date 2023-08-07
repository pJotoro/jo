package gdr

import vk "vendor:vulkan"
import "core:dynlib"
import "core:thread"
import "../app"
import "core:strings"
import "core:sync"

@(private)
Command_Pool :: struct {
	h: vk.CommandPool,
	primary_command_buffers: [dynamic]vk.CommandBuffer,
	total_primary_command_buffers: int,
	secondary_command_buffers: [dynamic]vk.CommandBuffer,
	total_secondary_command_buffers: int,
}

@(private)
Queue_Family :: struct {
	queues: [dynamic]vk.Queue,
	command_pools: [dynamic]Command_Pool,
	total_command_pools: int,
	lock: sync.Mutex,
}

@(private)
Context :: struct {
	instance: vk.Instance,
	surface: vk.SurfaceKHR,
	device: vk.Device,
	swapchain: vk.SwapchainKHR,
	extent: vk.Extent2D,
	swapchain_image_index: int,
	fence: vk.Fence,

	queue_family_properties: []vk.QueueFamilyProperties,
	swapchain_images: []vk.Image,
	swapchain_image_views: []vk.ImageView,
	queue_families: []Queue_Family,

	primary_graphics_queue_family_index: int,
	primary_present_queue_family_index: int,
}
@(private)
ctx: Context

@(private)
primary_graphics_command_buffer :: #force_inline proc "contextless" () -> vk.CommandBuffer {
	return ctx.queue_families[ctx.primary_graphics_queue_family_index].command_pools[0].primary_command_buffers[0]
}

@(private)
primary_graphics_queue :: #force_inline proc "contextless" () -> vk.Queue {
	return ctx.queue_families[ctx.primary_graphics_queue_family_index].queues[0]
}

@(private)
primary_present_queue :: #force_inline proc "contextless" () -> vk.Queue {
	return ctx.queue_families[ctx.primary_present_queue_family_index].queues[0]
}

init :: proc() -> bool {
	library: dynlib.Library = ---
	{
		ok: bool = ---
		library, ok = dynlib.load_library(VK_library_name)
		if !ok do return false
		get_instance_proc_addr := dynlib.symbol_address(library, "vkGetInstanceProcAddr")
		vk.load_proc_addresses(get_instance_proc_addr)
	}

	{
		version: u32 = ---
		vk.EnumerateInstanceVersion(&version)
		if version < vk.API_VERSION_1_3 {
			dynlib.unload_library(library)
			return false
		}
	}

	instance_extensions := []cstring{
		"VK_KHR_surface",
		VK_KHR_platform_surface,
	}
	
	{
		app_name := strings.clone_to_cstring(app.name(), context.temp_allocator)
		app_info := vk.ApplicationInfo{
			sType = .APPLICATION_INFO,
			pApplicationName = app_name,
			apiVersion = vk.API_VERSION_1_3,
		}
		when ODIN_DEBUG {
			layers := []cstring{
				"VK_LAYER_KHRONOS_validation",
			}
		}
		
		info := vk.InstanceCreateInfo{
			sType = .INSTANCE_CREATE_INFO,
			pApplicationInfo = &app_info,
			enabledExtensionCount = u32(len(instance_extensions)),
			ppEnabledExtensionNames = raw_data(instance_extensions),
		}
		when ODIN_DEBUG {
			info.enabledLayerCount = u32(len(layers))
			info.ppEnabledLayerNames = raw_data(layers)
		}
		if vk.CreateInstance(&info, nil, &ctx.instance) != .SUCCESS {
			dynlib.unload_library(library)
			return false
		}
		vk.load_proc_addresses(ctx.instance)
	}

	{
		if create_surface() != .SUCCESS {
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}

		ctx.primary_present_queue_family_index = -1
		for i in 0..<len(queue_family_properties) {
			supported: b32 = ---
			if vk.GetPhysicalDeviceSurfaceSupport(physical_device, u32(i), ctx.surface, &supported) != .SUCCESS {
				vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
				vk.DestroyInstance(ctx.instance, nil)
				dynlib.unload_library(library)
				return false
			}
			if supported {
				ctx.primary_present_queue_family_index = i
				break
			}
		}
		if ctx.primary_present_queue_family_index == -1 {
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}
	}

	device_extensions := [?]cstring{
		"VK_KHR_swapchain",
		"VK_EXT_extended_dynamic_state3",
		"VK_EXT_vertex_input_dynamic_state",
		"VK_EXT_descriptor_buffer",
	}

	physical_device: vk.PhysicalDevice = ---
	{
		physical_device_count: u32 = ---
		if vk.EnumeratePhysicalDevices(ctx.instance, &physical_device_count, nil) != .SUCCESS {
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}
		physical_devices := make([]vk.PhysicalDevice, physical_device_count, context.temp_allocator)
		if vk.EnumeratePhysicalDevices(ctx.instance, &physical_device_count, raw_data(physical_devices)) != .SUCCESS {
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}

		chosen_physical_device: Maybe(vk.PhysicalDevice)
		physical_device_loop: for physical_device in physical_devices {
			found: [len(device_extensions)]bool
			for instance_extension in instance_extensions {
				count: u32 = ---
				if vk.EnumerateDeviceExtensionProperties(physical_device, instance_extension, &count, nil) != .SUCCESS {
					vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
					vk.DestroyInstance(ctx.instance, nil)
					dynlib.unload_library(library)
					return false
				}
				properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
				if vk.EnumerateDeviceExtensionProperties(physical_device, instance_extension, &count, raw_data(properties)) != .SUCCESS {
					vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
					vk.DestroyInstance(ctx.instance, nil)
					dynlib.unload_library(library)
					return false
				}
				for &p in properties {
					for device_extension, found_index in device_extensions {
						if cstring(&p.extensionName[0]) == device_extension {
							found[found_index] = true
							break
						}
					}
				}
			}
			count: u32 = ---
			if vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, nil) != .SUCCESS {
				vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
				vk.DestroyInstance(ctx.instance, nil)
				dynlib.unload_library(library)
				return false
			}
			properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
			if vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, raw_data(properties)) != .SUCCESS {
				vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
				vk.DestroyInstance(ctx.instance, nil)
				dynlib.unload_library(library)
				return false
			}
			for &p in properties {
				for device_extension, found_index in device_extensions {
					if cstring(&p.extensionName[0]) == device_extension {
						found[found_index] = true
						break
					}
				}
			}
			for f in found {
				if !f {
					continue physical_device_loop
				}
			}
			chosen_physical_device = physical_device
			break physical_device_loop
		}
		ok: bool = ---
		physical_device, ok = chosen_physical_device.(vk.PhysicalDevice)
		if !ok {
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}
	}

	queue_family_properties: []vk.QueueFamilyProperties
	{
		count: u32 = ---
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, nil)
		queue_family_properties = make([]vk.QueueFamilyProperties, count)
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, raw_data(queue_family_properties))
	}

	{
		features_descriptor_buffer := vk.PhysicalDeviceDescriptorBufferFeaturesEXT{
			sType = .PHYSICAL_DEVICE_DESCRIPTOR_BUFFER_FEATURES_EXT,
		}
		features_vertex_input_dynamic_state := vk.PhysicalDeviceVertexInputDynamicStateFeaturesEXT{
			sType = .PHYSICAL_DEVICE_VERTEX_INPUT_DYNAMIC_STATE_FEATURES_EXT,
			pNext = &features_descriptor_buffer,
		}
		features_extended_dynamic_state_3 := vk.PhysicalDeviceExtendedDynamicState3FeaturesEXT{
			sType = .PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_3_FEATURES_EXT,
			pNext = &features_vertex_input_dynamic_state,
		}
		features_1_3 := vk.PhysicalDeviceVulkan13Features{
			sType = .PHYSICAL_DEVICE_VULKAN_1_3_FEATURES,
			pNext = &features_extended_dynamic_state_3,
		}
		features_1_2 := vk.PhysicalDeviceVulkan12Features{
			sType = .PHYSICAL_DEVICE_VULKAN_1_2_FEATURES,
			pNext = &features_1_3,
		}
		features_1_1 := vk.PhysicalDeviceVulkan11Features{
			sType = .PHYSICAL_DEVICE_VULKAN_1_1_FEATURES,
			pNext = &features_1_2,
		}
		features := vk.PhysicalDeviceFeatures2{
			sType = .PHYSICAL_DEVICE_FEATURES_2,
			pNext = &features_1_1,
		}
		vk.GetPhysicalDeviceFeatures2(physical_device, &features)

		device_queue_infos := make([]vk.DeviceQueueCreateInfo, len(queue_family_properties), context.temp_allocator)
		for &info, i in device_queue_infos {
			info.sType = .DEVICE_QUEUE_CREATE_INFO
			info.queueFamilyIndex = u32(i)
			info.queueCount = queue_family_properties[i].queueCount
			// TODO
			priorities := make([]f32, info.queueCount, context.temp_allocator)
			for &p in priorities do p = 1
			info.pQueuePriorities = raw_data(priorities)
		}

		info := vk.DeviceCreateInfo{
			sType = .DEVICE_CREATE_INFO,
			pNext = &features,
			queueCreateInfoCount = u32(len(device_queue_infos)),
			pQueueCreateInfos = raw_data(device_queue_infos),
			enabledExtensionCount = u32(len(device_extensions)),
			ppEnabledExtensionNames = &device_extensions[0],
		}
		if vk.CreateDevice(physical_device, &info, nil, &ctx.device) != .SUCCESS {
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}
		vk.load_proc_addresses(ctx.device)
	}

	swapchain_images: []vk.Image
	swapchain_image_views: []vk.ImageView
	{
		capabilities: vk.SurfaceCapabilitiesKHR = ---
		if vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, ctx.surface, &capabilities) != .SUCCESS {
			vk.DestroyDevice(ctx.device, nil)
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}

		queue_family_indices := make([dynamic]u32, 0, len(queue_family_properties), context.temp_allocator)
		for p, i in queue_family_properties {
			if .TRANSFER in p.queueFlags do append(&queue_family_indices, u32(i))
		}

		swapchain_info := vk.SwapchainCreateInfoKHR{
			sType = .SWAPCHAIN_CREATE_INFO_KHR,
			surface = ctx.surface,
			minImageCount = (capabilities.maxImageCount == 0 || capabilities.maxImageCount >= capabilities.minImageCount + 1) ? capabilities.minImageCount + 1 : capabilities.minImageCount,
			imageFormat = .B8G8R8A8_SRGB,
			imageColorSpace = .SRGB_NONLINEAR,
			presentMode = .FIFO,
			imageExtent = {width = capabilities.currentExtent.width, height = capabilities.currentExtent.height},
			imageUsage = {.COLOR_ATTACHMENT, .TRANSFER_SRC},
			queueFamilyIndexCount = u32(len(queue_family_indices)),
			pQueueFamilyIndices = &queue_family_indices[0],
			imageSharingMode = len(queue_family_indices) > 1 ? .CONCURRENT : .EXCLUSIVE,
			preTransform = capabilities.currentTransform,
			compositeAlpha = {.OPAQUE},
			clipped = true,
			imageArrayLayers = 1,
		}
		ctx.extent = swapchain_info.imageExtent
		if vk.CreateSwapchainKHR(ctx.device, &swapchain_info, nil, &ctx.swapchain) != .SUCCESS {
			vk.DestroyDevice(ctx.device, nil)
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}

		swapchain_image_count: u32 = ---
		if vk.GetSwapchainImagesKHR(ctx.device, ctx.swapchain, &swapchain_image_count, nil) != .SUCCESS {
			vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
			vk.DestroyDevice(ctx.device, nil)
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}
		swapchain_images = make([]vk.Image, swapchain_image_count)
		if vk.GetSwapchainImagesKHR(ctx.device, ctx.swapchain, &swapchain_image_count, raw_data(swapchain_images)) != .SUCCESS {
			vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
			vk.DestroyDevice(ctx.device, nil)
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}

		swapchain_image_views = make([]vk.ImageView, len(swapchain_images))
		for &s, i in swapchain_image_views {
			info := vk.ImageViewCreateInfo{
				sType = .IMAGE_VIEW_CREATE_INFO,
				image = swapchain_images[i],
				viewType = .D2,
				format = .B8G8R8A8_SRGB,
				components = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
				subresourceRange = {
					aspectMask = {.COLOR},
					levelCount = 1,
					layerCount = 1,
				},
			}
			if vk.CreateImageView(ctx.device, &info, nil, &s) != .SUCCESS {
				for j in 0..<i {
					vk.DestroyImageView(ctx.device, swapchain_image_views[j], nil)
				}
				vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
				vk.DestroyDevice(ctx.device, nil)
				vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
				vk.DestroyInstance(ctx.instance, nil)
				dynlib.unload_library(library)
				return false
			}
		}
	}

	queue_families: []Queue_Family
	{
		queue_families = make([]Queue_Family, len(queue_family_properties))
		for &queue_family, i in queue_families {
			queue_family.command_pools = make([dynamic]Command_Pool, 1)
			queue_family.total_command_pools = 1
			{
				info := vk.CommandPoolCreateInfo{
					sType = .COMMAND_POOL_CREATE_INFO,
					flags = {.TRANSIENT, .RESET_COMMAND_BUFFER},
					queueFamilyIndex = u32(i),
				}
				if vk.CreateCommandPool(ctx.device, &info, nil, &queue_family.command_pools[0].h) != .SUCCESS {
					for j in 0..<i {
						vk.DestroyCommandPool(ctx.device, queue_families[j].command_pools[0].h, nil)
					}
					for image_view in swapchain_image_views {
						vk.DestroyImageView(ctx.device, image_view, nil)
					}
					vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
					vk.DestroyDevice(ctx.device, nil)
					vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
					vk.DestroyInstance(ctx.instance, nil)
					dynlib.unload_library(library)
					return false
				}
			}
			queue_family.command_pools[0].primary_command_buffers = make([dynamic]vk.CommandBuffer, 1)
			queue_family.command_pools[0].total_primary_command_buffers = 1
			{
				info := vk.CommandBufferAllocateInfo{
					sType = .COMMAND_BUFFER_ALLOCATE_INFO,
					commandPool = queue_family.command_pools[0].h,
					level = .PRIMARY,
					commandBufferCount = 1,
				}
				if vk.AllocateCommandBuffers(ctx.device, &info, &queue_family.command_pools[0].primary_command_buffers[0]) != .SUCCESS {
					for j in 0..<i {
						vk.DestroyCommandPool(ctx.device, queue_families[j].command_pools[0].h, nil)
					}
					for image_view in swapchain_image_views {
						vk.DestroyImageView(ctx.device, image_view, nil)
					}
					vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
					vk.DestroyDevice(ctx.device, nil)
					vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
					vk.DestroyInstance(ctx.instance, nil)
					dynlib.unload_library(library)
					return false
				}
			}
			if .GRAPHICS in queue_family_properties[i].queueFlags {
				queue_family.command_pools[0].secondary_command_buffers = make([dynamic]vk.CommandBuffer, 1)
				queue_family.command_pools[0].total_secondary_command_buffers = 1
				info := vk.CommandBufferAllocateInfo{
					sType = .COMMAND_BUFFER_ALLOCATE_INFO,
					commandPool = queue_family.command_pools[0].h,
					level = .SECONDARY,
					commandBufferCount = 1,
				}
				if vk.AllocateCommandBuffers(ctx.device, &info, &queue_family.command_pools[0].secondary_command_buffers[0]) != .SUCCESS {
					for j in 0..<i {
						vk.DestroyCommandPool(ctx.device, queue_families[j].command_pools[0].h, nil)
					}
					for image_view in swapchain_image_views {
						vk.DestroyImageView(ctx.device, image_view, nil)
					}
					vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
					vk.DestroyDevice(ctx.device, nil)
					vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
					vk.DestroyInstance(ctx.instance, nil)
					dynlib.unload_library(library)
					return false
				}
			}
			queue_family.queues = make([dynamic]vk.Queue, queue_family_properties[i].queueCount)
			for &queue, j in queue_family.queues {
				vk.GetDeviceQueue(ctx.device, u32(i), u32(j), &queue)
			}
		}
	}

	{
		info := vk.FenceCreateInfo{
			sType = .FENCE_CREATE_INFO,
		}
		if vk.CreateFence(ctx.device, &info, nil, &ctx.fence) != .SUCCESS {
			for queue_family in queue_families {
				vk.DestroyCommandPool(ctx.device, queue_family.command_pools[0].h, nil)
			}
			for image_view in swapchain_image_views {
				vk.DestroyImageView(ctx.device, image_view, nil)
			}
			vk.DestroySwapchainKHR(ctx.device, ctx.swapchain, nil)
			vk.DestroyDevice(ctx.device, nil)
			vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
			vk.DestroyInstance(ctx.instance, nil)
			dynlib.unload_library(library)
			return false
		}
	}

	{
		for p, i in queue_family_properties {
			if .GRAPHICS in p.queueFlags {
				ctx.primary_graphics_queue_family_index = i
				break
			}
		}
	}

	ctx.queue_family_properties = make([]vk.QueueFamilyProperties, len(queue_family_properties))
	copy(ctx.queue_family_properties, queue_family_properties)
	ctx.swapchain_images = make([]vk.Image, len(swapchain_images))
	copy(ctx.swapchain_images, swapchain_images)
	ctx.swapchain_image_views = make([]vk.ImageView, len(swapchain_image_views))
	copy(ctx.swapchain_image_views, swapchain_image_views)
	ctx.queue_families = make([]Queue_Family, len(queue_families))
	copy(ctx.queue_families, queue_families)

	return true
}

begin :: proc(r, g, b, a: f32, timeout := max(u64)) {
	{
		i: u32 = ---
		vk.AcquireNextImageKHR(ctx.device, ctx.swapchain, timeout, 0, ctx.fence, &i)
		vk.WaitForFences(ctx.device, 1, &ctx.fence, true, timeout)
		vk.ResetFences(ctx.device, 1, &ctx.fence)
		ctx.swapchain_image_index = int(i)
	}

	command_buffer := primary_graphics_command_buffer()
	{
		info := vk.CommandBufferBeginInfo{
			sType = .COMMAND_BUFFER_BEGIN_INFO,
			flags = {.ONE_TIME_SUBMIT},
		}
		vk.BeginCommandBuffer(command_buffer, &info)
	}
	{
		color_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = ctx.swapchain_image_views[ctx.swapchain_image_index],
			imageLayout = .COLOR_ATTACHMENT_OPTIMAL,
			loadOp = .CLEAR,
			storeOp = .STORE,
			clearValue = {color = {float32 = {r, g, b, a}}},
		}

		/*
		depth_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
		}

		stencil_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
		}
		*/

		info := vk.RenderingInfo{
			sType = .RENDERING_INFO,
			flags = {.CONTENTS_SECONDARY_COMMAND_BUFFERS},
			renderArea = {extent = ctx.extent},
			layerCount = 1,
			colorAttachmentCount = 1,
			pColorAttachments = &color_attachment,
		}

		vk.CmdBeginRendering(command_buffer, &info)
	}
}

end :: proc(timeout := max(u64)) {
	command_buffer := primary_graphics_command_buffer()
	vk.CmdEndRendering(command_buffer)
	vk.EndCommandBuffer(command_buffer)
	queue := primary_graphics_queue()
	{
		command_buffer_info := vk.CommandBufferSubmitInfo{
			sType = .COMMAND_BUFFER_SUBMIT_INFO,
			commandBuffer = command_buffer,
		}
		info := vk.SubmitInfo2{
			sType = .SUBMIT_INFO,
			commandBufferInfoCount = 1,
			pCommandBufferInfos = &command_buffer_info,
		}
		vk.QueueSubmit2(queue, 1, &info, ctx.fence)
		vk.WaitForFences(ctx.device, 1, &ctx.fence, true, timeout)
		vk.ResetFences(ctx.device, 1, &ctx.fence)
	}

	
}