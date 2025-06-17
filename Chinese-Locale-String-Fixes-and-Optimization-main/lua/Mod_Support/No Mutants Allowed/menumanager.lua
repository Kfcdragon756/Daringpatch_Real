if not ChinStringFixes or not ChinStringFixes.settings.Mod_Support.NoMA.NoMA_Enable then
	return
end

if not NoMA then
	return
else
	log("ChinStringFixes : NoMA Detected.")
end

local function logf(...)
	log(string.format(...))
end
local function _has_category(categories, category)
	return categories and table.contains(categories, category)
end

local wctg2upgname = {
	pistol = 'pistol_magazine_capacity_inc_1',
	shotgun = 'shotgun_magazine_capacity_inc_1',
	assault_rifle = 'player_automatic_mag_increase_1',
	lmg = 'player_automatic_mag_increase_1',
	smg = 'player_automatic_mag_increase_1'
}

local function eval_to_string(tbl)
	local result = tbl[4] .. ' ' .. NoMA.damage_match_str[4]
	for i = 3, 1, -1 do
		result = result .. ' / ' .. tbl[i] .. ' ' .. NoMA.damage_match_str[i]
	end
	return result
end

local function bonus_eval_counter_to_string(tbl)
	local result = 'accounted bonuses (minimum):'
	for k, v in pairs(tbl) do
		result = result .. '\n- ' .. k .. ': ' .. v
	end
	return result
end

local function all_damages_to_string(tbl, category)
	local result = 'accounted amounts on ' .. category .. ':'

	local dmgs = table.map_keys(tbl.damage_all_counter)
	table.sort(dmgs)
	for _, dmg in ipairs(dmgs) do
		local eval_x = {}
		for i = 1, 4 do
			local nr = tbl.damage_eval_counter[i][dmg]
			if nr then
				table.insert(eval_x, nr .. ' ' .. NoMA.damage_match_str[i])
			end
		end
		result = result .. '\n- ' .. dmg .. ' (' .. table.concat(eval_x, ' / ') .. ')'
	end

	return result
end

local function weapon_parts_names(tbl)
	local parts = {}
	for _, part_id in ipairs(tbl) do
		if not tweak_data.weapon.factory.parts[part_id].inaccessible then
			table.insert(parts, managers.localization:text(tweak_data.weapon.factory.parts[part_id].name_id))
		end
	end
	return #parts == 0 and 'nothing' or table.concat(parts, ' / ')
end

local function round_timer(t)
	return math.round(t * 10) / 10 -- *sigh*
end

-------------------------------------------------------------------------------------------------------------------

