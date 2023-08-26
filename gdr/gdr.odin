package gdr

import vk "vendor:vulkan"
import "core:dynlib"
import "../app"
import "core:strings"
import "core:log"
import "core:runtime"
import "core:slice"
import "core:fmt"
import "core:os"
import "core:mem"

@(private)
Context :: struct {
	// ----- instance -----
	instance: vk.Instance,
	instance_extensions: [dynamic]cstring,
	// --------------------

	// ----- physical device -----
	physical_device: vk.PhysicalDevice,

	properties: vk.PhysicalDeviceProperties,
	descriptor_buffer_properties: vk.PhysicalDeviceDescriptorBufferPropertiesEXT,

	features: vk.PhysicalDeviceFeatures2,
	features_1_1: vk.PhysicalDeviceVulkan11Features,
	features_1_2: vk.PhysicalDeviceVulkan12Features,
	features_1_3: vk.PhysicalDeviceVulkan13Features,
	features_extended_dynamic_state_2: vk.PhysicalDeviceExtendedDynamicState2FeaturesEXT,
	features_extended_dynamic_state_3: vk.PhysicalDeviceExtendedDynamicState3FeaturesEXT,
	features_vertex_input_dynamic_state: vk.PhysicalDeviceVertexInputDynamicStateFeaturesEXT,
	features_descriptor_buffer: vk.PhysicalDeviceDescriptorBufferFeaturesEXT,
	// ---------------------------

	// ----- surface -----
	surface: vk.SurfaceKHR,
	surface_capabilities: vk.SurfaceCapabilitiesKHR,
	surface_capabilities_hdr_amd: vk.DisplayNativeHdrSurfaceCapabilitiesAMD,
	surface_capabilities_fullscreen_exclusive: vk.SurfaceCapabilitiesFullScreenExclusiveEXT,
	// -------------------
	
	// ----- device -----
	device: vk.Device,
	device_extensions: [dynamic]cstring,
	// ------------------
	
	// ----- memory -----
	_memory_properties: vk.PhysicalDeviceMemoryProperties,
	memory_types: []vk.MemoryType,
	memory_heaps: []vk.MemoryHeap,
	//allocations: [][dynamic]Allocation, // [len(memory_types)][dynamic]
	// ------------------

	// ----- swapchain -----
	swapchain: vk.SwapchainKHR,
	swapchain_format: vk.Format,
	swapchain_color_space: vk.ColorSpaceKHR,
	swapchain_images: []vk.Image,
	swapchain_image_views: []vk.ImageView,
	swapchain_image_index: int,
	extent: vk.Extent2D,
	// ---------------------

	// ----- execution -----
	queue_family_properties: []vk.QueueFamilyProperties,
	queues: [][]vk.Queue,
	dynamic_states: [dynamic]vk.DynamicState,
	// ---------------------

	// ----- depth stencil -----
	depth_stencil_format: vk.Format,
	depth_stencil_image: vk.Image,
	depth_stencil_image_view: vk.ImageView,
	// -------------------------

	// ----- synchronization/concurrency -----

	// ---------------------------------------

	// ----- subject to change -----
	fences: [2]vk.Fence,
	graphics_semaphores: [2]vk.Semaphore,
	present_semaphores: [2]vk.Semaphore,
	command_pool: vk.CommandPool,
	command_buffers: [2]vk.CommandBuffer,
	submission_index: int,
	// ----------------------------	
}
@(private)
ctx: Context

// TODO(pJotoro): Figure out a way to destory Vulkan objects in a way that's both safe and efficient.

