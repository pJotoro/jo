package tests

import "core:log"
import "core:testing"
import "core:os"

create_logger :: proc(t: ^testing.T) -> log.Logger {
	return log.Logger{
        procedure = logger_proc,
        data = t,
        lowest_level = .Debug,
        options = { .Level, .Date, .Time, .Short_File_Path, .Long_File_Path, .Line, .Procedure, .Terminal_Color }, // NOTE(pJotoro): It doesn't really matter what I put here...
    }
}

logger_proc :: proc(data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
    t := (^testing.T)(data)

    switch level {
        case .Debug, .Info, .Warning:

        case .Error:
            testing.error(t, text)
        case .Fatal:
            testing.fail_now(t, text)
    }
}