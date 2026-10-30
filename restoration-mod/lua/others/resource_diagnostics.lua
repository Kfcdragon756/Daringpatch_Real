-- RC4 diagnostics: record the custom unit immediately before the engine load.
-- This does not skip or replace resources and cannot catch a native crash.
Hooks:PreHook(DynamicResourceManager, "load", "CN64_LastCustomUnitLoad", function(self, resource_type, resource_name)
	if not resource_type or resource_type:key() ~= Idstring("unit"):key() or not resource_name then return end
	local files = Global.fm and Global.fm.added_files
	local bucket = files and files[resource_type:key()]
	local entry = bucket and bucket[resource_name:key()]
	local source = entry and entry.file
	-- Keep the isolated vanilla fallback visible even though it has no custom entry.
	if not source and resource_name:key() == Idstring("units/pd2_dlc_chico/weapons/wpn_npc_sg417/wpn_npc_sg417"):key() then
		source = "[game DB fallback] units/pd2_dlc_chico/weapons/wpn_npc_sg417/wpn_npc_sg417"
	end
	if not source then return end
	local message = "[CN64 Resource] unit load: " .. tostring(source) .. " | " .. tostring(resource_name)
	log(message)
	-- Preserve the final request even if the process dies before its log flushes.
	if SavePath then
		local file = io.open(SavePath .. "restoration_cn64_last_resource.txt", "w")
		if file then
			file:write(message .. "\n")
			file:close()
		end
	end
end)
