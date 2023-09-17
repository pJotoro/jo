package gdr

RENDER_DOC :: #config(GDR_RENDER_DOC, false)

import vk "vendor:vulkan"
import "../vkma"
import "core:dynlib"
import "../app"
import "core:strings"
import "core:log"
import "core:runtime"
import "core:slice"
import "core:fmt"
import "core:os"
import "core:mem"
import "core:reflect"

vertices := [?]f32{
	-0.5, -0.5, 0.0,
	0.5, -0.5, 0.0,
	0.0, 0.5, 0.0,
}

init :: proc() -> bool {
	using ctx

	result: vk.Result

	deletion_queue = make([dynamic]any, 0, 128)

	{
		ok: bool = ---
		library, ok = dynlib.load_library(VK_library_name)
		if !ok do return false
		append(&deletion_queue, library)
		get_instance_proc_addr := dynlib.symbol_address(library, "vkGetInstanceProcAddr")
		vk.load_proc_addresses(get_instance_proc_addr)
	}

	{
		version: u32 = ---
		vk.EnumerateInstanceVersion(&version)
		if version < vk.API_VERSION_1_3 do return delete_all()
	}

	instance_layers = make([dynamic]cstring, 0, 2)
	append(&deletion_queue, instance_layers)
	instance_extensions = make([dynamic]cstring, 0, 32)
	append(&deletion_queue, instance_extensions)
	{
		app_name := strings.clone_to_cstring(app.name(), context.temp_allocator)
		app_info := vk.ApplicationInfo{
			sType = .APPLICATION_INFO,
			pApplicationName = app_name,
			apiVersion = vk.API_VERSION_1_3,
		}

		when RENDER_DOC {
			append(&instance_layers, "VK_LAYER_RENDERDOC_Capture")
		}

		append(&instance_extensions, "VK_KHR_surface", VK_KHR_platform_surface)

		when ODIN_DEBUG {
			append(&instance_layers, "VK_LAYER_KHRONOS_validation")
			append(&instance_extensions, "VK_EXT_debug_utils", "VK_EXT_validation_features")

			enabled_validation_features := [?]vk.ValidationFeatureEnableEXT{
				.GPU_ASSISTED,
				.SYNCHRONIZATION_VALIDATION,
			}
			validation_features := vk.ValidationFeaturesEXT{
				sType = .VALIDATION_FEATURES_EXT,
				enabledValidationFeatureCount = u32(len(enabled_validation_features)),
				pEnabledValidationFeatures = raw_data(&enabled_validation_features),
			}

			log_proc_no_debugger :: proc(data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
				backing: [1024]byte
				buf := strings.builder_from_bytes(backing[:])
				log.do_level_header(options, level, &buf)
				fmt.printf("%s%s\n", strings.to_string(buf), text)
			}
			log_proc_debugger :: proc(data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
				backing: [1024]byte
				buf := strings.builder_from_bytes(backing[:])
				log.do_level_header(options, level, &buf)
				fmt.sbprintf(&buf, "%s%s\n", text)
				debug_print_string(strings.to_string(buf))
			}
			debug_logger := new(log.Logger)
			append(&deletion_queue, debug_logger)
			debug_logger^ = log.Logger{
				procedure = debugger_present() ? log_proc_debugger : log_proc_no_debugger,
				lowest_level = .Debug,
				options = {.Level, .Terminal_Color},
			}

			debug_callback :: proc "system" (message_severities: vk.DebugUtilsMessageSeverityFlagsEXT, message_types: vk.DebugUtilsMessageTypeFlagsEXT, callback_data: ^vk.DebugUtilsMessengerCallbackDataEXT, user_data: rawptr) -> b32 {
				context = runtime.default_context()
				context.logger = (^log.Logger)(user_data)^
				if .ERROR in message_severities do log.error(callback_data.pMessage)
				else if .WARNING in message_severities do log.warn(callback_data.pMessage)
				else if .INFO in message_severities || .VERBOSE in message_severities do log.info(callback_data.pMessage)
				return false
			}
			debug_info := vk.DebugUtilsMessengerCreateInfoEXT{
				sType = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
				pNext = &validation_features,
				messageSeverity = {.VERBOSE, .ERROR, .INFO, .WARNING},
				messageType = {.GENERAL, .PERFORMANCE, .VALIDATION},
				pfnUserCallback = debug_callback,
				pUserData = debug_logger,
			}
		}
		{
			count: u32 = ---
			result = vk.EnumerateInstanceExtensionProperties(nil, &count, nil)
			if result != .SUCCESS do return delete_all()
			instance_extension_properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
			result = vk.EnumerateInstanceExtensionProperties(nil, &count, raw_data(instance_extension_properties))
			if result != .SUCCESS do return delete_all()
			desired_instance_extensions := [?]cstring{
				//"VK_KHR_display",
				//"VK_KHR_display_swapchain",
				"VK_EXT_swapchain_colorspace",
				"VK_KHR_get_surface_capabilities2",
				"VK_EXT_surface_maintenance1",
			}
			find_extensions: for &p in instance_extension_properties {
				for instance_extension in desired_instance_extensions {
					if cstring(raw_data(&p.extensionName)) == instance_extension {
						append(&instance_extensions, instance_extension)
						continue find_extensions
					}
				}
			}
		}
		
		info := vk.InstanceCreateInfo{
			sType = .INSTANCE_CREATE_INFO,
			pApplicationInfo = &app_info,
			enabledLayerCount = u32(len(instance_layers)),
			ppEnabledLayerNames = len(instance_layers) == 0 ? nil : raw_data(instance_layers),
			enabledExtensionCount = u32(len(instance_extensions)),
			ppEnabledExtensionNames = raw_data(instance_extensions),
		}
		when ODIN_DEBUG {
			info.pNext = &debug_info
		}
		result = vk.CreateInstance(&info, nil, &instance)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, instance)
		vk.load_proc_addresses(instance)
	}

	{
		result = create_surface()
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, surface)
	}

	{
		physical_device_count: u32 = ---
		result = vk.EnumeratePhysicalDevices(instance, &physical_device_count, nil)
		if result != .SUCCESS do return delete_all()
		physical_devices := make([]vk.PhysicalDevice, physical_device_count, context.temp_allocator)
		result = vk.EnumeratePhysicalDevices(instance, &physical_device_count, raw_data(physical_devices))
		if result != .SUCCESS do return delete_all()

		// TODO
		physical_device = physical_devices[0]
	}

	desired_device_extensions := [?]cstring{
		"VK_EXT_extended_dynamic_state3", 
		"VK_EXT_vertex_input_dynamic_state", 
		"VK_EXT_descriptor_buffer",
		//"VK_EXT_full_screen_exclusive",
	}

	device_extensions = make([dynamic]cstring, 0, 128)
	append(&deletion_queue, device_extensions)

	append(&device_extensions, "VK_KHR_swapchain")
	{
		count: u32 = ---
		result = vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, nil)
		if result != .SUCCESS do return delete_all()
		extension_properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
		result = vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, raw_data(extension_properties))
		for &e in extension_properties {
			when RENDER_DOC {
				if slice.contains(desired_device_extensions[:], cstring(raw_data(&e.extensionName))) && !slice.contains(render_doc_unsupported_extensions[:], cstring(raw_data(&e.extensionName))) {
					append(&device_extensions, cstring(raw_data(&e.extensionName)))
				}
			} else {
				if slice.contains(desired_device_extensions[:], cstring(raw_data(&e.extensionName))) {
					append(&device_extensions, cstring(raw_data(&e.extensionName)))
				}
			}
		}
	}

	surface_capabilities_fullscreen_exclusive.sType = .SURFACE_CAPABILITIES_FULL_SCREEN_EXCLUSIVE_EXT

	present_modes: []vk.PresentModeKHR
	if slice.contains(device_extensions[:], "VK_EXT_full_screen_exclusive") && app.fullscreen() {
		platform_fullscreen_info := platform_exclusive_fullscreen_info()
		fullscreen_info := vk.SurfaceFullScreenExclusiveInfoEXT{
			sType = .SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT,
			pNext = &platform_fullscreen_info,
			fullScreenExclusive = .APPLICATION_CONTROLLED,
		}
		info := vk.PhysicalDeviceSurfaceInfo2KHR{
			sType = .PHYSICAL_DEVICE_SURFACE_INFO_2_KHR,
			pNext = &fullscreen_info,
			surface = surface,
		}
		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfacePresentModes2EXT(physical_device, &info, &count, nil)
		if result != .SUCCESS do return delete_all()
		present_modes = make([]vk.PresentModeKHR, count, context.temp_allocator)
		result = vk.GetPhysicalDeviceSurfacePresentModes2EXT(physical_device, &info, &count, raw_data(present_modes))
		if result != .SUCCESS do return delete_all()
	} else {
		//set_fullscreen = true // NOTE(pJotoro): In this case, the application is not fullscreen, so it should never actually try to set itself to fullscreen.

		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, nil)
		if result != .SUCCESS do return delete_all()
		present_modes = make([]vk.PresentModeKHR, count, context.temp_allocator)
		result = vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, raw_data(present_modes))
		if result != .SUCCESS do return delete_all()
	}

	surface_formats_1: []vk.SurfaceFormatKHR
	surface_formats_2: []vk.SurfaceFormat2KHR
	if slice.contains(instance_extensions[:], "VK_KHR_get_surface_capabilities2") {
		platform_fullscreen_info := platform_exclusive_fullscreen_info()
		fullscreen_info := vk.SurfaceFullScreenExclusiveInfoEXT{
			sType = .SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT,
			fullScreenExclusive = .ALLOWED,
		}
		
		info := vk.PhysicalDeviceSurfaceInfo2KHR{
			sType = .PHYSICAL_DEVICE_SURFACE_INFO_2_KHR,
			surface = surface,
		}
		surface_capabilities_2 := vk.SurfaceCapabilities2KHR{
			sType = .SURFACE_CAPABILITIES_2_KHR
		}
		surface_present_mode := vk.SurfacePresentModeEXT{
			sType = .SURFACE_PRESENT_MODE_EXT,
			presentMode = slice.contains(present_modes, vk.PresentModeKHR.MAILBOX) ? .MAILBOX : .FIFO,
		}

		// NOTE(pJotoro): surface_present_mode MUST be at the end of the chain because otherwise, the chain for one of the two will be incorrect.
		if app.fullscreen() {
			set_next_chain(instance_extensions[:], device_extensions[:], &info, 
				Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &fullscreen_info}, 
				Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &platform_fullscreen_info}, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
			set_next_chain(instance_extensions[:], device_extensions[:], &surface_capabilities_2, 
				Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &surface_capabilities_fullscreen_exclusive}, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
		} else {
			set_next_chain(instance_extensions[:], device_extensions[:], &info, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
			set_next_chain(instance_extensions[:], device_extensions[:], &surface_capabilities_2, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
		}

		result = vk.GetPhysicalDeviceSurfaceCapabilities2KHR(physical_device, &info, &surface_capabilities_2)
		if result != .SUCCESS do return delete_all()

		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfaceFormats2KHR(physical_device, &info, &count, nil)
		if result != .SUCCESS do return delete_all()
		surface_formats_2 = make([]vk.SurfaceFormat2KHR, count, context.temp_allocator)
		for &f in surface_formats_2 do f.sType = .SURFACE_FORMAT_2_KHR
		result = vk.GetPhysicalDeviceSurfaceFormats2KHR(physical_device, &info, &count, raw_data(surface_formats_2))
		if result != .SUCCESS do return delete_all()

		surface_capabilities = surface_capabilities_2.surfaceCapabilities
	} else {
		result = vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &surface_capabilities)
		if result != .SUCCESS do return delete_all()
		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, nil)
		if result != .SUCCESS do return delete_all()
		surface_formats_1 = make([]vk.SurfaceFormatKHR, count, context.temp_allocator)
		result = vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, raw_data(surface_formats_1))
		if result != .SUCCESS do return delete_all()
	}

	{
		count: u32 = ---
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, nil)
		queue_family_properties = make([]vk.QueueFamilyProperties, count)
		append(&deletion_queue, queue_family_properties)
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, raw_data(queue_family_properties))
	}

	present_queue_family_indices := make([dynamic]int, 0, len(queue_family_properties), context.temp_allocator)
	{
		for i in 0..<len(queue_family_properties) {
			supported: b32 = ---
			result = vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, u32(i), surface, &supported)
			if result != .SUCCESS do return delete_all()
			if supported do append(&present_queue_family_indices, i)
		}
		if len(present_queue_family_indices) == 0 do return delete_all()
	}

	{
		features.sType = .PHYSICAL_DEVICE_FEATURES_2
		features.pNext = &features_1_1
		features_1_1.sType = .PHYSICAL_DEVICE_VULKAN_1_1_FEATURES
		features_1_1.pNext = &features_1_2
		features_1_2.sType = .PHYSICAL_DEVICE_VULKAN_1_2_FEATURES
		features_1_2.pNext= &features_1_3
		features_1_3.sType = .PHYSICAL_DEVICE_VULKAN_1_3_FEATURES
		features_1_3.pNext = &features_extended_dynamic_state_2
		features_extended_dynamic_state_2.sType = .PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_2_FEATURES_EXT

		features_extended_dynamic_state_3.sType = .PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_3_FEATURES_EXT
		features_vertex_input_dynamic_state.sType = .PHYSICAL_DEVICE_VERTEX_INPUT_DYNAMIC_STATE_FEATURES_EXT
		features_descriptor_buffer.sType = .PHYSICAL_DEVICE_DESCRIPTOR_BUFFER_FEATURES_EXT

		set_next_chain(device_extensions[:], &features_extended_dynamic_state_2, Next_Chain_Entry{"VK_EXT_extended_dynamic_state3", &features_extended_dynamic_state_3}, Next_Chain_Entry{"VK_EXT_vertex_input_dynamic_state", &features_vertex_input_dynamic_state}, Next_Chain_Entry{"VK_EXT_descriptor_buffer", &features_descriptor_buffer})
		vk.GetPhysicalDeviceFeatures2(physical_device, &features)
		if features_1_2.descriptorIndexing == false do return delete_all()

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
			ppEnabledExtensionNames = raw_data(device_extensions),
		}
		result = vk.CreateDevice(physical_device, &info, nil, &device)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, device)
		vk.load_proc_addresses(device)
	}

	{
		{
			if slice.contains(instance_extensions[:], "VK_KHR_get_surface_capabilities2") {
				found: bool
				for surface_format in surface_formats_2 {
					if surface_format.surfaceFormat.format == vk.Format.B8G8R8A8_SRGB && surface_format.surfaceFormat.colorSpace == vk.ColorSpaceKHR.SRGB_NONLINEAR {
						found = true
						swapchain_format = surface_format.surfaceFormat.format
						swapchain_color_space = surface_format.surfaceFormat.colorSpace
						break
					}
				}
				if !found do return delete_all()
			} else {
				found: bool
				for surface_format in surface_formats_1 {
					if surface_format.format == vk.Format.B8G8R8A8_SRGB && surface_format.colorSpace == vk.ColorSpaceKHR.SRGB_NONLINEAR {
						found = true
						swapchain_format = surface_format.format
						swapchain_color_space = surface_format.colorSpace
						break
					}
				}
				if !found do return delete_all()
			}
		}

		platform_fullscreen_info := platform_exclusive_fullscreen_info()
		fullscreen_info := vk.SurfaceFullScreenExclusiveInfoEXT{
			sType = .SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT,
			fullScreenExclusive = .ALLOWED,
		}

		swapchain_info := vk.SwapchainCreateInfoKHR{
			sType = .SWAPCHAIN_CREATE_INFO_KHR,
			surface = surface,
			minImageCount = surface_capabilities.minImageCount != surface_capabilities.maxImageCount ? surface_capabilities.minImageCount + 1 : surface_capabilities.minImageCount,
			imageFormat = swapchain_format,
			imageColorSpace = swapchain_color_space,
			presentMode = slice.contains(present_modes, vk.PresentModeKHR.FIFO_RELAXED) ? .FIFO_RELAXED : .FIFO,
			imageExtent = {width = surface_capabilities.currentExtent.width, height = surface_capabilities.currentExtent.height},
			imageUsage = {.COLOR_ATTACHMENT, .TRANSFER_SRC},
			preTransform = surface_capabilities.currentTransform,
			compositeAlpha = {.OPAQUE},
			clipped = true,
			imageArrayLayers = 1,
		}
		extent = swapchain_info.imageExtent

		set_next_chain(device_extensions[:], &swapchain_info, 
			Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &fullscreen_info}, 
			Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &platform_fullscreen_info})
		result = vk.CreateSwapchainKHR(device, &swapchain_info, nil, &swapchain)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, swapchain)

		swapchain_image_count: u32 = ---
		result = vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, nil)
		if result != .SUCCESS do return delete_all()
		swapchain_images = make([]vk.Image, swapchain_image_count)
		append(&deletion_queue, swapchain_images)
		result = vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, raw_data(swapchain_images))
		if result != .SUCCESS do return delete_all()

		swapchain_image_views = make([]vk.ImageView, len(swapchain_images))
		append(&deletion_queue, swapchain_image_views)
		for &s, i in swapchain_image_views {
			info := vk.ImageViewCreateInfo{
				sType = .IMAGE_VIEW_CREATE_INFO,
				image = swapchain_images[i],
				viewType = .D2,
				format = swapchain_format,
				components = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
				subresourceRange = {
					aspectMask = {.COLOR},
					levelCount = 1,
					layerCount = 1,
				},
			}
			result = vk.CreateImageView(device, &info, nil, &s)
			if result != .SUCCESS do return delete_all()
			append(&deletion_queue, swapchain_image_views[i])
		}
	}

	{
		queues = make([][]vk.Queue, len(queue_family_properties))
		append(&deletion_queue, queues)
		for &queue_family, i in queues {
			queue_family = make([]vk.Queue, queue_family_properties[i].queueCount)
			append(&deletion_queue, queues[i])
			for &queue, j in queue_family {
				vk.GetDeviceQueue(device, u32(i), u32(j), &queue)
			}
		}
	}

	{
		depth_stencil_formats := [?]vk.Format{
			.D32_SFLOAT_S8_UINT,
			.D24_UNORM_S8_UINT,
			.D16_UNORM_S8_UINT,
		}
		for format in depth_stencil_formats {
			p: vk.FormatProperties = ---
			vk.GetPhysicalDeviceFormatProperties(physical_device, format, &p)
			if .DEPTH_STENCIL_ATTACHMENT in p.optimalTilingFeatures {
				depth_stencil_format = format
				break
			}
		}
		if depth_stencil_format == .UNDEFINED do return delete_all()
	}

	allocator = vkma.create_allocator(physical_device, device)

	{
		depth_stencil_image, result = vkma.create_image(&allocator, depth_stencil_format, extent.width, extent.height, 1, 1, 1, {._1}, {.DEPTH_STENCIL_ATTACHMENT}, .UNDEFINED, {.DEVICE_LOCAL}, {.HOST_VISIBLE})
		if result != .SUCCESS do return delete_all()
	}

	{
		fence_info := vk.FenceCreateInfo{
			sType = .FENCE_CREATE_INFO,
			flags = {.SIGNALED},
		}

		semaphore_type_info := vk.SemaphoreTypeCreateInfo{
			sType = .SEMAPHORE_TYPE_CREATE_INFO,
			semaphoreType = .BINARY,
		}
		semaphore_info := vk.SemaphoreCreateInfo{
			sType = .SEMAPHORE_CREATE_INFO,
			pNext = &semaphore_type_info,
		}

		result = vk.CreateFence(device, &fence_info, nil, &fences[0])
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, fences[0])

		result = vk.CreateFence(device, &fence_info, nil, &fences[1])
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, fences[1])
		
		result = vk.CreateSemaphore(device, &semaphore_info, nil, &graphics_semaphores[0])
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, graphics_semaphores[0])

		result = vk.CreateSemaphore(device, &semaphore_info, nil, &graphics_semaphores[1])
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, graphics_semaphores[1])

		result = vk.CreateSemaphore(device, &semaphore_info, nil, &present_semaphores[0])
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, present_semaphores[0])

		result = vk.CreateSemaphore(device, &semaphore_info, nil, &present_semaphores[1])
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, present_semaphores[1])
	}

	{
		info := vk.CommandPoolCreateInfo{
			sType = .COMMAND_POOL_CREATE_INFO,
			flags = {.TRANSIENT, .RESET_COMMAND_BUFFER},
			queueFamilyIndex = 0,
		}
		result = vk.CreateCommandPool(device, &info, nil, &graphics_command_pool)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, graphics_command_pool)
	}

	{
		info := vk.CommandBufferAllocateInfo{
			sType = .COMMAND_BUFFER_ALLOCATE_INFO,
			commandPool = graphics_command_pool,
			level = .PRIMARY,
			commandBufferCount = 2,
		}
		result = vk.AllocateCommandBuffers(device, &info, raw_data(&graphics_command_buffers))
		if result != .SUCCESS do return delete_all()
	}

	staging_buffer, result = vkma.create_buffer(&allocator, size_of(vertices), {.TRANSFER_SRC}, {.HOST_VISIBLE}, {.DEVICE_LOCAL})
	if result != .SUCCESS do return delete_all()

	vertex_buffer, result = vkma.create_buffer(&allocator, size_of(vertices), {.TRANSFER_DST, .VERTEX_BUFFER}, {.DEVICE_LOCAL}, {.HOST_VISIBLE})
	if result != .SUCCESS do return delete_all()

	if vkma.alloc(&allocator) != .SUCCESS do return delete_all()

	{
		info := vk.ImageViewCreateInfo{
			sType = .IMAGE_VIEW_CREATE_INFO,
			image = depth_stencil_image,
			viewType = .D2,
			format = depth_stencil_format,
			components = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
			subresourceRange = {
				aspectMask = {.DEPTH, .STENCIL},
				levelCount = 1,
				layerCount = 1,
			},
		}
		result = vk.CreateImageView(ctx.device, &info, nil, &depth_stencil_image_view)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, depth_stencil_image_view)
	}

	{
		data, result := vkma.map_memory(&allocator, staging_buffer, 0, size_of(vertices), {})
		if result != .SUCCESS do return delete_all()
		copy(data, slice.to_bytes(vertices[:]))
		vkma.unmap_memory(&allocator, staging_buffer)
	}

	{
		dynamic_states = make([dynamic]vk.DynamicState)
		append(&deletion_queue, dynamic_states)
		append(&dynamic_states,
			vk.DynamicState.LINE_WIDTH,
			//vk.DynamicState.DEPTH_BIAS,
			//vk.DynamicState.BLEND_CONSTANTS,
			//vk.DynamicState.DEPTH_BOUNDS,
			//vk.DynamicState.STENCIL_COMPARE_MASK,
			//vk.DynamicState.STENCIL_WRITE_MASK,
			//vk.DynamicState.STENCIL_REFERENCE,
			//vk.DynamicState.CULL_MODE,
			vk.DynamicState.FRONT_FACE,
			vk.DynamicState.PRIMITIVE_TOPOLOGY,
			vk.DynamicState.VIEWPORT_WITH_COUNT,
			vk.DynamicState.SCISSOR_WITH_COUNT,
			//vk.DynamicState.VERTEX_INPUT_BINDING_STRIDE,
			//vk.DynamicState.DEPTH_TEST_ENABLE,
			//vk.DynamicState.DEPTH_WRITE_ENABLE,
			//vk.DynamicState.DEPTH_COMPARE_OP,
			//vk.DynamicState.DEPTH_BOUNDS_TEST_ENABLE,
			//vk.DynamicState.STENCIL_OP,
			//vk.DynamicState.RASTERIZER_DISCARD_ENABLE,
			//vk.DynamicState.DEPTH_BIAS_ENABLE,
			//vk.DynamicState.PRIMITIVE_RESTART_ENABLE,
			vk.DynamicState.VERTEX_INPUT_EXT)
		//if features_extended_dynamic_state_2.extendedDynamicState2LogicOp 							do append(&dynamic_states, vk.DynamicState.LOGIC_OP_EXT)
		//else do panic("no logic op!")
		//if features_extended_dynamic_state_2.extendedDynamicState2PatchControlPoints 				do append(&dynamic_states, vk.DynamicState.PATCH_CONTROL_POINTS_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3TessellationDomainOrigin 			do append(&dynamic_states, vk.DynamicState.TESSELLATION_DOMAIN_ORIGIN_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3DepthClampEnable 					do append(&dynamic_states, vk.DynamicState.DEPTH_CLAMP_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3PolygonMode 						do append(&dynamic_states, vk.DynamicState.POLYGON_MODE_EXT)
		//else do panic("no dynamic polygon mode!")
		//if features_extended_dynamic_state_3.extendedDynamicState3RasterizationSamples 				do append(&dynamic_states, vk.DynamicState.RASTERIZATION_SAMPLES_EXT)
		//else do return delete_all()
		//if features_extended_dynamic_state_3.extendedDynamicState3SampleMask 						do append(&dynamic_states, vk.DynamicState.SAMPLE_MASK_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3AlphaToCoverageEnable 			do append(&dynamic_states, vk.DynamicState.ALPHA_TO_COVERAGE_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3AlphaToOneEnable 					do append(&dynamic_states, vk.DynamicState.ALPHA_TO_ONE_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3LogicOpEnable 					do append(&dynamic_states, vk.DynamicState.LOGIC_OP_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ColorBlendEnable 					do append(&dynamic_states, vk.DynamicState.COLOR_BLEND_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ColorBlendEquation 				do append(&dynamic_states, vk.DynamicState.COLOR_BLEND_EQUATION_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ColorWriteMask 					do append(&dynamic_states, vk.DynamicState.COLOR_WRITE_MASK_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3RasterizationStream 				do append(&dynamic_states, vk.DynamicState.RASTERIZATION_STREAM_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ConservativeRasterizationMode 	do append(&dynamic_states, vk.DynamicState.CONSERVATIVE_RASTERIZATION_MODE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ExtraPrimitiveOverestimationSize 	do append(&dynamic_states, vk.DynamicState.EXTRA_PRIMITIVE_OVERESTIMATION_SIZE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3DepthClipEnable 					do append(&dynamic_states, vk.DynamicState.DEPTH_CLIP_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3SampleLocationsEnable 			do append(&dynamic_states, vk.DynamicState.SAMPLE_LOCATIONS_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ColorBlendAdvanced 				do append(&dynamic_states, vk.DynamicState.COLOR_BLEND_ADVANCED_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3ProvokingVertexMode 				do append(&dynamic_states, vk.DynamicState.PROVOKING_VERTEX_MODE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3LineRasterizationMode 			do append(&dynamic_states, vk.DynamicState.LINE_RASTERIZATION_MODE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3LineStippleEnable 				do append(&dynamic_states, vk.DynamicState.LINE_STIPPLE_ENABLE_EXT)
		//if features_extended_dynamic_state_3.extendedDynamicState3DepthClipNegativeOneToOne 		do append(&dynamic_states, vk.DynamicState.DEPTH_CLIP_NEGATIVE_ONE_TO_ONE_EXT)
	}

	vertex_shader_module, result = create_shader_module("vert.spv")
	if result != .SUCCESS do return delete_all()
	append(&deletion_queue, vertex_shader_module)

	fragment_shader_module, result = create_shader_module("frag.spv")
	if result != .SUCCESS do return delete_all()
	append(&deletion_queue, fragment_shader_module)

	{
		info := vk.PipelineCacheCreateInfo{
			sType = .PIPELINE_CACHE_CREATE_INFO,
			flags = {.EXTERNALLY_SYNCHRONIZED},
		}
		result = vk.CreatePipelineCache(device, &info, nil, &pipeline_cache)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, pipeline_cache)
	}

	//{
	//	info := vk.DescriptorSetLayoutCreateInfo{
	//		sType = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
	//		//flags = {.CREATE_UPDATE_AFTER_BIND_POOL},
	//		//bindingCount
	//		//pBindings
	//	}
	//	result = vk.CreateDescriptorSetLayout(device, &info, nil, &descriptor_set_layout)
	//	if result != .SUCCESS do return delete_all()
	//	append(&deletion_queue, descriptor_set_layout)
	//}

	{
		info := vk.PipelineLayoutCreateInfo{
			sType = .PIPELINE_LAYOUT_CREATE_INFO,
		}
		result = vk.CreatePipelineLayout(device, &info, nil, &pipeline_layout)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, pipeline_layout)
	}

	{
		stages := [?]vk.PipelineShaderStageCreateInfo{
			{
				sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
				stage = {.VERTEX},
				module = vertex_shader_module,
				pName = "main",
			},
			{
				sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
				stage = {.FRAGMENT},
				module = fragment_shader_module,
				pName = "main",
			},
		}

		// NOTE(pJotoro): It actually isn't that straightforward to not include this.
		// "If the VK_EXT_extended_dynamic_state3 extension is enabled, it can be NULL if the pipeline is created with 
		// both VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE, and VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY dynamic states set 
		// and dynamicPrimitiveTopologyUnrestricted is VK_TRUE."
		// https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkGraphicsPipelineCreateInfo.html
		input_assembly := vk.PipelineInputAssemblyStateCreateInfo{
			sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
			topology = .TRIANGLE_LIST,
		}
		tessellation := vk.PipelineTessellationStateCreateInfo{
			sType = .PIPELINE_TESSELLATION_STATE_CREATE_INFO,
		}
		viewport := vk.PipelineViewportStateCreateInfo{
			sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
		}
		rasterization := vk.PipelineRasterizationStateCreateInfo{
			sType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
		}
		multisample := vk.PipelineMultisampleStateCreateInfo{
			sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
			rasterizationSamples = {._1},
		}
		depth_stencil := vk.PipelineDepthStencilStateCreateInfo{
			sType = .PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
		}
		color_blend := vk.PipelineColorBlendStateCreateInfo{
			sType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
		}
		dynamic_ := vk.PipelineDynamicStateCreateInfo{
			sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
			dynamicStateCount = u32(len(dynamic_states)),
			pDynamicStates = raw_data(dynamic_states),
		}

		rendering_info := vk.PipelineRenderingCreateInfo{
			sType = .PIPELINE_RENDERING_CREATE_INFO,
			colorAttachmentCount = 1,
			pColorAttachmentFormats = &swapchain_format,
			depthAttachmentFormat = depth_stencil_format,
			stencilAttachmentFormat = depth_stencil_format,
		}
		info := vk.GraphicsPipelineCreateInfo{
			sType = .GRAPHICS_PIPELINE_CREATE_INFO,
			pNext = &rendering_info,
			stageCount = u32(len(stages)),
			pStages = raw_data(&stages),
			pInputAssemblyState = &input_assembly,
			pTessellationState = &tessellation,
			pViewportState = &viewport,
			pRasterizationState = &rasterization,
			pMultisampleState = &multisample,
			pDepthStencilState = &depth_stencil,
			pColorBlendState = &color_blend,
			pDynamicState = &dynamic_,
			layout = pipeline_layout,
		}
		result = vk.CreateGraphicsPipelines(device, pipeline_cache, 1, &info, nil, &pipeline)
		if result != .SUCCESS do return delete_all()
		append(&deletion_queue, pipeline)
	}

	return true
}