function NoMA:check_weapon_ammo(peer, weapon, clip_base_mod, total_ammo_mod, recv_ammo_max, recv_clip_ammo_max)
	local weapon_tweak_data = tweak_data.weapon[weapon.weapon_id]
	local factory = tweak_data.weapon.factory

	-- mods
	local weapon_factory = factory[weapon.factory_id]
	for _, mod_id in pairs(weapon.equipped_mods) do
		local part = factory.parts[mod_id]
		if not part then
			logf('[NoMA] %s (%s) Unknown mod for %s: %s',
				peer:name(), peer:skills(), weapon.name, mod_id)
			self:mark_cheater(peer, string.format('unknown mod for %s: %s', weapon.name, mod_id))
			return
		end

		if not weapon_factory.uses_parts or not table.contains(weapon_factory.uses_parts, mod_id) then
			logf('[NoMA] %s (%s) Forbidden mod for %s: %s',
				peer:name(), peer:skills(), weapon.name, managers.localization:text(part.name_id))
			self:mark_cheater(peer, string.format('forbidden mod for %s: %s',
				weapon.name, managers.localization:text(part.name_id)))
			return
		end
	end

	-- mag size
	local function upgrade_blocked(category, upgrade)
		if not weapon_tweak_data.upgrade_blocks then
			return false
		end
		if not weapon_tweak_data.upgrade_blocks[category] then
			return false
		end
		return table.contains(weapon_tweak_data.upgrade_blocks[category], upgrade)
	end

	if clip_base_mod < recv_clip_ammo_max then
		local mag_ok
		if not upgrade_blocked('weapon', 'clip_ammo_increase') then
			local wctgs = weapon_tweak_data.categories
			local upgrade_name
			for ctg, upg_name in pairs(wctg2upgname) do
				if _has_category(wctgs, ctg) then
					if ctg == 'pistol' and _has_category(wctgs, 'revolver') then
						-- qued
					else
						upgrade_name = upg_name
					end
					break
				end
			end
			if upgrade_name then
				local upg_def = tweak_data.upgrades.definitions[upgrade_name].upgrade
				local mult = _has_category(wctgs, 'akimbo') and 2 or 1
				for _, clip_skill in pairs(tweak_data.upgrades.values[upg_def.category][upg_def.upgrade]) do
					local final_clip_skill = clip_skill * mult
					if clip_base_mod + final_clip_skill == recv_clip_ammo_max or clip_base_mod + final_clip_skill > recv_ammo_max then
						mag_ok = true
						self:check_upgrade(peer, upgrade_name)
					end
				end
			end
		end
		if not mag_ok then
			logf('[NoMA] %s (%s) Weird mag size for %s: received %i, got base of %i',
				peer:name(), peer:skills(), weapon.name, recv_clip_ammo_max, clip_base_mod)
			self:log_weapon_details(weapon)
			self:mark_cheater(peer, string.format('%s的武器弹容量异常，他的值为%i，本地值为%i',
				weapon.name, recv_clip_ammo_max, clip_base_mod))
		end
	end

	-- ammo max
	local function get_ammo_max(ammo_max_mul)
		ammo_max_mul = ammo_max_mul + ammo_max_mul * total_ammo_mod
		return math.round(tweak_data.weapon[weapon.weapon_id].AMMO_MAX * ammo_max_mul)
	end

	if get_ammo_max(1) == recv_ammo_max then
		return
	end

	local ammo_max_multiplier_fl = tweak_data.upgrades.values.player.extra_ammo_multiplier[1]
	if weapon_tweak_data.category == 'akimbo' then
		local profile = self:get_player_profile(peer)

		local has_perk_hitman = profile.perk_id == 5 and profile.perk_rank >= 3
		local multiplier_low = has_perk_hitman and tweak_data.upgrades.values.akimbo.extra_ammo_multiplier[1] or 1
		local multiplier_high = tweak_data.upgrades.values.akimbo.extra_ammo_multiplier[has_perk_hitman and 2 or 1]

		if get_ammo_max(multiplier_low) == recv_ammo_max then
			return

		elseif get_ammo_max(multiplier_high) == recv_ammo_max then
			self:check_upgrade(peer, 'akimbo_extra_ammo_multiplier_1')
			return

		elseif get_ammo_max(multiplier_low * ammo_max_multiplier_fl) == recv_ammo_max then
			self:check_upgrade(peer, 'extra_ammo_multiplier1')
			return

		elseif get_ammo_max(multiplier_high * ammo_max_multiplier_fl) == recv_ammo_max then
			self:check_upgrade(peer, 'akimbo_extra_ammo_multiplier_1')
			self:check_upgrade(peer, 'extra_ammo_multiplier1')
			return
		end

	elseif get_ammo_max(ammo_max_multiplier_fl) == recv_ammo_max then
		self:check_upgrade(peer, 'extra_ammo_multiplier1')
		return

	elseif weapon_tweak_data.category == 'saw' then
		local ammo_max_multiplier_saw = tweak_data.upgrades.values.saw.extra_ammo_multiplier[1]
		if get_ammo_max(ammo_max_multiplier_saw) == recv_ammo_max then
			self:check_upgrade(peer, 'saw_extra_ammo_multiplier')
			return
		elseif get_ammo_max(ammo_max_multiplier_saw * ammo_max_multiplier_fl) == recv_ammo_max then
			self:check_upgrade(peer, 'extra_ammo_multiplier1')
			self:check_upgrade(peer, 'saw_extra_ammo_multiplier')
			return
		end
	end

	logf('[NoMA] %s (%s) Weird total ammo for %s: received %i, got base of %i (%i with FL)',
		peer:name(), peer:skills(), weapon.name, recv_ammo_max, get_ammo_max(1), get_ammo_max(ammo_max_multiplier_fl))
	self:log_weapon_details(weapon)
	self:mark_cheater(peer, string.format('%s的武器总弹量异常，他的值为%i，本地值为%i（空仓时为%i）',
		weapon.name, recv_ammo_max, get_ammo_max(1), get_ammo_max(ammo_max_multiplier_fl)))
