#+ build windows
package app

import win32 "core:sys/windows"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"

// Based off https://github.com/odin-lang/examples/blob/master/directx/d3d11_minimal_sdl2/d3d11_in_odin.odin

D3D11_Context :: struct {
	base_device: ^d3d11.IDevice,
	base_device_context: ^d3d11.IDeviceContext,
	device: ^d3d11.IDevice,
	device_context: ^d3d11.IDeviceContext,
	dxgi_device: ^dxgi.IDevice,
	dxgi_adapter: ^dxgi.IAdapter,
	dxgi_factory: ^dxgi.IFactory2,
	swapchain: ^dxgi.ISwapChain1,
	render_target: ^d3d11.ITexture2D,
	render_target_view: ^d3d11.IRenderTargetView,
	depth_buffer: ^d3d11.ITexture2D,
	depth_buffer_view: ^d3d11.IDepthStencilView,
	viewport: d3d11.VIEWPORT,
	rasterizer_state: ^d3d11.IRasterizerState,
	sampler_state: ^d3d11.ISamplerState,
	depth_stencil_state: ^d3d11.IDepthStencilState,
}

// If you have already initialized any D3D11 objects, this procedure won't touch them.
d3d11_init :: proc(ctx: ^Context, d3d11_ctx: ^D3D11_Context = nil) -> (res: win32.HRESULT) {
	assert(!ctx.graphics_api_initialized, "Graphics API already initialized.")

	d3d11_ctx := d3d11_ctx
	if d3d11_ctx == nil {
		d3d11_ctx = new(D3D11_Context)
	}
	ctx.d3d11_ctx = d3d11_ctx

	feature_levels := [?]d3d11.FEATURE_LEVEL{._11_0} // TODO: Allow other versions.

	if d3d11_ctx.base_device == nil || d3d11_ctx.base_device_context == nil {
		flags := d3d11.CREATE_DEVICE_FLAGS{.BGRA_SUPPORT, .SINGLETHREADED}
		when ODIN_DEBUG {
			flags += {.DEBUG}
		}
		if res = d3d11.CreateDevice(nil, .HARDWARE, nil, {.BGRA_SUPPORT}, &feature_levels[0], len(feature_levels), d3d11.SDK_VERSION, &d3d11_ctx.base_device, nil, &d3d11_ctx.base_device_context); res != 0 { return }
	}
	
	if d3d11_ctx.device == nil {
		if res = d3d11_ctx.base_device->QueryInterface(d3d11.IDevice_UUID, (^rawptr)(&d3d11_ctx.device)); res != 0 { return }
	}

	if d3d11_ctx.device_context == nil {
		if res = d3d11_ctx.base_device_context->QueryInterface(d3d11.IDeviceContext_UUID, (^rawptr)(&d3d11_ctx.device_context)); res != 0 { return }
	}
	
	if d3d11_ctx.dxgi_device == nil {
		if res = d3d11_ctx.device->QueryInterface(dxgi.IDevice_UUID, (^rawptr)(&d3d11_ctx.dxgi_device)); res != 0 { return }
	}
	
	if d3d11_ctx.dxgi_adapter == nil {
		if res = d3d11_ctx.dxgi_device->GetAdapter(&d3d11_ctx.dxgi_adapter); res != 0 { return }		
	}

	if d3d11_ctx.dxgi_factory == nil {
		if res = d3d11_ctx.dxgi_adapter->GetParent(dxgi.IFactory2_UUID, (^rawptr)(&d3d11_ctx.dxgi_factory)); res != 0 { return }		
	}

	if d3d11_ctx.swapchain == nil {
		r := client_rect(ctx)

		swapchain_desc := dxgi.SWAP_CHAIN_DESC1{
			Width  = u32(r.w),
			Height = u32(r.h),
			Format = .B8G8R8A8_UNORM_SRGB,
			Stereo = false,
			SampleDesc = {
				Count   = 1,
				Quality = 0,
			},
			BufferUsage = {.RENDER_TARGET_OUTPUT},
			BufferCount = 2,
			Scaling     = .STRETCH,
			SwapEffect  = .DISCARD,
			AlphaMode   = .UNSPECIFIED,
			Flags       = {},
		}

		if res = d3d11_ctx.dxgi_factory->CreateSwapChainForHwnd(d3d11_ctx.device, ctx.win32_window, &swapchain_desc, nil, nil, &d3d11_ctx.swapchain); res != 0 { return }
	}

	if d3d11_ctx.render_target == nil {
		if res = d3d11_ctx.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, (^rawptr)(&d3d11_ctx.render_target)); res != 0 { return }		
	}

	if d3d11_ctx.render_target_view == nil {
		if res = d3d11_ctx.device->CreateRenderTargetView(d3d11_ctx.render_target, nil, &d3d11_ctx.render_target_view); res != 0 { return }		
	}

	depth_buffer_desc: d3d11.TEXTURE2D_DESC
	d3d11_ctx.render_target->GetDesc(&depth_buffer_desc)
	depth_buffer_desc.Format = .D24_UNORM_S8_UINT
	depth_buffer_desc.BindFlags = {.DEPTH_STENCIL}
	if d3d11_ctx.depth_buffer == nil {
		if res = d3d11_ctx.device->CreateTexture2D(&depth_buffer_desc, nil, &d3d11_ctx.depth_buffer); res != 0 { return }
	}

	if d3d11_ctx.depth_buffer_view == nil {
		if res = d3d11_ctx.device->CreateDepthStencilView(d3d11_ctx.depth_buffer, nil, &d3d11_ctx.depth_buffer_view); res != 0 { return }		
	}

	if d3d11_ctx.rasterizer_state == nil {
		rasterizer_desc := d3d11.RASTERIZER_DESC{
			FillMode = .SOLID,
			CullMode = .BACK,
		}

		if res = d3d11_ctx.device->CreateRasterizerState(&rasterizer_desc, &d3d11_ctx.rasterizer_state); res != 0 { return }
	}

	if d3d11_ctx.sampler_state == nil {
		sampler_desc := d3d11.SAMPLER_DESC {
			Filter         = .MIN_MAG_MIP_POINT,
			AddressU       = .WRAP,
			AddressV       = .WRAP,
			AddressW       = .WRAP,
			ComparisonFunc = .NEVER,
		}
		if res = d3d11_ctx.device->CreateSamplerState(&sampler_desc, &d3d11_ctx.sampler_state); res != 0 { return }
	}

	if d3d11_ctx.depth_stencil_state == nil {
		depth_stencil_desc := d3d11.DEPTH_STENCIL_DESC {
			DepthEnable    = true,
			DepthWriteMask = .ALL,
			DepthFunc      = .LESS,
		}

		if res = d3d11_ctx.device->CreateDepthStencilState(&depth_stencil_desc, &d3d11_ctx.depth_stencil_state); res != 0 { return }
	}

	if d3d11_ctx.viewport == {} {
		d3d11_ctx.viewport = d3d11.VIEWPORT{0, 0, f32(depth_buffer_desc.Width), f32(depth_buffer_desc.Height), 0, 1}
	}

	// assert(d3d11_ctx.base_device != nil)
	// assert(d3d11_ctx.base_device_context != nil)
	// assert(d3d11_ctx.device != nil)
	// assert(d3d11_ctx.device_context != nil)
	// assert(d3d11_ctx.dxgi_device != nil)
	// assert(d3d11_ctx.dxgi_adapter != nil)
	// assert(d3d11_ctx.dxgi_factory != nil)
	// assert(d3d11_ctx.swapchain != nil)
	// assert(d3d11_ctx.render_target != nil)
	// assert(d3d11_ctx.render_target_view != nil)
	// assert(d3d11_ctx.depth_buffer != nil)
	// assert(d3d11_ctx.depth_buffer_view != nil)
	// assert(d3d11_ctx.viewport != {})
	// assert(d3d11_ctx.rasterizer_state != nil)
	// assert(d3d11_ctx.sampler_state != nil)
	// assert(d3d11_ctx.depth_stencil_state != nil)

	// d3d11_ctx.dxgi_device->SetMaximumFrameLatency(1) TODO
	d3d11_ctx.dxgi_factory->MakeWindowAssociation(ctx.win32_window, {.NO_ALT_ENTER})

	ctx.d3d11_ctx = d3d11_ctx
	ctx.graphics_api = .D3D11
	ctx.graphics_api_initialized = true
	return
}

d3d11_swap_buffers :: proc(ctx: ^Context) {
	ctx.d3d11_ctx.swapchain->Present(1, {})
}