local origin_content_jobs = WeaponFactoryTweakData._init_content_jobs
function WeaponFactoryTweakData:_init_content_jobs()
	origin_content_jobs(self)

	self.parts.wpn_fps_upg_ns_duck.has_description = true
	
end
