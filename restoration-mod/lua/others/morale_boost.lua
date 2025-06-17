Hooks:PostHook(PlayerStandard, "_do_action_intimidate", "gogobothgogo", function(self, t, interact_type, sound_name, skip_alert, ...)
    local my_unit = managers.network:session():local_peer():unit()
	
	if interact_type == "cmd_gogo" and managers.player:has_category_upgrade("cooldown", "long_dis_revive") then
		my_unit:movement():on_morale_boost(my_unit)
	elseif interact_type == "cmd_come" and managers.player:has_category_upgrade("cooldown", "long_dis_revive") and self._i_call_ai then
		my_unit:movement():on_morale_boost(my_unit)
	end
	
end)

Hooks:PostHook(PlayerStandard, "_get_intimidation_action", "aigobothgogo", function(self, prime_target, char_table, amount, primary_only, detect_only, secondary, ...)
	if prime_target and prime_target.unit_type == 2 and managers.groupai:state():all_criminals()[prime_target.unit:key()].ai then
	    self._i_call_ai = true
	else
		self._i_call_ai = false
	end
end)
