package gdr

import vk "vendor:vulkan"
import "core:dynlib"
import "core:thread"
import "../app"
import "core:strings"
import "core:sync"
import "core:log"
import "core:runtime"
import "core:slice"
import "core:fmt"
import gltf "vendor:cgltf"
import "core:image"
import "core:image/png"
import "core:image/tga"
import "core:image/qoi"
import "core:path/filepath"
import "core:os"
import "core:mem"

ASSETS :: #config(GDR_ASSETS, "")
SHADERS :: #config(GDR_SHADERS, "")

@(private)
Command_Pool :: struct {
	h: vk.CommandPool,
	primary_command_buffer_count: uint,
	primary_command_buffers: [dynamic]vk.CommandBuffer,
	secondary_command_buffer_count: uint,
	secondary_command_buffers: [dynamic]vk.CommandBuffer,
}

@(private)
Queue_Family :: struct {
	queues: []vk.Queue,
	command_pools_lock: sync.Atomic_Mutex,
	command_pools: [dynamic]Command_Pool,
}

// T - memory type index
// A - allocation index
// G - generation index
// B - allocation block index
// GGGGGGTTTTTAAAAABBBBBBBBBBBBBBBB
@(private)
Object_Allocation :: distinct u32
@(private)
Image_Allocation :: distinct Object_Allocation
@(private)
Buffer_Allocation :: distinct Object_Allocation

@(private)
Dedicated_Allocation :: struct {
	memory: vk.DeviceMemory,
	size: u64,
	object: vk.NonDispatchableHandle,
}

@(private)
Undedicated_Allocation :: struct {
	memory: vk.DeviceMemory,
	size: u64,
	blocks: [dynamic]Allocation_Block,
}

@(private)
Allocation :: union {
	Dedicated_Allocation,
	Undedicated_Allocation,
}

@(private)
Allocation_Block :: struct {
	object: vk.NonDispatchableHandle, // zero if freed
	offset: u64,
	size: u64,
}

@(private)
Asset_Data :: union {
	^gltf.data,
	^image.Image,
}

@(private)
Asset :: struct {
	data: Asset_Data,
	// TODO
}

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
	allocations: [][dynamic]Allocation, // [len(memory_types)][dynamic]
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
	queue_families: []Queue_Family,
	dynamic_states: [dynamic]vk.DynamicState,
	// ---------------------

	// ----- depth stencil -----
	depth_stencil_format: vk.Format,
	depth_stencil_image: vk.Image,
	depth_stencil_image_view: vk.ImageView,
	// -------------------------

	// ----- synchronization/concurrency -----
	rendering_fence: vk.Fence,
	// ---------------------------

	// ----- assets -----
	assets: map[string]Asset,
	gltf_options: gltf.options,
	// ------------------

	// ----- subject to change -----
	shaders: map[string]vk.ShaderModule,
	pipeline: vk.Pipeline,
	pipeline_layout: vk.PipelineLayout,
	descriptor_set_layout: vk.DescriptorSetLayout,
	staging_buffer: vk.Buffer,
	staging_buffer_memory: vk.DeviceMemory,
	vertex_buffer: vk.Buffer,
	copy_staging_buffer: bool,

	graphics_queue_index: int,
	transfer_queue_index: int,
	present_queue_index: int,
	// ----------------------------	
}
@(private)
ctx: Context

// TODO(pJotoro): Figure out a way to destory Vulkan objects in a way that's both safe and efficient.

