if not ChinStringFixes or not ChinStringFixes.settings.Stream_Mode.CSF_Text.CSF_Text_Chat then
	return
end

local xxx  = {
		'可卡因',
		'冰毒',
		'麻黄素',
		'习近平',
		'江泽民',
		'共产党',
		'毒品',
		'制毒',
		'膜蛤',
		'你妈死了',
		'干你妈',
		'日你妈',
		'你妈逼',
		'操逼',
		'操你妈'
	}
local CSF_CM_check = xxx

local CSF_CM_SaveString = ""
local CSF_CM_Replace_1 = ""
local CSF_CM_Replace_2 = ""
local CSF_CM_TableCheck = {}
local CSF_is_table_exist = io.file_is_readable(SavePath .. "chin_string_fixes_steam_mode.json")
local CSF_CM_SaveTable

if CSF_is_table_exist then
	CSF_CM_SaveTable = io.open(SavePath .. "chin_string_fixes_steam_mode.json", "r")
	if CSF_CM_SaveTable then
		CSF_CM_SaveString = CSF_CM_SaveTable:read("*all")
		CSF_CM_SaveTable:close()
	end
	CSF_CM_Replace_1 = string.gsub(CSF_CM_SaveString, "%[", "{")
	CSF_CM_Replace_2 = string.gsub(CSF_CM_Replace_1, "%]", "}")
	CSF_CM_TableCheck = CSF_StrToTable(CSF_CM_Replace_2)
end

function ChatManager:receive_message_by_peer(channel_id, peer, message)
	if self:is_peer_muted(peer) then
		return
	end
	local color_id = peer:id()
	local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	local rank = peer:level() == nil and managers.experience:current_rank() or peer:rank()
	local icon = managers.experience:rank_icon(rank)
	local name = peer:name()

	for _, v in pairs(CSF_CM_check) do
		if string.find(name,v) or string.find(message,v) then
			if string.find(name,v) then
				name=string.gsub(name,v,'*')
			end
			if string.find(message,v) then
				message=string.gsub(message,v,'*')
			end
		end
	end

	if CSF_CM_TableCheck and type(CSF_CM_TableCheck) == "table" then
		for _, v_2 in pairs(CSF_CM_TableCheck) do
			if string.find(name,v_2) or string.find(message,v_2) then
				if string.find(name,v_2) then
					name=string.gsub(name,v_2,'*')
				end
				if string.find(message,v_2) then
					message=string.gsub(message,v_2,'*')
				end
			end
		end
	end

	self:_receive_message(channel_id, name, message, tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors], icon)
end
