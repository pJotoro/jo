package ngl

import gl "vendor:OpenGL"

delete_pipelines :: proc "contextless" (pipelines: []Pipeline) {
	gl.impl_DeleteProgramPipelines(i32(len(pipelines)), ([^]u32)(raw_data(pipelines)))
}

gen_pipelines :: proc "contextless" (pipelines: []Pipeline) {
	gl.impl_CreateProgramPipelines(i32(len(pipelines)), ([^]u32)(raw_data(pipelines)))
}

is_pipeline :: proc "contextless" (pipeline: u32) -> bool {
	return gl.impl_IsProgramPipeline(pipeline)
}