end



function NoMA:check_ammo(peer, selection_index, max_clip, current_clip, current_left, max)
	local profile = self:get_player_profile(peer)

	local weapon = profile.weapons[selection_index]
	if not weapon then
		return
	end

	if not weapon.ammo_checked then
		if not weapon.weapon_id then
			return
		end

		weapon.ammo_checked = true
		weapon.recv_clip_ammo_max = max_clip
		weapon.recv_ammo_max = max

		if not tweak_data.weapon[weapon.weapon_id] then
			logf('[NoMA] %s (%s) Weird weapon_id: received %s',
				profile.name, profile.skills, tostring(weapon.weapon_id))
			self:mark_cheater(peer, string.format('weird weapon_id: received %s', tostring(weapon.weapon_id)))
			return
		end

		for _, default_part in ipairs(managers.weapon_factory:get_default_blueprint_by_factory_id(weapon.factory_id)) do
			table.delete(weapon.equipped_mods, default_part)
		end
		local cs = weapon.skin:split('-')
		local cosmetics = {
			id = cs[1] ~= 'nil' and cs[1] or nil,
			quality = cs[2],
			bonus = cs[3] == '1',
			data = cs[1] ~= 'nil' and tweak_data.blackmarket.weapon_skins[cs[1]] or nil
		}
		local current_stats = self:get_weapon_stats(weapon.factory_id, weapon.weapon_id, weapon.equipped_mods, cosmetics)
		weapon.current_stats = current_stats

		self:check_weapon_ammo(peer, weapon, tweak_data.weapon[weapon.weapon_id].CLIP_AMMO_MAX + current_stats.extra_ammo, current_stats.total_ammo_mod, max, max_clip)
	end

	if current_clip < 0 or current_clip > weapon.recv_clip_ammo_max then
		logf('[NoMA] %s (%s) Magazine is abnormally filled! Got %i out of %i',
			profile.name, profile.skills, current_clip, weapon.recv_clip_ammo_max)
		self:mark_cheater(peer, string.format('换弹异常！对方弹药量变成了%i，正常为%i。', current_clip, weapon.recv_clip_ammo_max))
	end

	if max_clip ~= weapon.recv_clip_ammo_max then
		logf('[NoMA] %s (%s) Size of magazine has changed! %i to %i',
			profile.name, profile.skills, weapon.recv_clip_ammo_max, max_clip)
		self:mark_cheater(peer, string.format('弹容量从%i变成了%i', weapon.recv_clip_ammo_max, max_clip))
		weapon.recv_clip_ammo_max = max_clip
	end

	if max ~= weapon.recv_ammo_max then
		logf('[NoMA] %s (%s) Ammo quantity has changed! %i to %i',
			profile.name, profile.skills, weapon.recv_ammo_max, max)
		self:mark_cheater(peer, string.format('总弹量从%i变成了%i', weapon.recv_ammo_max, max))
		weapon.recv_ammo_max = max
	end
end