present :: proc() {
	result: vk.Result

	{
		swapchain_image_index: u32 = ---
		result = vk.AcquireNextImageKHR(ctx.device, ctx.swapchain, max(u64), ctx.graphics_semaphores[ctx.submission_index], 0, &swapchain_image_index)
		assert(result == .SUCCESS)
		ctx.swapchain_image_index = int(swapchain_image_index)
	}

	result = vk.WaitForFences(ctx.device, 1, &ctx.fences[ctx.submission_index], true, max(u64))
	assert(result == .SUCCESS)
	result = vk.ResetFences(ctx.device, 1, &ctx.fences[ctx.submission_index])
	assert(result == .SUCCESS)

	command_buffer := ctx.graphics_command_buffers[ctx.submission_index]

	{
		info := vk.CommandBufferBeginInfo{
			sType = .COMMAND_BUFFER_BEGIN_INFO,
			flags = {.ONE_TIME_SUBMIT},
		}
		result = vk.BeginCommandBuffer(command_buffer, &info)
		assert(result == .SUCCESS)
	}
	{
		buffer_barriers := [?]vk.BufferMemoryBarrier2{
			{
				sType = .BUFFER_MEMORY_BARRIER_2,
				srcStageMask = {.TRANSFER},
				dstAccessMask = {.VERTEX_ATTRIBUTE_READ},
				dstStageMask = {.VERTEX_INPUT},
				buffer = ctx.vertex_buffer,
				offset = 0,
				size = size_of(vertices),
			},
		}

		@(static)
		copy_staging_buffer := true

		image_barriers := [?]vk.ImageMemoryBarrier2{
			{
				sType = .IMAGE_MEMORY_BARRIER_2,
				dstAccessMask = {.COLOR_ATTACHMENT_WRITE},
				dstStageMask = {.COLOR_ATTACHMENT_OUTPUT},
				oldLayout = .UNDEFINED,
				newLayout = .COLOR_ATTACHMENT_OPTIMAL,
				image = ctx.swapchain_images[ctx.swapchain_image_index],
				subresourceRange = {
					aspectMask = {.COLOR},
					levelCount = 1,
					layerCount = 1,
				},
			},
			{
				sType = .IMAGE_MEMORY_BARRIER_2,
				srcAccessMask = {.COLOR_ATTACHMENT_WRITE},
				srcStageMask = {.COLOR_ATTACHMENT_OUTPUT},
				dstStageMask = {.COLOR_ATTACHMENT_OUTPUT},
				oldLayout = .COLOR_ATTACHMENT_OPTIMAL,
				newLayout = .PRESENT_SRC_KHR,
				image = ctx.swapchain_images[ctx.swapchain_image_index],
				subresourceRange = {
					aspectMask = {.COLOR},
					levelCount = 1,
					layerCount = 1,
				},
			},
		}
		
		info := vk.DependencyInfo{
			sType = .DEPENDENCY_INFO,
			bufferMemoryBarrierCount = copy_staging_buffer ? u32(len(buffer_barriers)) : 0,
			pBufferMemoryBarriers = copy_staging_buffer ? raw_data(&buffer_barriers) : nil,
			imageMemoryBarrierCount = u32(len(image_barriers)),
			pImageMemoryBarriers = raw_data(&image_barriers),
		}
		vk.CmdPipelineBarrier2(command_buffer, &info)

		if copy_staging_buffer {
			copy_staging_buffer = false

			region := vk.BufferCopy{0, 0, size_of(vertices)}
			vk.CmdCopyBuffer(command_buffer, ctx.staging_buffer, ctx.vertex_buffer, 1, &region)
		}
	}

	{
		color_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = ctx.swapchain_image_views[ctx.swapchain_image_index],
			imageLayout = .COLOR_ATTACHMENT_OPTIMAL,
			loadOp = .CLEAR,
			storeOp = .STORE,
		}

		depth_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = ctx.depth_stencil_image_view,
			imageLayout = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
			loadOp = .CLEAR,
			storeOp = .STORE,
		}

		stencil_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = ctx.depth_stencil_image_view,
			imageLayout = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
			loadOp = .CLEAR,
			storeOp = .STORE,
		}

		info := vk.RenderingInfo{
			sType = .RENDERING_INFO,
			renderArea = {extent = ctx.extent},
			layerCount = 1,
			colorAttachmentCount = 1,
			pColorAttachments = &color_attachment,
			pDepthAttachment = &depth_attachment,
			pStencilAttachment = &stencil_attachment,
		}

		vk.CmdBeginRendering(command_buffer, &info)
	}

	vk.CmdSetLineWidth(command_buffer, 1)
	vk.CmdSetPrimitiveTopology(command_buffer, .TRIANGLE_LIST)
	vk.CmdSetFrontFace(command_buffer, .CLOCKWISE)
	viewport := vk.Viewport{0, 0, f32(ctx.extent.width), f32(ctx.extent.height), 0, 1}
	vk.CmdSetViewportWithCount(command_buffer, 1, &viewport)
	scissor := vk.Rect2D{extent = ctx.extent}
	vk.CmdSetScissorWithCount(command_buffer, 1, &scissor)

	binding := vk.VertexInputBindingDescription2EXT{
		sType = .VERTEX_INPUT_BINDING_DESCRIPTION_2_EXT,
		binding = 0,
		stride = size_of(f32) * 3,
		inputRate = .VERTEX,
		divisor = 1,
	}
	attribute := vk.VertexInputAttributeDescription2EXT{
		sType = .VERTEX_INPUT_ATTRIBUTE_DESCRIPTION_2_EXT,
		location = 0,
		binding = 0,
		format = .R32G32B32_SFLOAT,
		offset = 0,
	}
	vk.CmdSetVertexInputEXT(command_buffer, 1, &binding, 1, &attribute)

	vk.CmdBindPipeline(command_buffer, .GRAPHICS, ctx.pipeline)
	vk.CmdDraw(command_buffer, 3, 1, 0, 0)
	
	vk.CmdEndRendering(command_buffer)
	result = vk.EndCommandBuffer(command_buffer)
	assert(result == .SUCCESS)

	{
		dst_stages := [?]vk.PipelineStageFlags{{.COLOR_ATTACHMENT_OUTPUT}}
		wait_semaphores := [?]vk.Semaphore{ctx.graphics_semaphores[ctx.submission_index]}
		signal_semaphores := [?]vk.Semaphore{ctx.present_semaphores[ctx.submission_index]}
		info := vk.SubmitInfo{
			sType = .SUBMIT_INFO,
			waitSemaphoreCount = u32(len(wait_semaphores)),
			pWaitSemaphores = raw_data(&wait_semaphores),
			pWaitDstStageMask = raw_data(&dst_stages),
			commandBufferCount = 1,
			pCommandBuffers = &ctx.graphics_command_buffers[ctx.submission_index],
			signalSemaphoreCount = u32(len(signal_semaphores)),
			pSignalSemaphores = raw_data(&signal_semaphores),
		}
		result = vk.QueueSubmit(ctx.queues[0][0], 1, &info, ctx.fences[ctx.submission_index])
		assert(result == .SUCCESS)
	}
	
	{
		i := u32(ctx.swapchain_image_index)
		info := vk.PresentInfoKHR{
			sType = .PRESENT_INFO_KHR,
			waitSemaphoreCount = 1,
			pWaitSemaphores = &ctx.present_semaphores[ctx.submission_index],
			swapchainCount = 1,
			pSwapchains = &ctx.swapchain,
			pImageIndices = &i,
		}
		result = vk.QueuePresentKHR(ctx.queues[0][0], &info)
		assert(result == .SUCCESS)
	}

	ctx.submission_index = ctx.submission_index == 0 ? 1 : 0
}