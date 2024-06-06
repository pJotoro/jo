package ngl

import gl "vendor:OpenGL"

// Modified from: https://github.com/mtarik34b/opengl46-enum-wrapper/blob/master/OpenGL/enums_synchronization.odin

/* Sync Objects and Fences [4.1] */

/* sync FenceSync(enum condition, bitfield flags); */
Fence_Sync_Condition :: enum u32 {
	Sync_GPU_Commands_Complete = gl.SYNC_GPU_COMMANDS_COMPLETE,
}

Fence_Sync_Flag :: enum u32 {}

Fence_Sync_Flags :: bit_set[Fence_Sync_Flag; u32]


/* Waiting for Sync Objects [4.1.1] */

/* enum ClientWaitSync(sync sync, bitfield flags, uint64 timeout_ns); */
Client_Wait_Sync_Status :: enum u32 {
	Already_Signaled    = gl.ALREADY_SIGNALED,
	Timeout_Expired     = gl.TIMEOUT_EXPIRED,
	Condition_Satisfied = gl.CONDITION_SATISFIED,
	Wait_Failed         = gl.WAIT_FAILED,
}

Client_Wait_Sync_Flag :: enum u32 {
	Sync_Flush_Commands = 0, // SYNC_FLUSH_COMMANDS_BIT :: 0x00000001
}

Client_Wait_Sync_Flags :: bit_set[Client_Wait_Sync_Flag; u32]

/* void WaitSync(sync sync, bitfield flags, uint64 timeout); */
Wait_Sync_Flag :: enum u32 {}

Wait_Sync_Flags :: bit_set[Wait_Sync_Flag; u32]

Wait_Sync_Timeout :: enum u64 {
	Timeout_Ignored = gl.TIMEOUT_IGNORED,
}


/* Sync Object Queries [4.1.3] */

/* void GetSynciv(sync sync, enum pname, sizei bufSize, sizei *length, int *values); */
Get_Synciv_Parameter :: enum u32 {
	Object_Type    = gl.OBJECT_TYPE,
	Sync_Status    = gl.SYNC_STATUS,
	Sync_Condition = gl.SYNC_CONDITION,
	Sync_Flags     = gl.SYNC_FLAGS,
}