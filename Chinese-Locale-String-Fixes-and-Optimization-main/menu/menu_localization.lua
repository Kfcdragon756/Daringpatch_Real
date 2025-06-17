--localization

local mpath=ModPath

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ltyrchinfix", function(loc)
	local lang, path=SystemInfo and SystemInfo:language(), "loc/english.txt"
		if lang==Idstring("schinese") then
			path="loc/schinese.txt"
		end
	loc:load_localization_file(mpath..path)
end)

