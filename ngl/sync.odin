package ngl

import gl "vendor:OpenGL"

fence_sync :: proc "contextless" () -> Sync {
	return gl.impl_FenceSync(gl.SYNC_GPU_COMMANDS_COMPLETE, 0)
}

is_sync :: proc "contextless" (sync: rawptr) -> bool {
	return gl.impl_IsSync(Sync(sync))
}

delete_sync :: proc "contextless" (sync: Sync) {
	gl.impl_DeleteSync(sync)
}

client_wait_sync :: proc "contextless" (sync: Sync, flush_commands: bool, timeout: u64) -> Client_Wait_Sync_Status {
	return Client_Wait_Sync_Status(gl.impl_ClientWaitSync(sync, flush_commands ? gl.SYNC_FLUSH_COMMANDS_BIT : 0, timeout))
}

wait_sync :: proc "contextless" (sync: Sync, timeout: u64) {
	gl.impl_WaitSync(sync, 0, timeout)
}