init :: proc() -> bool {
	using ctx

	result: vk.Result

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
		assert(version > vk.API_VERSION_1_3)
	}

	instance_extensions = make([dynamic]cstring, 0, 32)
	{
		app_name := strings.clone_to_cstring(app.name(), context.temp_allocator)
		app_info := vk.ApplicationInfo{
			sType = .APPLICATION_INFO,
			pApplicationName = app_name,
			apiVersion = vk.API_VERSION_1_3,
		}

		append(&instance_extensions, cstring("VK_KHR_surface"), VK_KHR_platform_surface)

		when ODIN_DEBUG {
			layers := [?]cstring{
				"VK_LAYER_KHRONOS_validation",
			}
			append(&instance_extensions, cstring("VK_EXT_debug_utils"), "VK_EXT_validation_features")

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
			assert(result == .SUCCESS)
			instance_extension_properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
			result = vk.EnumerateInstanceExtensionProperties(nil, &count, raw_data(instance_extension_properties))
			assert(result == .SUCCESS)
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
			enabledExtensionCount = u32(len(instance_extensions)),
			ppEnabledExtensionNames = raw_data(instance_extensions),
		}
		when ODIN_DEBUG {
			info.pNext = &debug_info
			info.enabledLayerCount = u32(len(layers))
			info.ppEnabledLayerNames = raw_data(&layers)
		}
		result = vk.CreateInstance(&info, nil, &instance)
		assert(result == .SUCCESS)
		vk.load_proc_addresses(instance)
	}

	{
		result = create_surface()
		assert(result == .SUCCESS)
	}

	device_extensions = make([dynamic]cstring, 0, 128)
	{
		physical_device_count: u32 = ---
		result = vk.EnumeratePhysicalDevices(instance, &physical_device_count, nil)
		assert(result == .SUCCESS)
		physical_devices := make([]vk.PhysicalDevice, physical_device_count, context.temp_allocator)
		result = vk.EnumeratePhysicalDevices(instance, &physical_device_count, raw_data(physical_devices))
		assert(result == .SUCCESS)

		chosen_physical_device: Maybe(vk.PhysicalDevice)
		physical_device_loop: for physical_device, i in physical_devices {
			@(static)
			required_device_extensions := [?]cstring{
				"VK_KHR_swapchain", 
				"VK_EXT_extended_dynamic_state3", 
				"VK_EXT_vertex_input_dynamic_state", 
				"VK_EXT_descriptor_buffer",
			}
			@(static)
			desired_device_extensions := [?]cstring{
				"VK_EXT_full_screen_exclusive",
				"VK_AMD_display_native_hdr",
			}

			for instance_extension in instance_extensions {
				count: u32 = ---
				result = vk.EnumerateDeviceExtensionProperties(physical_device, instance_extension, &count, nil)
				assert(result == .SUCCESS)
				properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
				result = vk.EnumerateDeviceExtensionProperties(physical_device, instance_extension, &count, raw_data(properties))
				assert(result == .SUCCESS)
				found: [len(required_device_extensions)]bool
				find_device_extensions: for &p in properties {
					for device_extension, found_index in required_device_extensions {
						if cstring(raw_data(&p.extensionName)) == device_extension {
							found[found_index] = true
							append(&device_extensions, device_extension)
							continue find_device_extensions
						}
					}
					for device_extension in desired_device_extensions {
						if cstring(&p.extensionName[0]) == device_extension { 
							append(&device_extensions, device_extension)
							continue find_device_extensions
						}
					}
				}
			}
			count: u32 = ---
			result = vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, nil)
			assert(result == .SUCCESS)
			properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
			vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, raw_data(properties))
			assert(result == .SUCCESS)
			found: [len(required_device_extensions)]bool
			find_device_extensions_no_layer: for &p in properties {
				for device_extension, found_index in required_device_extensions {
					if cstring(&p.extensionName[0]) == device_extension {
						found[found_index] = true
						append(&device_extensions, device_extension)
						continue find_device_extensions_no_layer
					}
				}
				for device_extension in desired_device_extensions {
					if cstring(&p.extensionName[0]) == device_extension { 
						append(&device_extensions, device_extension)
						continue find_device_extensions_no_layer
					}
				}
			}
			for f in found {
				if !f do continue physical_device_loop
			}
			chosen_physical_device = physical_device
			assert(i == 1)
			break physical_device_loop
		}
		ok: bool = ---
		physical_device, ok = chosen_physical_device.(vk.PhysicalDevice)
		assert(ok)
	}

	surface_capabilities_hdr_amd.sType = .DISPLAY_NATIVE_HDR_SURFACE_CAPABILITIES_AMD
	surface_capabilities_fullscreen_exclusive.sType = .SURFACE_CAPABILITIES_FULL_SCREEN_EXCLUSIVE_EXT

	present_modes: []vk.PresentModeKHR
	if slice.contains(device_extensions[:], "VK_EXT_full_screen_exclusive") && app.fullscreen() {
		platform_fullscreen_info := platform_exclusive_fullscreen_info()
		fullscreen_info := vk.SurfaceFullScreenExclusiveInfoEXT{
			sType = .SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT,
			pNext = &platform_fullscreen_info,
			fullScreenExclusive = .ALLOWED,
		}
		info := vk.PhysicalDeviceSurfaceInfo2KHR{
			sType = .PHYSICAL_DEVICE_SURFACE_INFO_2_KHR,
			pNext = &fullscreen_info,
			surface = surface,
		}
		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfacePresentModes2EXT(physical_device, &info, &count, nil)
		assert(result == .SUCCESS)
		present_modes = make([]vk.PresentModeKHR, count, context.temp_allocator)
		result = vk.GetPhysicalDeviceSurfacePresentModes2EXT(physical_device, &info, &count, raw_data(present_modes))
		assert(result == .SUCCESS)
	} else {
		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, nil)
		assert(result == .SUCCESS)
		present_modes = make([]vk.PresentModeKHR, count, context.temp_allocator)
		result = vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, raw_data(present_modes))
		assert(result == .SUCCESS)
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
				Next_Chain_Entry{"VK_AMD_display_native_hdr", &surface_capabilities_hdr_amd}, 
				Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &surface_capabilities_fullscreen_exclusive}, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
		} else {
			set_next_chain(instance_extensions[:], device_extensions[:], &info, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
			set_next_chain(instance_extensions[:], device_extensions[:], &surface_capabilities_2, 
				Next_Chain_Entry{"VK_AMD_display_native_hdr", &surface_capabilities_hdr_amd}, 
				Next_Chain_Entry{"VK_EXT_surface_maintenance1", &surface_present_mode})
		}

		result = vk.GetPhysicalDeviceSurfaceCapabilities2KHR(physical_device, &info, &surface_capabilities_2)
		assert(result == .SUCCESS)

		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfaceFormats2KHR(physical_device, &info, &count, nil)
		assert(result == .SUCCESS)
		surface_formats_2 = make([]vk.SurfaceFormat2KHR, count, context.temp_allocator)
		for &f in surface_formats_2 do f.sType = .SURFACE_FORMAT_2_KHR
		result = vk.GetPhysicalDeviceSurfaceFormats2KHR(physical_device, &info, &count, raw_data(surface_formats_2))
		assert(result == .SUCCESS)

		surface_capabilities = surface_capabilities_2.surfaceCapabilities
	} else {
		result = vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &surface_capabilities)
		assert(result == .SUCCESS)
		count: u32 = ---
		result = vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, nil)
		assert(result == .SUCCESS)
		surface_formats_1 = make([]vk.SurfaceFormatKHR, count, context.temp_allocator)
		result = vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, raw_data(surface_formats_1))
		assert(result == .SUCCESS)
	}

	{
		count: u32 = ---
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, nil)
		queue_family_properties = make([]vk.QueueFamilyProperties, count)
		vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, raw_data(queue_family_properties))
	}

	present_queue_family_indices := make([dynamic]int, 0, len(queue_family_properties), context.temp_allocator)
	{
		for i in 0..<len(queue_family_properties) {
			supported: b32 = ---
			result = vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, u32(i), surface, &supported)
			assert(result == .SUCCESS)
			if supported do append(&present_queue_family_indices, i)
		}
		assert(len(present_queue_family_indices) != 0)
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
		features_extended_dynamic_state_2.pNext = &features_extended_dynamic_state_3
		features_extended_dynamic_state_3.sType = .PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_3_FEATURES_EXT
		features_extended_dynamic_state_3.pNext = &features_vertex_input_dynamic_state
		features_vertex_input_dynamic_state.sType = .PHYSICAL_DEVICE_VERTEX_INPUT_DYNAMIC_STATE_FEATURES_EXT
		features_vertex_input_dynamic_state.pNext = &features_descriptor_buffer
		features_descriptor_buffer.sType = .PHYSICAL_DEVICE_DESCRIPTOR_BUFFER_FEATURES_EXT
		vk.GetPhysicalDeviceFeatures2(physical_device, &features)
		assert(features_1_2.descriptorIndexing == true)

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
		assert(result == .SUCCESS)
		vk.load_proc_addresses(device)
	}

	{
		{
			// TODO(pJotoro): DISPLAY_NATIVE_AMD
			if slice.contains(instance_extensions[:], "VK_KHR_get_surface_capabilities2") {
				found: bool
				for surface_format in surface_formats_2 {
					if surface_format.surfaceFormat.format == vk.Format.B8G8R8A8_SRGB && surface_format.surfaceFormat.colorSpace == vk.ColorSpaceKHR.SRGB_NONLINEAR {
						found = true
						swapchain_format = .B8G8R8A8_SRGB
						swapchain_color_space = .SRGB_NONLINEAR
						break
					}
				}
				assert(found)
			} else {
				found: bool
				for surface_format in surface_formats_1 {
					if surface_format.format == vk.Format.B8G8R8A8_SRGB && surface_format.colorSpace == vk.ColorSpaceKHR.SRGB_NONLINEAR {
						found = true
						swapchain_format = .B8G8R8A8_SRGB
						swapchain_color_space = .SRGB_NONLINEAR
						break
					}
				}
				assert(found)
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
			minImageCount = surface_capabilities.maxImageCount == 0 ? surface_capabilities.minImageCount + 1 : surface_capabilities.maxImageCount,
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

		set_next_chain(device_extensions[:], &swapchain_info, Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &fullscreen_info}, Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &platform_fullscreen_info})
		result = vk.CreateSwapchainKHR(device, &swapchain_info, nil, &swapchain)
		assert(result == .SUCCESS)

		swapchain_image_count: u32 = ---
		result = vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, nil)
		assert(result == .SUCCESS)
		swapchain_images = make([]vk.Image, swapchain_image_count)
		result = vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, raw_data(swapchain_images))
		assert(result == .SUCCESS)

		swapchain_image_views = make([]vk.ImageView, len(swapchain_images))
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
			assert(result == .SUCCESS)
		}
	}

	{
		queues = make([][]vk.Queue, len(queue_family_properties))
		for &queue_family, i in queues {
			queue_family = make([]vk.Queue, queue_family_properties[i].queueCount)
			for &queue, j in queue_family {
				vk.GetDeviceQueue(device, u32(i), u32(j), &queue)
			}
		}
	}

	{
		vk.GetPhysicalDeviceMemoryProperties(physical_device, &_memory_properties)
		memory_types = _memory_properties.memoryTypes[:int(_memory_properties.memoryTypeCount)]
		memory_heaps = _memory_properties.memoryHeaps[:int(_memory_properties.memoryHeapCount)]
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
		assert(depth_stencil_format != .UNDEFINED)
	}

	{
		// TODO
		for i in 0..<2 {
			fence_info := vk.FenceCreateInfo{
				sType = .FENCE_CREATE_INFO,
				flags = {.SIGNALED},
			}
			result = vk.CreateFence(device, &fence_info, nil, &fences[i])
			assert(result == .SUCCESS)

			semaphore_type_info := vk.SemaphoreTypeCreateInfo{
				sType = .SEMAPHORE_TYPE_CREATE_INFO,
				semaphoreType = .BINARY,
			}
			semaphore_info := vk.SemaphoreCreateInfo{
				sType = .SEMAPHORE_CREATE_INFO,
				pNext = &semaphore_type_info,
			}
			result = vk.CreateSemaphore(device, &semaphore_info, nil, &graphics_semaphores[i])
			assert(result == .SUCCESS)

			result = vk.CreateSemaphore(device, &semaphore_info, nil, &present_semaphores[i])
			assert(result == .SUCCESS)
		}
	}

	{
		info := vk.CommandPoolCreateInfo{
			sType = .COMMAND_POOL_CREATE_INFO,
			flags = {.TRANSIENT, .RESET_COMMAND_BUFFER},
			queueFamilyIndex = 0,
		}
		result = vk.CreateCommandPool(device, &info, nil, &command_pool)
		assert(result == .SUCCESS)
	}

	{
		info := vk.CommandBufferAllocateInfo{
			sType = .COMMAND_BUFFER_ALLOCATE_INFO,
			commandPool = command_pool,
			level = .PRIMARY,
			commandBufferCount = 2,
		}
		result = vk.AllocateCommandBuffers(device, &info, raw_data(&command_buffers))
		assert(result == .SUCCESS)
	}

	{
		dynamic_states = make([dynamic]vk.DynamicState)
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
		if features_extended_dynamic_state_3.extendedDynamicState3RasterizationSamples 				do append(&dynamic_states, vk.DynamicState.RASTERIZATION_SAMPLES_EXT)
		else do panic("no rasterization samples!")
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

	return true
}

