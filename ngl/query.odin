package ngl

import gl "vendor:OpenGL"

gen_queries :: proc "contextless" (target: Query_And_Timestamp_Target, ids: []Query) {
	gl.impl_CreateQueries(u32(target), i32(len(ids)), ([^]u32)(raw_data(ids)))
}

delete_queries :: proc "contextless" (ids: []Query) {
	gl.impl_DeleteQueries(i32(len(ids)), ([^]u32)(raw_data(ids)))
}

is_query :: proc "contextless" (query: u32) -> bool {
	return gl.impl_IsQuery(query)
}

begin_query :: proc "contextless" (target: Query_Target, id: Query) {
	gl.impl_BeginQuery(u32(target), u32(id))
}

end_query :: proc "contextless" (target: Query_Target) {
	gl.impl_EndQuery(u32(target))
}

query_counter :: proc "contextless" (query: Query) {
	gl.impl_QueryCounter(u32(query), gl.TIMESTAMP)
}

begin_query_indexed :: proc "contextless" (target: Query_Target, index: u32, query: Query) {
	gl.impl_BeginQueryIndexed(u32(target), index, u32(query))
}

end_query_indexed :: proc "contextless" (target: Query_Target, index: u32) {
	gl.impl_EndQueryIndexed(u32(target), index)
}

get_query_samples_passed :: proc "contextless" () -> (res: i64, n_bits: i32) {
    @static _n_bits := i32(0)
    if _n_bits != 0 {
        n_bits = _n_bits
    } else {
        gl.impl_GetQueryiv(gl.SAMPLES_PASSED, gl.QUERY_COUNTER_BITS, &_n_bits)
        n_bits = _n_bits
    }

    if n_bits <= 32 {
        _res: i32
        gl.impl_GetQueryiv(gl.SAMPLES_PASSED, gl.CURRENT_QUERY, &_res)
        res = i64(_res)
    } else {
        gl.impl_GetQueryiv(gl.SAMPLES_PASSED, gl.CURRENT_QUERY, ([^]i32)(&res))
    }
    return
}

get_query_any_samples_passed :: proc "contextless" () -> (res: bool) {
    _res: i32
    gl.impl_GetQueryiv(gl.ANY_SAMPLES_PASSED, gl.CURRENT_QUERY, &_res)
    res = bool(_res)
    return
}

get_query_any_samples_passed_conservative :: proc "contextless" () -> (res: bool) {
    _res: i32
    gl.impl_GetQueryiv(gl.ANY_SAMPLES_PASSED_CONSERVATIVE, gl.CURRENT_QUERY, &_res)
    res = bool(_res)
    return
}

get_query_primitives_generated :: proc "contextless" () -> (res: i64, n_bits: i32) {
    @static _n_bits := i32(0)
    if _n_bits != 0 {
        n_bits = _n_bits
    } else {
        gl.impl_GetQueryiv(gl.PRIMITIVES_GENERATED, gl.QUERY_COUNTER_BITS, &_n_bits)
        n_bits = _n_bits
    }

    if n_bits <= 32 {
        _res: i32
        gl.impl_GetQueryiv(gl.PRIMITIVES_GENERATED, gl.CURRENT_QUERY, &_res)
        res = i64(_res)
    } else {
        gl.impl_GetQueryiv(gl.PRIMITIVES_GENERATED, gl.CURRENT_QUERY, ([^]i32)(&res))
    }
    return
}

get_query_transform_feedback_primitives_written :: proc "contextless" () -> (res: i64, n_bits: i32) {
    @static _n_bits := i32(0)
    if _n_bits != 0 {
        n_bits = _n_bits
    } else {
        gl.impl_GetQueryiv(gl.TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, gl.QUERY_COUNTER_BITS, &_n_bits)
        n_bits = _n_bits
    }

    if n_bits <= 32 {
        _res: i32
        gl.impl_GetQueryiv(gl.TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, gl.CURRENT_QUERY, &_res)
        res = i64(_res)
    } else {
        gl.impl_GetQueryiv(gl.TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, gl.CURRENT_QUERY, ([^]i32)(&res))
    }
    return
}

