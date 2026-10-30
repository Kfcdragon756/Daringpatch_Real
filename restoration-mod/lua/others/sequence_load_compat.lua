-- RC6 compatibility trial: avoid a second load of a Restoration unit from
-- inside its native package notification. Preserve the original sequence
-- registration, but run it from the next SequenceManager update.
local sequence_class = CoreSequenceManager and CoreSequenceManager.SequenceManager
if not sequence_class or sequence_class._cn64_deferred_unit_callback then return end

local source = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")
local root = restoration and restoration._mod_path or source:match("^(.-)/lua/")
if not root then error("[CN64 Sequence] Cannot resolve Restoration asset root") end
local function normalize(path)
	return tostring(path):gsub("\\", "/"):gsub("/+", "/"):lower()
end
local prefix = normalize(root):gsub("/+$", "") .. "/"
local unit_type = Idstring("unit")
local original_loaded = Hooks:GetFunction(sequence_class, "clbk_pkg_manager_unit_loaded")

local function record(stage, file, name)
	local message = "[CN64 Sequence] " .. stage .. ": " .. tostring(file) .. " | " .. tostring(name)
	log(message)
	if SavePath then
		local out = io.open(SavePath .. "restoration_cn64_sequence_load.txt", "w")
		if out then out:write(message .. "\n"); out:close() end
	end
end

Hooks:OverrideFunction(sequence_class, "clbk_pkg_manager_unit_loaded", function(self, resource_type, unit_name)
	local files = Global and Global.fm and Global.fm.added_files
	local units = files and files[unit_type:key()]
	local entry = unit_name and units and units[unit_name:key()]
	local owned = entry and entry.file and normalize(entry.file):find(prefix, 1, true) == 1
	local dynamic = managers and managers.dyn_resource
	-- Already tracked dynamic loads do not start another load in BeardLib.
	if not owned or (dynamic and dynamic:has_resource(unit_type, unit_name, dynamic.DYN_RESOURCES_PACKAGE)) then
		return original_loaded(self, resource_type, unit_name)
	end
	self._cn64_unit_queue = self._cn64_unit_queue or {}
	self._cn64_unit_pending = self._cn64_unit_pending or {}
	local key = unit_name:key()
	if not self._cn64_unit_pending[key] then
		self._cn64_unit_pending[key] = true
		table.insert(self._cn64_unit_queue, {resource_type = resource_type, name = unit_name, file = entry.file})
		record("deferred from package callback", entry.file, unit_name)
	end
end)

Hooks:PreHook(sequence_class, "update", "CN64_ProcessDeferredUnitSequences", function(self)
	local queue = self._cn64_unit_queue
	if not queue or #queue == 0 or not (managers and managers.dyn_resource) then return end
	-- Detach this batch. New callbacks caused by these loads run next frame;
	-- they must not extend the batch while it is being processed.
	self._cn64_unit_queue = nil
	self._cn64_unit_pending = nil
	for _, request in ipairs(queue) do
		record("processing after package callback", request.file, request.name)
		original_loaded(self, request.resource_type, request.name)
		record("sequence callback returned", request.file, request.name)
	end
end)
sequence_class._cn64_deferred_unit_callback = true
log("[CN64 Sequence] Restoration unit callback compatibility installed")
