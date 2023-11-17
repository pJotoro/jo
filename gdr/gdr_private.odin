// +private
package gdr

import vk "vendor:vulkan"
import "../vkma"
import "core:runtime"
import "core:mem"
import "core:dynlib"
import "core:log"
import "core:slice"
import "core:bytes"
import "core:io"
import "core:image"
import "core:fmt"
import "../misc"

Context :: struct {
	// ----- instance -----
	instance: vk.Instance,
	instance_layers: [dynamic]cstring,
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
	surface_capabilities_fullscreen_exclusive: vk.SurfaceCapabilitiesFullScreenExclusiveEXT,
	// -------------------
	
	// ----- device -----
	device: vk.Device,
	device_extensions: [dynamic]cstring,
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

	// ----- depth stencil -----
	depth_stencil_format: vk.Format,
	depth_stencil_image: vk.Image,
	depth_stencil_image_view: vk.ImageView,
	// -------------------------

	// ----- execution -----
	queue_family_properties: []vk.QueueFamilyProperties,
	queues: [][]vk.Queue,
	dynamic_states: [dynamic]vk.DynamicState,

	fences: [2]vk.Fence,
	graphics_semaphores: [2]vk.Semaphore,
	present_semaphores: [2]vk.Semaphore,

	graphics_command_pool: vk.CommandPool,
	graphics_command_buffers: [2]vk.CommandBuffer,

	submission_index: int,
	// ---------------------

	// ----- misc -----
	library: dynlib.Library,
	deletion_queue: [dynamic]any,
	allocator: vkma.Allocator,
	// ----------------

	// ----- subject to change -----
	staging_buffer: vk.Buffer,
	vertex_buffer: vk.Buffer,
	pipeline_cache: vk.PipelineCache,
	vertex_shader_module: vk.ShaderModule,
	fragment_shader_module: vk.ShaderModule,
	descriptor_set_layout: vk.DescriptorSetLayout,
	pipeline_layout: vk.PipelineLayout,
	pipeline: vk.Pipeline,

	sprite_image: vk.Image,
	sprite_image_view: vk.ImageView,
	// -----------------------------
}
ctx: Context

delete_all :: proc() -> bool {
	using ctx

	for {
		deletion, ok := pop_safe(&deletion_queue);
		if !ok do break
		switch object in deletion {
			case dynlib.Library:
				dynlib.unload_library(object)
			case [dynamic]cstring:
				delete(object)
			case [dynamic]vk.DynamicState:
				delete(object)
			case []vk.QueueFamilyProperties:
				delete(object)
			case []vk.ImageView:
				delete(object)
			case [][]vk.Queue:
				delete(object)
			case []vk.Queue:
				delete(object)
			case vk.Instance:
				vk.DestroyInstance(object, nil)
			case vk.SurfaceKHR:
				vk.DestroySurfaceKHR(instance, object, nil)
			case vk.Device:
				vk.DestroyDevice(object, nil)
			case vk.SwapchainKHR:
				vk.DestroySwapchainKHR(device, object, nil)
			case vk.ImageView:
				vk.DestroyImageView(device, object, nil)
			case vk.Fence:
				vk.DestroyFence(device, object, nil)
			case vk.Semaphore:
				vk.DestroySemaphore(device, object, nil)
			case vk.CommandPool:
				vk.DestroyCommandPool(device, object, nil)
			case vk.ShaderModule:
				vk.DestroyShaderModule(device, object, nil)
			case vk.PipelineCache:
				vk.DestroyPipelineCache(device, object, nil)
			case vk.DescriptorSetLayout:
				vk.DestroyDescriptorSetLayout(device, object, nil)
			case vk.PipelineLayout:
				vk.DestroyPipelineLayout(device, object, nil)
			case vk.Pipeline:
				vk.DestroyPipeline(device, object, nil)
			case ^log.Logger:
				free(object)
			case:
				panic("Unknown object type in deletion queue!")
		}
	}

	delete(deletion_queue)

	return false
}