get_query_time_elapsed :: proc "contextless" () -> (res: i64, n_bits: i32) {
    @static _n_bits := i32(0)
    if _n_bits != 0 {
        n_bits = _n_bits
    } else {
        gl.impl_GetQueryiv(gl.TIME_ELAPSED, gl.QUERY_COUNTER_BITS, &_n_bits)
        n_bits = _n_bits
    }

    if n_bits <= 32 {
        _res: i32
        gl.impl_GetQueryiv(gl.TIME_ELAPSED, gl.CURRENT_QUERY, &_res)
        res = i64(_res)
    } else {
        gl.impl_GetQueryiv(gl.TIME_ELAPSED, gl.CURRENT_QUERY, ([^]i32)(&res))
    }
    return
}

get_query_timestamp :: proc "contextless" () -> (res: i64, n_bits: i32) {
    @static _n_bits := i32(0)
    if _n_bits != 0 {
        n_bits = _n_bits
    } else {
        gl.impl_GetQueryiv(gl.TIMESTAMP, gl.QUERY_COUNTER_BITS, &_n_bits)
        n_bits = _n_bits
    }

    if n_bits <= 32 {
        _res: i32
        gl.impl_GetQueryiv(gl.TIMESTAMP, gl.CURRENT_QUERY, &_res)
        res = i64(_res)
    } else {
        gl.impl_GetQueryiv(gl.TIMESTAMP, gl.CURRENT_QUERY, ([^]i32)(&res))
    }
    return
}

get_query_result_no_buffer :: proc "contextless" (query: Query) -> (res: u64) {
    gl.impl_GetQueryObjectui64v(u32(query), gl.QUERY_RESULT, &res)
    return
}

get_query_result_buffer :: proc "contextless" (query: Query, buffer: Buffer, offset: int) {
    gl.impl_GetQueryBufferObjectui64v(u32(query), u32(buffer), gl.QUERY_RESULT, offset)
}

get_query_result :: proc {
    get_query_result_no_buffer,
    get_query_result_buffer,
}

get_query_result_no_wait_no_buffer :: proc "contextless" (query: Query) -> (res: u64, modified: bool) {
    gl.impl_GetQueryObjectui64v(u32(query), gl.QUERY_RESULT_NO_WAIT, &res)
    if res != 0 {
        modified = true
    }
    return
}

get_query_result_no_wait_buffer :: proc "contextless" (query: Query, buffer: Buffer, offset: int) {
    gl.impl_GetQueryBufferObjectui64v(u32(query), u32(buffer), gl.QUERY_RESULT_NO_WAIT, offset)
}

get_query_result_no_wait :: proc {
    get_query_result_no_wait_no_buffer,
    get_query_result_no_wait_buffer,
}

get_query_result_available_no_buffer :: proc "contextless" (query: Query) -> (res: bool) {
    _res: i32 = ---
    gl.impl_GetQueryObjectiv(u32(query), gl.QUERY_RESULT_AVAILABLE, &_res)
    res = bool(_res)
    return
}

get_query_result_available_buffer :: proc "contextless" (query: Query, buffer: Buffer, offset: int) {
    gl.GetQueryBufferObjectiv(u32(query), u32(buffer), gl.QUERY_RESULT_AVAILABLE, offset)
}

get_query_result_available :: proc {
    get_query_result_available_no_buffer,
    get_query_result_available_buffer,
}

get_query_target_no_buffer :: proc "contextless" (query: Query) -> (target: Query_And_Timestamp_Target) {
    gl.impl_GetQueryObjectuiv(u32(query), gl.QUERY_TARGET, (^u32)(&target))
    return
}

get_query_target_buffer :: proc "contextless" (query: Query, buffer: Buffer, offset: int) {
    gl.impl_GetQueryBufferObjectuiv(u32(query), u32(buffer), gl.QUERY_TARGET, offset)
}

get_query_target :: proc {
    get_query_target_no_buffer,
    get_query_target_buffer,
}