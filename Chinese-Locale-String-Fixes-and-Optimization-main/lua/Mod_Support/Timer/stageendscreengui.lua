Hooks:PostHook(StageEndScreenGui, "feed_statistics","CSF_StatisticsManager_HTsessionfdfd_time_played", function(self, data)
	local GPC_HT = managers.game_play_central._heist_timer
	local record = 0
	if ChinStringFixes and ChinStringFixes.start_time then
		record = GPC_HT and Application:time() - (ChinStringFixes.start_time or 0) or 0
	end
	if Global and Global.ChinStringFixesTimer then
		Global.ChinStringFixesTimer = Global.ChinStringFixesTimer + record
	end
end)