create_shader_module :: proc(filename: string, loc := #caller_location) -> (shader_module: vk.ShaderModule, result: vk.Result) {
	binary, ok := misc.read_entire_file_aligned(filename, align_of(u32), context.temp_allocator)
	assert(ok, "file does not exist", loc)

	info := vk.ShaderModuleCreateInfo{
		sType = .SHADER_MODULE_CREATE_INFO,
		codeSize = len(binary),
		pCode = (^u32)(raw_data(binary)),
	}
	result = vk.CreateShaderModule(ctx.device, &info, nil, &shader_module)
	return
}

create_buffer :: proc(size: vk.DeviceSize, usage: vk.BufferUsageFlags, memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags) -> (buffer: vk.Buffer, result: vk.Result) {
	return vkma.create_buffer(&ctx.allocator, size, usage, memory_properties_include, memory_properties_exclude)
}

create_image_raw :: proc(format: vk.Format, width, height, depth, mip_levels, array_layers: u32, samples: vk.SampleCountFlags, usage: vk.ImageUsageFlags, initial_layout: vk.ImageLayout, memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags) -> (image: vk.Image, result: vk.Result) {
	return vkma.create_image(&ctx.allocator, format, width, height, depth, mip_levels, array_layers, samples, usage, initial_layout, memory_properties_include, memory_properties_exclude)
}

create_image_from_image :: proc(img: ^image.Image, mip_levels, array_layers: u32, samples: vk.SampleCountFlags, usage: vk.ImageUsageFlags, initial_layout: vk.ImageLayout, memory_properties_include, memory_properties_exclude: vk.MemoryPropertyFlags) -> (image: vk.Image, result: vk.Result) {
	format: vk.Format
	switch {
		case img.channels == 3 && img.depth == 8:
			format = .R8G8B8_UINT
		case img.channels == 3 && img.depth == 16:
			format = .R16G16B16_UINT
		case img.channels == 4 && img.depth == 8:
			format = .R8G8B8A8_UINT
		case img.channels == 4 && img.depth == 16:
			format = .R16G16B16A16_UINT
		case:
			fmt.panicf("Unknown channels and depth combination! channels: %v, depth: %v\n", img.channels, img.depth)
	}
	return create_image_raw(format, u32(img.width), u32(img.height), 1, mip_levels, array_layers, samples, usage, initial_layout, memory_properties_include, memory_properties_exclude)
}

create_image :: proc{create_image_raw, create_image_from_image}

