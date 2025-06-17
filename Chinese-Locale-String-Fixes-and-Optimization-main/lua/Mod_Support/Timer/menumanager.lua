Hooks:PreHook(MenuCallbackHandler, "_dialog_end_game_yes","CSF_ExitGame_SaveHeistsTimer", function(self)
	if managers.player:player_unit() then
		local current_state_name = game_state_machine:current_state_name()
		if current_state_name == "victoryscreen" or current_state_name == "ingame_lobby_menu" or current_state_name == "gameoverscreen" then
			return
		end
		
		local GPC_HT = managers.game_play_central._heist_timer
		local record = GPC_HT and Application:time() - (ChinStringFixes.start_time or 0) or 0
		if Global and Global.ChinStringFixesTimer then
			Global.ChinStringFixesTimer = Global.ChinStringFixesTimer + record
		end
	end
end)


local AF_yes
local AF_fun
local AF_fool
local AF_haha
local AF_title
local AF_message
local AF_messages
local getaf = os.date("*t")
Hooks:Add("MenuManagerOnOpenMenu", "CSF_MenuManagerOnOpenMenuStreamlinedHeisting", function()
	if managers and managers.localization then
		AF_yes = managers.localization:text('CSF_Miss_QKI_yes')
		AF_fun = managers.localization:text('AF_Fun')
		AF_fool = managers.localization:text('AF_Fool')
		AF_haha = managers.localization:text('AF_Haha')
		AF_title = managers.localization:text('AF_Title')
		AF_message = managers.localization:text('AF_Message')
		AF_messages = managers.localization:text('AF_Messages')
	end
	if getaf.month == 4 and getaf.day == 1 then
		if Global then
			if not Global.ChinStringFixesSwitch_hour and Global.ChinStringFixesTimer >= 3600 then
				CSF_create_a_simple_menu(AF_title, AF_message, AF_yes, false, 1)
				Global.ChinStringFixesSwitch_hour = true
			end
			if not Global.ChinStringFixesSwitch_hours and Global.ChinStringFixesTimer >= 7200 then
				CSF_create_a_simple_menu(AF_title, AF_messages, AF_yes, false, 1)
				Global.ChinStringFixesSwitch_hours = true
			end
			if not Global.ChinStringFixesSwitch_haha and Global.ChinStringFixesSwitch_hours and Global.ChinStringFixesTimer >= 9000 then
				CSF_create_a_simple_menu(AF_fool, AF_fun, AF_haha, false, 1)
				Global.ChinStringFixesSwitch_haha = true
			end
		end
	end
end)