function NoMA:check_elapsed_time(peer, interaction_id)
	local profile = self:get_player_profile(peer)
	if not profile.previous_interaction_start then
		return
	end

	if not profile.previous_interaction_timer then
		logf('[NoMA] %s (%s) Timer was not initialized!',
			profile.name, profile.skills)
		self:mark_cheater(peer, '互动计时器未能初始化。')
	end

	profile.previous_interaction_id = interaction_id

	if self.timespeedchange_t >= profile.previous_interaction_start then
		return
	end

	-- announced timer vs time past
	local t = TimerManager:game():time()
	local dt = t - profile.previous_interaction_start
	local qos = peer:qos()
	local ping_sec = qos.ping / 1000

	profile.persistent.timers_total = profile.persistent.timers_total + 1
	profile.persistent.timers_sum = profile.persistent.timers_sum + profile.previous_interaction_timer
	profile.persistent.timers_real_sum = profile.persistent.timers_real_sum + dt

	if dt - profile.previous_interaction_timer < -0.1 - ping_sec then
		if t - self.spawn_t < 15 and interaction_id == 'mask_on_action' then
			-- discard warning due to interaction started while in blackscreen
			return
		end

		profile.persistent.timers_short = profile.persistent.timers_short + 1
		if qos.packet_loss > profile.previous_packet_loss then
			profile.previous_packet_loss = qos.packet_loss
			profile.persistent.network_prbs = profile.persistent.network_prbs + 1
		end

		logf('[NoMA] %s (%s) Elapsed time not equal to timer for %s! Got %.1f sec instead of %.1f sec (latency = %.2f, packet_loss = %i, window = %.1f)',
			profile.name, profile.skills, interaction_id, dt, profile.previous_interaction_timer, ping_sec, qos.packet_loss, qos.window)

		-- not reliable enough to give the cheater mark, player has to decide by himself
		local overall_wait_rate = 100 * profile.persistent.timers_real_sum / profile.persistent.timers_sum
		if overall_wait_rate < 75 and qos.ping < self.settings.max_ping_to_eval_elapsed_time then
			local msg = string.format("%s的互动时间过短！\n在%i次互动中，有%i次过短。（其中%i次可能由网络问题引起）。\n他的同步率为%.1f%% （过低的值可能意味着作弊）。",
				profile.name, profile.persistent.timers_total, profile.persistent.timers_short, profile.persistent.network_prbs, overall_wait_rate)
			self:tell(msg)
		end
	end
end



function NoMA:check_inspire_cooldown(peer)
	local t = TimerManager:game():time()
	local profile = self:get_player_profile(peer)
	local cooldown = tweak_data.upgrades.values.cooldown.long_dis_revive[1][2]
	local dt = t - profile.inspire_t
	if dt < cooldown * 0.85 then
		logf('[NoMA] %s (%s) Inspire cooldown: %.1f sec instead of %.1f',
			profile.name, profile.skills, dt, cooldown)
		self:mark_cheater(peer, string.format('激励战吼冷却时间异常（对方为%.1f秒，正常为%.1f秒）', dt, cooldown))
	end
	profile.inspire_t = t
end



function NoMA:get_text_info(peer_id)
	local result = ''

	local profile = self.profiles[peer_id]
	if profile and profile.weapons then
		local crits = 0
		local total = 0
		for _, weapon in ipairs(profile.weapons) do
			if weapon.bonus_eval_counter then
				crits = crits + (weapon.bonus_eval_counter.critical_hit or 0)
				total = total + (weapon.bonus_eval_counter.total or 0)
			end
		end

		if crits > 0 then
			result = result .. string.format('暴击率：%.1f%%，射击了%i次， ',
				100 * crits / total, total)
		end
	end

	local hacc = self.hit_accounting[peer_id]
	if hacc and hacc.attacked_nr > 0 then
		result = result .. string.format('受击率：%0.1f%%，被射击了%i次（该项受无敌帧和闪避影响）',
			(hacc.health_hit_nr + hacc.armor_hit_nr) / hacc.attacked_nr * 100, hacc.attacked_nr)
	end

	return result
end

