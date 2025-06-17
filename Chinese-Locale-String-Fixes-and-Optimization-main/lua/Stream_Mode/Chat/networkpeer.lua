if not ChinStringFixes then
    dofile(ModPath .. "Core.lua")
end

local is_chinese = CSF_is_schinese()

if not ChinStringFixes.settings.Stream_Mode.CSF_Name.CSF_Name_Enable then
    return
end

Hooks:PreHook(NetworkPeer, "name", "CSF_Steaming_Mode_name", function(self)
    local judge_function = ChinStringFixes.containsChars --
	local name_get = self._name
    local characters_all_1 = {"平", "习", "近"}
    local characters_all_1_1 = {"pin", "jin", "xi"}
    local characters_all_2 = {"泽", "民", "江"}
    local characters_all_2_1 = {"jian", "ze", "min"}
    local name_match_all = judge_function(ChinStringFixes, name_get, characters_all_1, true) or
                               judge_function(ChinStringFixes, name_get, characters_all_1_1, true) or
                               judge_function(ChinStringFixes, name_get, characters_all_2, true) or
                               judge_function(ChinStringFixes, name_get, characters_all_2_1, true) -- 参数3输入 真 ，所有都包含才返回true

    local characters_part = {"海洛因", "冰毒", "可卡因", "吸毒", "毒品", "奶水", "奶头", "精液", "淫水", "淫液", "发情", "重口", "乳液", "乳头", "操逼", "强奸", "子宫", "阴道"}
    local name_match_part = judge_function(ChinStringFixes, name_get, characters_part, nil) -- 参数3输入 假 ，有一个包含就返回true

    if name_match_all or name_match_part then
        if ChinStringFixes.settings.Stream_Mode.CSF_Name.CSF_Name_Display == 2 then
			self._name = self._account_id
        else
            if is_chinese then
                self._name = "<昵称已屏蔽>"
            else
                self._name = "<Name Muted>"
            end
        end
    end
end)

--[[Hooks:PostHook(NetworkPeer, "init", "init_Streamtest", function(self, name, rpc, id, loading, synced, in_lobby, character, user_id, account_type_str, account_id)
	self._name = name or managers.localization:text("menu_" .. tostring(character or "russian"))
	managers.mission._fading_debug_output:script().log("_name is "..self._name)
	managers.mission._fading_debug_output:script().log(" ")
	local userid_type = type(self._user_id)
	if userid_type == "string" then
		managers.mission._fading_debug_output:script().log("userid_type is "..userid_type)
		managers.mission._fading_debug_output:script().log("user_id is "..self._user_id)
	else
		managers.mission._fading_debug_output:script().log("userid_type is "..userid_type)
	end
	managers.mission._fading_debug_output:script().log(" ")
	local acc_type = type(self._account_id)
	if acc_type == "string" then
		managers.mission._fading_debug_output:script().log("acc_type is "..acc_type)
		managers.mission._fading_debug_output:script().log("acc_id is "..self._account_id)
	else
		managers.mission._fading_debug_output:script().log("acc_type is "..acc_type)
	end
end)

Hooks:PostHook(NetworkPeer, "set_name", "set_name_Streamtest", function(self, name)
	log("self._name is "..self._name)
end)

Hooks:PostHook(NetworkPeer, "set_name_drop_in", "set_name_drop_in_name_Streamtest", function(self, name)
	log("_name_drop_in is "..self._name_drop_in)
end)--]]