update :: proc() {
	result: vk.Result

	result = vk.WaitForFences(ctx.device, 1, &ctx.fences[ctx.submission_index], true, max(u64))
	assert(result == .SUCCESS)
	result = vk.ResetFences(ctx.device, 1, &ctx.fences[ctx.submission_index])
	assert(result == .SUCCESS)

	command_buffer := ctx.command_buffers[ctx.submission_index]

	swapchain_image_index: u32 = ---
	{
		result = vk.AcquireNextImageKHR(ctx.device, ctx.swapchain, max(u64), ctx.graphics_semaphores[ctx.submission_index], 0, &swapchain_image_index)
		assert(result == .SUCCESS)
		ctx.swapchain_image_index = int(swapchain_image_index)
	}
	{
		info := vk.CommandBufferBeginInfo{
			sType = .COMMAND_BUFFER_BEGIN_INFO,
			flags = {.ONE_TIME_SUBMIT},
		}
		result = vk.BeginCommandBuffer(command_buffer, &info)
		assert(result == .SUCCESS)
	}
	{
		image_barrier := vk.ImageMemoryBarrier2 {
			sType = .IMAGE_MEMORY_BARRIER_2,
			srcStageMask = {.COLOR_ATTACHMENT_OUTPUT},
			dstStageMask = {.COLOR_ATTACHMENT_OUTPUT},
			dstAccessMask = {.COLOR_ATTACHMENT_WRITE},
			oldLayout = .UNDEFINED,
			newLayout = .PRESENT_SRC_KHR,
			image = ctx.swapchain_images[ctx.swapchain_image_index],
			subresourceRange = {
				aspectMask = {.COLOR},
				levelCount = 1,
				layerCount = 1,
			},
		}
		
		info := vk.DependencyInfo{
			sType = .DEPENDENCY_INFO,
			imageMemoryBarrierCount = 1,
			pImageMemoryBarriers = &image_barrier,
		}
		vk.CmdPipelineBarrier2(command_buffer, &info)
	}

	{
		color_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = ctx.swapchain_image_views[ctx.swapchain_image_index],
			imageLayout = .COLOR_ATTACHMENT_OPTIMAL,
			loadOp = .CLEAR,
			storeOp = .STORE,
		}

		/*
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
		*/

		info := vk.RenderingInfo{
			sType = .RENDERING_INFO,
			renderArea = {extent = ctx.extent},
			layerCount = 1,
			colorAttachmentCount = 1,
			pColorAttachments = &color_attachment,
			//pDepthAttachment = &depth_attachment,
			//pStencilAttachment = &stencil_attachment,
		}

		vk.CmdBeginRendering(command_buffer, &info)
	}

	vk.CmdSetLineWidth(command_buffer, 1)
	vk.CmdSetPrimitiveTopology(command_buffer, .TRIANGLE_LIST)
	vk.CmdSetFrontFace(command_buffer, .CLOCKWISE)
	vk.CmdSetRasterizationSamplesEXT(command_buffer, {._1})
	viewport := vk.Viewport{0, 0, f32(ctx.extent.width), f32(ctx.extent.height), 0, 1}
	vk.CmdSetViewportWithCount(command_buffer, 1, &viewport)
	scissor := vk.Rect2D{extent = ctx.extent}
	vk.CmdSetScissorWithCount(command_buffer, 1, &scissor)
	
	vk.CmdEndRendering(command_buffer)
	result = vk.EndCommandBuffer(command_buffer)
	assert(result == .SUCCESS)

	{
		dst_stage := vk.PipelineStageFlags{.COLOR_ATTACHMENT_OUTPUT}
		info := vk.SubmitInfo{
			sType = .SUBMIT_INFO,
			waitSemaphoreCount = 1,
			pWaitSemaphores = &ctx.graphics_semaphores[ctx.submission_index],
			pWaitDstStageMask = &dst_stage,
			commandBufferCount = 1,
			pCommandBuffers = &ctx.command_buffers[ctx.submission_index],
			signalSemaphoreCount = 1,
			pSignalSemaphores = &ctx.present_semaphores[ctx.submission_index],
		}
		result = vk.QueueSubmit(ctx.queues[0][ctx.submission_index], 1, &info, ctx.fences[ctx.submission_index])
		assert(result == .SUCCESS)
	}
	
	{
		i := u32(swapchain_image_index)
		info := vk.PresentInfoKHR{
			sType = .PRESENT_INFO_KHR,
			waitSemaphoreCount = 1,
			pWaitSemaphores = &ctx.present_semaphores[ctx.submission_index],
			swapchainCount = 1,
			pSwapchains = &ctx.swapchain,
			pImageIndices = &i,
		}
		result = vk.QueuePresentKHR(ctx.queues[0][ctx.submission_index], &info)
		assert(result == .SUCCESS)
	}

	ctx.submission_index = ctx.submission_index == 0 ? 1 : 0
}