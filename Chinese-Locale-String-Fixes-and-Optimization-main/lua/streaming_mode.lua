local schinese = Idstring("schinese"):key() == SystemInfo:language():key()
if not schinese and not CHNMOD_PATCH then
	return
end

if not ChinStringFixes or not ChinStringFixes.settings.Enable_String then
	return
end


if ChinStringFixes.settings.Stream_Mode.CSF_Cocaine then
	dofile(ModPath .. "lua/Stream_Mode/Cocaine.lua")
end

if ChinStringFixes.settings.Stream_Mode.CSF_Meth then
	dofile(ModPath .. "lua/Stream_Mode/Meth.lua")
end

if ChinStringFixes.settings.Stream_Mode.CSF_Euphadrine then
	dofile(ModPath .. "lua/Stream_Mode/Euphadrine.lua")
end