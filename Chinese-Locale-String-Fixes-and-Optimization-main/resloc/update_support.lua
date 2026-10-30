-- Shared path discovery and the user-clicked updater action.
CSFRestorationUpdate = CSFRestorationUpdate or {}

function CSFRestorationUpdate:ResolvePath()
	local root = restoration and restoration._mod_path or SC and SC._path
	root = root or ChinStringFixes and ChinStringFixes.Res_Path
	if not root then return nil end
	return root:gsub("[/\\]+$", "") .. "/"
end

function CSFRestorationUpdate:Launch()
	local root = self:ResolvePath()
	local path = root and root .. "update/updater.exe"
	local file = path and io.open(path, "rb")
	if file then
		file:close()
		os.execute('start "" "' .. path:gsub("/", "\\") .. '"')
		return true
	end
	local title = managers.localization:text("CSF_BLT_Text_Title")
	local message = managers.localization:text(root and "CSF_ResUpdater_missing" or "CSF_ResMod_missing")
	QuickMenu:new(title, message, {{text = managers.localization:text("CSF_Quit")}}):Show()
	return false
end
