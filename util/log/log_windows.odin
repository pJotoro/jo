package util_log

import "core:log"
import win32 "core:sys/windows"
import "core:fmt"
import "core:strings"
import "core:time"
import "core:os"

foreign import kernel32 "system:Kernel32.lib"

@(default_calling_convention="system")
foreign kernel32 {
	IsDebuggerPresent :: proc() -> win32.BOOL ---
}

Logger_Data :: struct {
	ident: string,
}

do_level_header :: proc(opts: log.Options, str: ^strings.Builder, level: log.Level) {
	if .Level in opts {
		fmt.sbprint(str, log.Level_Headers[level])
	}
}

logger_proc :: proc(data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
	data := (^Logger_Data)(data)

	backing: [1024]byte //NOTE(Hoej): 1024 might be too much for a header backing, unless somebody has really long paths.
	buf := strings.builder_from_bytes(backing[:])

	do_level_header(options, &buf, level)

	when time.IS_SUPPORTED {
		log.do_time_header(options, &buf, time.now())
	}

	log.do_location_header(options, &buf, location)

	if .Thread_Id in options {
		// NOTE(Oskar): not using context.thread_id here since that could be
		// incorrect when replacing context for a thread.
		fmt.sbprintf(&buf, "[{}] ", os.current_thread_id())
	}

	if data.ident != "" {
		fmt.sbprintf(&buf, "[%s] ", data.ident)
	}

	fmt.sbprintf(&buf, "%s\n", text)

	wstring := win32.utf8_to_wstring(strings.to_string(buf))
	win32.OutputDebugStringW(wstring)
}

// In a debugger, it prints to the debug console. Otherwise, it is identical to the console logger.
create_logger :: proc(lowest := log.Level.Debug, opt := log.Default_Console_Logger_Opts, ident := "") -> log.Logger {
	if !IsDebuggerPresent() {
		return log.create_console_logger(lowest, opt, ident)
	} else {
		data := new(Logger_Data)
		data.ident = ident
		return log.Logger{logger_proc, data, lowest, opt}
	}
}

destroy_logger :: proc(logger: log.Logger) {
	free(logger.data)
}