#+ private
package app

import "core:prof/spall"

when SPALL_ENABLED {
    @(no_instrumentation)
    spall_buffer_begin :: proc "contextless" (name: string, args: string = "", location := #caller_location) #no_bounds_check /* bounds check would segfault instrumentation */ {
        spall._buffer_begin(ctx.spall_ctx, ctx.spall_buffer, name, args, location)
    }
    @(no_instrumentation)
    spall_buffer_end :: proc "contextless" () #no_bounds_check /* bounds check would segfault instrumentation */ {
        spall._buffer_end(ctx.spall_ctx, ctx.spall_buffer)
    }
} else {
    @(no_instrumentation)
    spall_buffer_begin :: proc "contextless" (name: string, args: string = "", location := #caller_location) #no_bounds_check /* bounds check would segfault instrumentation */ {
        // do nothing
    }
    @(no_instrumentation)
    spall_buffer_end :: proc "contextless" () #no_bounds_check /* bounds check would segfault instrumentation */ {
        // do nothing
    }
}