init :: proc() -> bool {
	using ctx

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
			assert(vk.EnumerateInstanceExtensionProperties(nil, &count, nil) == .SUCCESS)
			instance_extension_properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
			assert(vk.EnumerateInstanceExtensionProperties(nil, &count, raw_data(instance_extension_properties)) == .SUCCESS)
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
		assert(vk.CreateInstance(&info, nil, &instance) == .SUCCESS)
		vk.load_proc_addresses(instance)
	}

	{
		assert(create_surface() == .SUCCESS)
	}

	device_extensions = make([dynamic]cstring, 0, 128)
	{
		physical_device_count: u32 = ---
		assert(vk.EnumeratePhysicalDevices(instance, &physical_device_count, nil) == .SUCCESS)
		physical_devices := make([]vk.PhysicalDevice, physical_device_count, context.temp_allocator)
		assert(vk.EnumeratePhysicalDevices(instance, &physical_device_count, raw_data(physical_devices)) == .SUCCESS)

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
				assert(vk.EnumerateDeviceExtensionProperties(physical_device, instance_extension, &count, nil) == .SUCCESS)
				properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
				assert(vk.EnumerateDeviceExtensionProperties(physical_device, instance_extension, &count, raw_data(properties)) == .SUCCESS)
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
			assert(vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, nil) == .SUCCESS)
			properties := make([]vk.ExtensionProperties, count, context.temp_allocator)
			assert(vk.EnumerateDeviceExtensionProperties(physical_device, nil, &count, raw_data(properties)) == .SUCCESS)
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
		assert(vk.GetPhysicalDeviceSurfacePresentModes2EXT(physical_device, &info, &count, nil) == .SUCCESS)
		present_modes = make([]vk.PresentModeKHR, count, context.temp_allocator)
		assert(vk.GetPhysicalDeviceSurfacePresentModes2EXT(physical_device, &info, &count, raw_data(present_modes)) == .SUCCESS)
	} else {
		count: u32 = ---
		assert(vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, nil) == .SUCCESS)
		present_modes = make([]vk.PresentModeKHR, count, context.temp_allocator)
		assert(vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, raw_data(present_modes)) == .SUCCESS)
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

		assert(vk.GetPhysicalDeviceSurfaceCapabilities2KHR(physical_device, &info, &surface_capabilities_2) == .SUCCESS)

		count: u32 = ---
		assert(vk.GetPhysicalDeviceSurfaceFormats2KHR(physical_device, &info, &count, nil) == .SUCCESS)
		surface_formats_2 = make([]vk.SurfaceFormat2KHR, count, context.temp_allocator)
		for &f in surface_formats_2 do f.sType = .SURFACE_FORMAT_2_KHR
		assert(vk.GetPhysicalDeviceSurfaceFormats2KHR(physical_device, &info, &count, raw_data(surface_formats_2)) == .SUCCESS)

		surface_capabilities = surface_capabilities_2.surfaceCapabilities
	} else {
		assert(vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &surface_capabilities) == .SUCCESS)
		count: u32 = ---
		assert(vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, nil) == .SUCCESS)
		surface_formats_1 = make([]vk.SurfaceFormatKHR, count, context.temp_allocator)
		assert(vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, raw_data(surface_formats_1)) == .SUCCESS)
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
			assert(vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, u32(i), surface, &supported) == .SUCCESS)
			if supported do append(&present_queue_family_indices, i)
		}
		assert(len(present_queue_family_indices) != 0)
	}

	// TODO
	graphics_queue_index = 0
	transfer_queue_index = 1
	present_queue_index = 2

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
		assert(vk.CreateDevice(physical_device, &info, nil, &device) == .SUCCESS)
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
			presentMode = slice.contains(present_modes, vk.PresentModeKHR.MAILBOX) ? .MAILBOX : .FIFO,
			imageExtent = {width = surface_capabilities.currentExtent.width, height = surface_capabilities.currentExtent.height},
			imageUsage = {.COLOR_ATTACHMENT, .TRANSFER_SRC},
			preTransform = surface_capabilities.currentTransform,
			compositeAlpha = {.OPAQUE},
			clipped = true,
			imageArrayLayers = 1,
		}
		extent = swapchain_info.imageExtent

		set_next_chain(device_extensions[:], &swapchain_info, Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &fullscreen_info}, Next_Chain_Entry{"VK_EXT_full_screen_exclusive", &platform_fullscreen_info})
		assert(vk.CreateSwapchainKHR(device, &swapchain_info, nil, &swapchain) == .SUCCESS)

		swapchain_image_count: u32 = ---
		assert(vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, nil) == .SUCCESS)
		swapchain_images = make([]vk.Image, swapchain_image_count)
		assert(vk.GetSwapchainImagesKHR(device, swapchain, &swapchain_image_count, raw_data(swapchain_images)) == .SUCCESS)

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
			assert(vk.CreateImageView(device, &info, nil, &s) == .SUCCESS)
		}
	}

	{
		queue_families = make([]Queue_Family, len(queue_family_properties))
		for &queue_family, i in queue_families {
			queue_family.queues = make([]vk.Queue, queue_family_properties[i].queueCount)
			for &queue, j in queue_family.queues {
				vk.GetDeviceQueue(device, u32(i), u32(j), &queue)
			}
		}
	}

	{
		vk.GetPhysicalDeviceMemoryProperties(physical_device, &_memory_properties)
		memory_types = _memory_properties.memoryTypes[:int(_memory_properties.memoryTypeCount)]
		memory_heaps = _memory_properties.memoryHeaps[:int(_memory_properties.memoryHeapCount)]
		allocations = make([][dynamic]Allocation, len(memory_types))
		for &allocation_list in allocations {
			allocation_list = make([dynamic]Allocation)
		}
	}

	{
		depth_stencil_formats := [?]vk.Format{
			// NOTE(pJotoro): In order of usefulness
			.D24_UNORM_S8_UINT,
			.D16_UNORM_S8_UINT,
			.D32_SFLOAT_S8_UINT,
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
		info := vk.ImageCreateInfo{
			sType = .IMAGE_CREATE_INFO,
			imageType = .D2,
			format = depth_stencil_format,
			extent = {width = extent.width, height = extent.height, depth = 1},
			arrayLayers = 1,
			mipLevels = 1,
			samples = {._1},
			usage = {.DEPTH_STENCIL_ATTACHMENT},
		}
		assert(vk.CreateImage(device, &info, nil, &depth_stencil_image) == .SUCCESS)
	}

	{
		memory_requirements_info := vk.ImageMemoryRequirementsInfo2{
			sType = .IMAGE_MEMORY_REQUIREMENTS_INFO_2,
			image = depth_stencil_image,
		}
		memory_dedicated_requirements := vk.MemoryDedicatedRequirements{
			sType = .MEMORY_DEDICATED_REQUIREMENTS,
		}
		memory_requirements := vk.MemoryRequirements2{
			sType = .MEMORY_REQUIREMENTS_2,
			pNext = &memory_dedicated_requirements,
		}
		vk.GetImageMemoryRequirements2(device, &memory_requirements_info, &memory_requirements)

		dedicated_allocate_info := vk.MemoryDedicatedAllocateInfo{
			sType = .MEMORY_DEDICATED_ALLOCATE_INFO,
			image = depth_stencil_image,
		}

		memory_type_index := find_memory_type(memory_requirements.memoryRequirements.memoryTypeBits)

		allocation_size := memory_requirements.memoryRequirements.size

		allocate_info := vk.MemoryAllocateInfo{
			sType = .MEMORY_ALLOCATE_INFO,
			allocationSize = allocation_size,
			memoryTypeIndex = u32(memory_type_index),
		}
		
		if memory_dedicated_requirements.prefersDedicatedAllocation || memory_dedicated_requirements.requiresDedicatedAllocation {
			allocate_info.pNext = &dedicated_allocate_info
		} else {
			allocation_size *= 8
			allocate_info.allocationSize = allocation_size
		}

		memory: vk.DeviceMemory = ---
		assert(vk.AllocateMemory(device, &allocate_info, nil, &memory) == .SUCCESS)
		assert(vk.BindImageMemory(device, depth_stencil_image, memory, 0) == .SUCCESS)
		if memory_dedicated_requirements.prefersDedicatedAllocation || memory_dedicated_requirements.requiresDedicatedAllocation {
			allocation := Dedicated_Allocation{
				memory = memory,
				size = u64(allocate_info.allocationSize),
				object = vk.NonDispatchableHandle(depth_stencil_image),
			}
			append(&allocations[memory_type_index], allocation)
		} else {
			allocation := Undedicated_Allocation{
				memory = memory,
				size = u64(allocation_size),
				blocks = make([dynamic]Allocation_Block),
			}
			append(&allocation.blocks, Allocation_Block{vk.NonDispatchableHandle(depth_stencil_image), 0, u64(allocation_size)})
			append(&allocations[memory_type_index], allocation)
		}
	}

	{
		info := vk.BufferCreateInfo{
			sType = .BUFFER_CREATE_INFO,
			size = size_of(vertices),
			usage = {.TRANSFER_SRC},
		}
		assert(vk.CreateBuffer(device, &info, nil, &staging_buffer) == .SUCCESS)
	}

	{
		info := vk.BufferMemoryRequirementsInfo2{
			sType = .BUFFER_MEMORY_REQUIREMENTS_INFO_2,
			buffer = staging_buffer,
		}
		memory_dedicated_requirements := vk.MemoryDedicatedRequirements{
			sType = .MEMORY_DEDICATED_REQUIREMENTS,
		}
		memory_requirements := vk.MemoryRequirements2{
			sType = .MEMORY_REQUIREMENTS_2,
			pNext = &memory_dedicated_requirements,
		}
		vk.GetBufferMemoryRequirements2(device, &info, &memory_requirements)

		dedicated_allocate_info := vk.MemoryDedicatedAllocateInfo{
			sType = .MEMORY_DEDICATED_ALLOCATE_INFO,
			buffer = staging_buffer,
		}

		memory_type_index, ok := find_memory_type(memory_requirements.memoryRequirements.memoryTypeBits, vk.MemoryPropertyFlags{.HOST_VISIBLE})
		assert(ok)

		allocation_size := memory_requirements.memoryRequirements.size

		allocate_info := vk.MemoryAllocateInfo{
			sType = .MEMORY_ALLOCATE_INFO,
			allocationSize = allocation_size,
			memoryTypeIndex = u32(memory_type_index),
		}

		if memory_dedicated_requirements.prefersDedicatedAllocation || memory_dedicated_requirements.requiresDedicatedAllocation {
			allocate_info.pNext = &dedicated_allocate_info
		} else {
			allocation_size *= 8
			allocate_info.allocationSize = allocation_size
		}

		memory: vk.DeviceMemory = ---
		assert(vk.AllocateMemory(device, &allocate_info, nil, &memory) == .SUCCESS)
		assert(vk.BindBufferMemory(device, staging_buffer, memory, 0) == .SUCCESS)
		if memory_dedicated_requirements.prefersDedicatedAllocation || memory_dedicated_requirements.requiresDedicatedAllocation {
			allocation := Dedicated_Allocation{
				memory = memory,
				size = u64(allocate_info.allocationSize),
				object = vk.NonDispatchableHandle(staging_buffer),
			}
			append(&allocations[memory_type_index], allocation)
		} else {
			allocation := Undedicated_Allocation{
				memory = memory,
				size = u64(allocation_size),
				blocks = make([dynamic]Allocation_Block),
			}
			append(&allocation.blocks, Allocation_Block{vk.NonDispatchableHandle(staging_buffer), 0, u64(allocation_size)})
			append(&allocations[memory_type_index], allocation)
		}

		staging_buffer_memory = memory
	}

	{
		info := vk.BufferCreateInfo{
			sType = .BUFFER_CREATE_INFO,
			size = size_of(vertices),
			usage = {.TRANSFER_DST, .VERTEX_BUFFER},
		}
		assert(vk.CreateBuffer(device, &info, nil, &vertex_buffer) == .SUCCESS)
	}

	{
		info := vk.BufferMemoryRequirementsInfo2{
			sType = .BUFFER_MEMORY_REQUIREMENTS_INFO_2,
			buffer = vertex_buffer,
		}
		memory_dedicated_requirements := vk.MemoryDedicatedRequirements{
			sType = .MEMORY_DEDICATED_REQUIREMENTS,
		}
		memory_requirements := vk.MemoryRequirements2{
			sType = .MEMORY_REQUIREMENTS_2,
			pNext = &memory_dedicated_requirements,
		}
		vk.GetBufferMemoryRequirements2(device, &info, &memory_requirements)

		dedicated_allocate_info := vk.MemoryDedicatedAllocateInfo{
			sType = .MEMORY_DEDICATED_ALLOCATE_INFO,
			buffer = vertex_buffer,
		}

		memory_type_index, ok := find_memory_type(memory_requirements.memoryRequirements.memoryTypeBits, vk.MemoryPropertyFlags{.DEVICE_LOCAL}, vk.MemoryPropertyFlags{.HOST_VISIBLE})
		assert(ok)

		allocation_size := memory_requirements.memoryRequirements.size

		allocate_info := vk.MemoryAllocateInfo{
			sType = .MEMORY_ALLOCATE_INFO,
			allocationSize = allocation_size,
			memoryTypeIndex = u32(memory_type_index),
		}

		if memory_dedicated_requirements.prefersDedicatedAllocation || memory_dedicated_requirements.requiresDedicatedAllocation {
			allocate_info.pNext = &dedicated_allocate_info
		} else {
			allocation_size *= 8
			allocate_info.allocationSize = allocation_size
		}

		memory: vk.DeviceMemory = ---
		assert(vk.AllocateMemory(device, &allocate_info, nil, &memory) == .SUCCESS)
		assert(vk.BindBufferMemory(device, vertex_buffer, memory, 0) == .SUCCESS)
		if memory_dedicated_requirements.prefersDedicatedAllocation || memory_dedicated_requirements.requiresDedicatedAllocation {
			allocation := Dedicated_Allocation{
				memory = memory,
				size = u64(allocate_info.allocationSize),
				object = vk.NonDispatchableHandle(vertex_buffer),
			}
			append(&allocations[memory_type_index], allocation)
		} else {
			allocation := Undedicated_Allocation{
				memory = memory,
				size = u64(allocation_size),
				blocks = make([dynamic]Allocation_Block),
			}
			append(&allocation.blocks, Allocation_Block{vk.NonDispatchableHandle(vertex_buffer), 0, u64(allocation_size)})
			append(&allocations[memory_type_index], allocation)
		}
	}

	when SHADERS != "" {
		shader_pattern := strings.concatenate({SHADERS, "/*.spv"}, context.temp_allocator)
		shader_matches, filepath_err := filepath.glob(shader_pattern)
		assert(filepath_err == .None)
		for match in shader_matches {
			data, ok := read_entire_file_aligned(match, align_of(u32), context.temp_allocator)
			assert(ok)
			info := vk.ShaderModuleCreateInfo{
				sType = .SHADER_MODULE_CREATE_INFO,
				codeSize = len(data),
				pCode = (^u32)(raw_data(data)),
			}
			shader: vk.ShaderModule = ---
			assert(vk.CreateShaderModule(device, &info, nil, &shader) == .SUCCESS)
			shaders[match] = shader
		}
	}

	allocator := new(mem.Allocator)
	allocator^ = context.allocator

	gltf_alloc_func :: proc "c" (user: rawptr, size: uint) -> rawptr {
		allocator := (^mem.Allocator)(user)
		context = runtime.default_context()
		context.allocator = allocator^
		res, _ := mem.alloc(int(size))
		return res
	}

	gltf_free_func :: proc "c" (user: rawptr, ptr: rawptr) {
		allocator := (^mem.Allocator)(user)
		context = runtime.default_context()
		context.allocator = allocator^
		mem.free(ptr)
	}

	gltf_options.memory.alloc_func = gltf_alloc_func
	gltf_options.memory.free_func = gltf_free_func
	gltf_options.memory.user_data = allocator

	match_assets :: proc(file_extension: string) -> []string {
		using ctx
		pattern := strings.concatenate({ASSETS, "/*.", file_extension}, context.temp_allocator)
		matches, err := filepath.glob(pattern)
		assert(err == .None, "invalid asset folder")
		return matches
	}

	assets = make(map[string]Asset)

	when ASSETS != "" {
		gltf_matches_binary := match_assets("glb")
		for match in gltf_matches_binary {
			file, ok := os.read_entire_file(match, context.temp_allocator)
			assert(ok)
			options := gltf_options
			options.type = .glb
			data, result := gltf.parse(options, raw_data(file), len(file))
			assert(result == .success)
			assets[match] = Asset{data = data}
		}
		gltf_matches_json := match_assets("gltf")
		for match in gltf_matches_json {
			file, ok := os.read_entire_file(match, context.temp_allocator)
			assert(ok)
			options := gltf_options
			options.type = .gltf
			data, result := gltf.parse(options, raw_data(file), len(file))
			assert(result == .success)
			assets[match] = Asset{data = data}
		}

		match_images :: proc(file_extension: string) {
			using ctx
			matches := match_assets(file_extension)
			for match in matches {
				file, ok := os.read_entire_file(match, context.temp_allocator)
				assert(ok)
				image, error := image.load(match)
				assert(error == nil)
				assets[match] = Asset{data = image}
			}
		}

		match_images("png")
		match_images("qoi")
		match_images("tga")
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

	{
		info := vk.DescriptorSetLayoutCreateInfo{
			sType = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
			//flags = {.DESCRIPTOR_BUFFER},
		}
		assert(vk.CreateDescriptorSetLayout(device, &info, nil, &descriptor_set_layout) == .SUCCESS)
	}

	{
		info := vk.PipelineLayoutCreateInfo{
			sType = .PIPELINE_LAYOUT_CREATE_INFO,
			setLayoutCount = 1,
			pSetLayouts = &descriptor_set_layout,
		}
		assert(vk.CreatePipelineLayout(device, &info, nil, &pipeline_layout) == .SUCCESS)
	}

	{
		stages := [?]vk.PipelineShaderStageCreateInfo{
			{
				sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
				stage = {.VERTEX},
				module = shaders["C:\\Users\\jonas\\Desktop\\jo\\vert.spv"],
				pName = "main",
			},
			{
				sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
				stage = {.FRAGMENT},
				module = shaders["C:\\Users\\jonas\\Desktop\\jo\\frag.spv"],
				pName = "main",
			},
		}
		vertex_input_state := vk.PipelineVertexInputStateCreateInfo{
			sType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
		}
		input_assembly_state := vk.PipelineInputAssemblyStateCreateInfo{
			sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
			topology = .TRIANGLE_LIST, // NOTE(pJotoro): This won't actually be used for anything, but it makes the validation layer happy.
		}
		viewport_state := vk.PipelineViewportStateCreateInfo{
			sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
		}
		rasterization_state := vk.PipelineRasterizationStateCreateInfo{
			sType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
		}
		multisample_state := vk.PipelineMultisampleStateCreateInfo{
			sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
			rasterizationSamples = {._1}, // NOTE(pJotoro): This won't actually be used for anything, but it makes the validation layer happy.
		}
		//blend_state := vk.PipelineColorBlendStateCreateInfo{
		//	sType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
		//}
		dynamic_state := vk.PipelineDynamicStateCreateInfo{
			sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
			dynamicStateCount = u32(len(dynamic_states)),
			pDynamicStates = raw_data(dynamic_states),
		}
		//rendering_info := vk.PipelineRenderingCreateInfo{
		//	sType = .PIPELINE_RENDERING_CREATE_INFO,
		//	colorAttachmentCount = 1,
		//	pColorAttachmentFormats = &swapchain_format,
		//}
		info := vk.GraphicsPipelineCreateInfo{
			sType = .GRAPHICS_PIPELINE_CREATE_INFO,
			//pNext = &rendering_info,
			stageCount = u32(len(stages)),
			pStages = raw_data(&stages),
			pVertexInputState = &vertex_input_state,
			pInputAssemblyState = &input_assembly_state,
			pViewportState = &viewport_state,
			pRasterizationState = &rasterization_state,
			pMultisampleState = &multisample_state,
			//pColorBlendState = &blend_state,
			pDynamicState = &dynamic_state,
			layout = pipeline_layout,

		}
		assert(vk.CreateGraphicsPipelines(device, 0, 1, &info, nil, &pipeline) == .SUCCESS)
	}

	{
		info := vk.FenceCreateInfo{
			sType = .FENCE_CREATE_INFO,
		}
		assert(vk.CreateFence(device, &info, nil, &rendering_fence) == .SUCCESS)
	}

	return true
}

@(private)
find_memory_type_any :: proc "contextless" (memory_types: u32) -> (memory_type_index: int) {
	for memory_type_index = 0; memory_type_index < len(ctx.memory_types); memory_type_index += 1 {
		memory_type := u32(1 << u32(memory_type_index))
		if memory_types & memory_type != 0 do return
	}
	return // NOTE(pJotoro): This can't happen!
}

@(private)
find_memory_type_properties_include :: proc "contextless" (memory_types: u32, memory_properties_include: vk.MemoryPropertyFlags) -> (memory_type_index: int, ok: bool) {
	for memory_type_index = 0; memory_type_index < len(ctx.memory_types); memory_type_index += 1 {
		memory_type := u32(1 << u32(memory_type_index))
		if (memory_types & memory_type != 0) && (memory_properties_include <= ctx.memory_types[memory_type_index].propertyFlags) {
			ok = true
			return
		}
	}
	return
}

@(private)
find_memory_type_properties_include_exclude :: proc "contextless" (memory_types: u32, memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags) -> (memory_type_index: int, ok: bool) {
	for memory_type_index = 0; memory_type_index < len(ctx.memory_types); memory_type_index += 1 {
		memory_type := u32(1 << u32(memory_type_index))
		if (memory_types & memory_type != 0) && (memory_properties_include <= ctx.memory_types[memory_type_index].propertyFlags) && !(memory_properties_exclude <= ctx.memory_types[memory_type_index].propertyFlags) {
			ok = true
			return
		}
	}
	return
}

@(private)
find_memory_type :: proc{find_memory_type_any, find_memory_type_properties_include, find_memory_type_properties_include_exclude}

vertices: [3]Vertex
Vertex :: struct {
	position: [2]f32,
	color: [3]f32,
}

update :: proc(user_vertices: [3]Vertex) {
	if vertices != user_vertices {
		vertices = user_vertices
		ctx.copy_staging_buffer = true
		mapped_memory: rawptr = ---
		assert(vk.MapMemory(ctx.device, ctx.staging_buffer_memory, 0, size_of(vertices), {}, &mapped_memory) == .SUCCESS)
		mem.copy(mapped_memory, &vertices, size_of(vertices))
		vk.UnmapMemory(ctx.device, ctx.staging_buffer_memory)
	}

	command_pool := pop_command_pool(0)
	defer append(&ctx.queue_families[0].command_pools, command_pool)
	command_buffer := pop_primary_command_buffer(&command_pool)
	defer append(&command_pool.primary_command_buffers, command_buffer)

	swapchain_image_index: u32 = ---
	{
		assert(vk.AcquireNextImageKHR(ctx.device, ctx.swapchain, max(u64), 0, ctx.rendering_fence, &swapchain_image_index) == .SUCCESS)
	}
	{
		info := vk.CommandBufferBeginInfo{
			sType = .COMMAND_BUFFER_BEGIN_INFO,
			flags = {.ONE_TIME_SUBMIT},
		}
		assert(vk.BeginCommandBuffer(command_buffer, &info) == .SUCCESS)
	}
	{
		assert(vk.WaitForFences(ctx.device, 1, &ctx.rendering_fence, true, max(u64)) == .SUCCESS)
		assert(vk.ResetFences(ctx.device, 1, &ctx.rendering_fence) == .SUCCESS)
		ctx.swapchain_image_index = int(swapchain_image_index)
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
		buffer_barrier := vk.BufferMemoryBarrier2{
			sType = .BUFFER_MEMORY_BARRIER_2,
			srcStageMask = {.TRANSFER},
			srcAccessMask = {.TRANSFER_WRITE},
			dstStageMask = {.VERTEX_INPUT},
			dstAccessMask = {.VERTEX_ATTRIBUTE_READ},
			buffer = ctx.vertex_buffer,
			size = size_of(vertices),
		}
		info := vk.DependencyInfo{
			sType = .DEPENDENCY_INFO,
			imageMemoryBarrierCount = 1,
			pImageMemoryBarriers = &image_barrier,
			bufferMemoryBarrierCount = ctx.copy_staging_buffer ? 1 : 0,
			pBufferMemoryBarriers = ctx.copy_staging_buffer ? &buffer_barrier : nil, 
		}
		vk.CmdPipelineBarrier2(command_buffer, &info)
	}
	if ctx.copy_staging_buffer {
		defer ctx.copy_staging_buffer = false
		info := vk.BufferCopy{
			size = size_of(vertices),
		}
		vk.CmdCopyBuffer(command_buffer, ctx.staging_buffer, ctx.vertex_buffer, 1, &info)
	}
	{
		color_attachment := vk.RenderingAttachmentInfo{
			sType = .RENDERING_ATTACHMENT_INFO,
			imageView = ctx.swapchain_image_views[ctx.swapchain_image_index],
			imageLayout = .COLOR_ATTACHMENT_OPTIMAL,
			loadOp = .CLEAR,
			storeOp = .STORE,
			clearValue = {color = {float32 = {0.2, 0.3, 1, 1}}},
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
			//flags = {.CONTENTS_SECONDARY_COMMAND_BUFFERS},
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
	vk.CmdSetRasterizationSamplesEXT(command_buffer, {._1})
	viewport := vk.Viewport{0, 0, f32(ctx.extent.width), f32(ctx.extent.height), 0, 1}
	vk.CmdSetViewportWithCount(command_buffer, 1, &viewport)
	scissor := vk.Rect2D{extent = ctx.extent}
	vk.CmdSetScissorWithCount(command_buffer, 1, &scissor)
	vk.CmdBindPipeline(command_buffer, .GRAPHICS, ctx.pipeline)

	bindings := [?]vk.VertexInputBindingDescription2EXT{
		{
			sType = .VERTEX_INPUT_BINDING_DESCRIPTION_2_EXT,
			binding = 0,
			stride = size_of(Vertex),
			inputRate = .VERTEX,
			divisor = 1,
		},
	}
	attributes := [?]vk.VertexInputAttributeDescription2EXT{
		{
			sType = .VERTEX_INPUT_ATTRIBUTE_DESCRIPTION_2_EXT,
			location = 0,
			binding = 0,
			format = .R32G32_SFLOAT,
			offset = 0,
		},
		{
			sType = .VERTEX_INPUT_ATTRIBUTE_DESCRIPTION_2_EXT,
			location = 1,
			binding = 0,
			format = .R32G32B32_SFLOAT,
			offset = size_of(f32) * 2,
		},
	}
	vk.CmdSetVertexInputEXT(command_buffer, u32(len(bindings)), raw_data(&bindings), u32(len(attributes)), raw_data(&attributes))

	offset := vk.DeviceSize(0)
	vk.CmdBindVertexBuffers(command_buffer, 0, 1, &ctx.vertex_buffer, &offset)

	vk.CmdDraw(command_buffer, 3, 1, 0, 0)

	vk.CmdEndRendering(command_buffer)
	assert(vk.EndCommandBuffer(command_buffer) == .SUCCESS)

	{
		command_buffer_info := vk.CommandBufferSubmitInfo{
			sType = .COMMAND_BUFFER_SUBMIT_INFO,
			commandBuffer = command_buffer,
		}
		info := vk.SubmitInfo2{
			sType = .SUBMIT_INFO_2,
			commandBufferInfoCount = 1,
			pCommandBufferInfos = &command_buffer_info,
		}
		assert(vk.QueueSubmit2(ctx.queue_families[0].queues[ctx.graphics_queue_index], 1, &info, ctx.rendering_fence) == .SUCCESS)
		assert(vk.WaitForFences(ctx.device, 1, &ctx.rendering_fence, true, max(u64)) == .SUCCESS)
		assert(vk.ResetFences(ctx.device, 1, &ctx.rendering_fence) == .SUCCESS)
	}
	
	{
		i := u32(swapchain_image_index)
		result: vk.Result = ---
		info := vk.PresentInfoKHR{
			sType = .PRESENT_INFO_KHR,
			swapchainCount = 1,
			pSwapchains = &ctx.swapchain,
			pImageIndices = &i,
			pResults = &result,
		}
		assert(vk.QueuePresentKHR(ctx.queue_families[0].queues[ctx.present_queue_index], &info) == .SUCCESS)
		assert(result == .SUCCESS)
	}
}

pop_command_pool :: proc(queue_family_index: int) -> Command_Pool {
	using ctx
	command_pool, ok := pop_safe(&ctx.queue_families[queue_family_index].command_pools)
	if ok do return command_pool
	vk_command_pool: vk.CommandPool = ---
	info := vk.CommandPoolCreateInfo{
		sType = .COMMAND_POOL_CREATE_INFO,
		flags = {.TRANSIENT, .RESET_COMMAND_BUFFER},
		queueFamilyIndex = u32(queue_family_index),
	}
	assert(vk.CreateCommandPool(device, &info, nil, &vk_command_pool) == .SUCCESS)
	command_pool = Command_Pool{
		h = vk_command_pool,
		primary_command_buffers = make([dynamic]vk.CommandBuffer),
		secondary_command_buffers = make([dynamic]vk.CommandBuffer),
	}
	return command_pool
}

pop_primary_command_buffer :: proc(command_pool: ^Command_Pool) -> vk.CommandBuffer {
	command_buffer, ok := pop_safe(&command_pool.primary_command_buffers)
	if ok do return command_buffer
	old_len := len(command_pool.primary_command_buffers)
	if old_len == 0 {
		command_pool.primary_command_buffer_count = 1
		command_pool.primary_command_buffers = make([dynamic]vk.CommandBuffer, 1)
	} else {
		command_pool.primary_command_buffer_count *= 2
		resize(&command_pool.primary_command_buffers, int(command_pool.primary_command_buffer_count))
	}
	
	info := vk.CommandBufferAllocateInfo{
		sType = .COMMAND_BUFFER_ALLOCATE_INFO,
		commandPool = command_pool.h,
		level = .PRIMARY,
		commandBufferCount = u32(command_pool.primary_command_buffer_count - uint(old_len)),
	}

	assert(vk.AllocateCommandBuffers(ctx.device, &info, &command_pool.primary_command_buffers[old_len]) == .SUCCESS)
	return pop(&command_pool.primary_command_buffers)
}

pop_secondary_command_buffer :: proc(command_pool: ^Command_Pool) -> vk.CommandBuffer {
	command_buffer, ok := pop_safe(&command_pool.secondary_command_buffers)
	if ok do return command_buffer

	old_len := len(command_pool.secondary_command_buffers)
	if old_len == 0 {
		command_pool.secondary_command_buffer_count = 1
		command_pool.secondary_command_buffers = make([dynamic]vk.CommandBuffer, 1)
	} else {
		command_pool.secondary_command_buffer_count *= 2
		resize(&command_pool.secondary_command_buffers, int(command_pool.secondary_command_buffer_count))
	}

	info := vk.CommandBufferAllocateInfo{
		sType = .COMMAND_BUFFER_ALLOCATE_INFO,
		commandPool = command_pool.h,
		level = .SECONDARY,
		commandBufferCount = u32(command_pool.secondary_command_buffer_count - uint(old_len)),
	}
	assert(vk.AllocateCommandBuffers(ctx.device, &info, &command_pool.secondary_command_buffers[old_len]) == .SUCCESS)
	return pop(&command_pool.secondary_command_buffers)
}