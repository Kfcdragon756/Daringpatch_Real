local GamePlayCentralManager_start_heist_timer = GamePlayCentralManager.start_heist_timer
function GamePlayCentralManager:start_heist_timer()
	GamePlayCentralManager_start_heist_timer(self)
	if ChinStringFixes and ChinStringFixes.start_time then
		ChinStringFixes.start_time = self._heist_timer.start_time
	end
end