// https://github.com/baldurk/renderdoc/blob/v1.x/renderdoc/driver/vulkan/extension_support.md
render_doc_unsupported_extensions := [?]cstring{
	"VK_KHR_map_memory2",

    "VK_KHR_portability_subset",
    "VK_KHR_portability_enumeration",

    "VK_KHR_acceleration_structure",
    "VK_KHR_ray_tracing_pipeline",
    "VK_KHR_ray_tracing_position_fetch",
    "VK_KHR_ray_tracing_maintenance1",
    "VK_KHR_ray_query",
    "VK_KHR_deferred_host_operations",

    "VK_EXT_blend_operation_advanced",
    "VK_EXT_descriptor_buffer",
    "VK_EXT_device_address_binding_report",
    "VK_EXT_device_fault",
    "VK_EXT_device_memory_report",
    "VK_EXT_dynamic_rendering_unused_attachments",
    "VK_EXT_external_memory_acquire_unmodified",
    "VK_EXT_external_memory_host",
    "VK_EXT_extended_dynamic_state3",
    "VK_EXT_image_sliced_view_of_3d",
    "VK_EXT_image_compression_control",
    "VK_EXT_image_compression_control_swapchain",
    "VK_EXT_image_drm_format_modifier",
    "VK_EXT_legacy_dithering",
    "VK_EXT_mesh_shader",
    "VK_EXT_metal_objects",
    "VK_EXT_multi_draw",
    "VK_EXT_opacity_micromap",
    "VK_EXT_physical_device_drm",
    "VK_EXT_pipeline_library_group_handles",
    "VK_EXT_pipeline_protected_access",
    "VK_EXT_pipeline_properties",
    "VK_EXT_pipeline_robustness",
    "VK_EXT_rasterization_order_attachment_access",
    "VK_EXT_shader_module_identifier",
    "VK_EXT_shader_object",
    "VK_EXT_shader_tile_image",
    "VK_EXT_subpass_merge_feedback",

    "VK_ARM_rasterization_order_attachment_access",
    "VK_ARM_shader_core_builtins",
    "VK_ARM_shader_core_properties",

    "VK_AMD_pipeline_compiler_control",
    "VK_AMD_rasterization_order",
    "VK_AMD_shader_info",
    "VK_AMD_shader_core_properties2",
    "VK_AMD_shader_early_and_late_fragment_tests",

    "VK_FUCHSIA_external_memory",
    "VK_FUCHSIA_external_semaphore",
    "VK_FUCHSIA_buffer_collection",

    "VK_GOOGLE_surfaceless_query",

    "VK_HUAWEI_cluster_culling_shader",
    "VK_HUAWEI_subpass_shading",
    "VK_HUAWEI_invocation_mask",

    "VK_INTEL_shader_integer_functions2",
    "VK_INTEL_performance_query",

    "VK_NV_clip_space_w_scaling",
    "VK_NV_cooperative_matrix",
    "VK_NV_copy_memory_indirect",
    "VK_NV_corner_sampled_image",
    "VK_NV_coverage_reduction_mode",
    "VK_NV_dedicated_allocation_image_aliasing",
    "VK_NV_device_diagnostic_checkpoints",
    "VK_NV_device_diagnostics_config",
    "VK_NV_device_generated_commands",
    "VK_NV_displacement_micromap",
    "VK_NV_external_memory_rdma",
    "VK_NV_fill_rectangle",
    "VK_NV_fragment_coverage_to_color",
    "VK_NV_fragment_shading_rate_enums",
    "VK_NV_framebuffer_mixed_samples",
    "VK_NV_inherited_viewport_scissor",
    "VK_NV_linear_color_attachment",
    "VK_NV_low_latency",
    "VK_NV_memory_decompression",
    "VK_NV_mesh_shader",
    "VK_NV_optical_flow",
    "VK_NV_present_barrier",
    "VK_NV_ray_tracing_invocation_reorder",
    "VK_NV_ray_tracing_motion_blur",
    "VK_NV_representative_fragment_test",
    "VK_NV_scissor_exclusive",
    "VK_NV_shader_sm_builtins",
    "VK_NV_shading_rate_image",
    "VK_NV_viewport_swizzle",

    "VK_QCOM_multiview_per_view_render_areas",
    "VK_QCOM_fragment_density_map_offset",
    "VK_QCOM_image_processing",
    "VK_QCOM_multiview_per_view_viewports",
    "VK_QCOM_render_pass_shader_resolve",
    "VK_QCOM_render_pass_store_ops",
    "VK_QCOM_render_pass_transform",
    "VK_QCOM_rotated_copy_commands",
    "VK_QCOM_tile_properties",

    "VK_SEC_amigo_profiling",

    "VK_VALVE_descriptor_set_host_mapping",

    "VK_EXT_directfb_surface",
    "VK_FUCHSIA_imagepipe_surface",
    "VK_NN_vi_surface",
    "VK_NV_acquire_winrt_display",
    "VK_QNX_screen_surface",
    "VK_QNX_external_memory_screen_buffer",

    "VK_NV_ray_tracing",

    "VK_KHR_video_queue",
    "VK_KHR_video_decode_queue",
    "VK_KHR_video_decode_h264",
    "VK_KHR_video_decode_h265",

    "VK_LUNARG_direct_driver_loading",

    "VK_AMD_draw_indirect_count",
    "VK_KHR_video_encode_queue",
    "VK_EXT_video_encode_h264",
    "VK_EXT_video_encode_h265",
    "VK_EXT_video_decode_h264",
    "VK_EXT_video_decode_h265",
    "VK_MVK_ios_surface",
    "VK_NV_glsl_shader",
    "VK_NVX_binary_import",
    "VK_NVX_multiview_per_view_attributes",
    "VK_NVX_image_view_handle",
}