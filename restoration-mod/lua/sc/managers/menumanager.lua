restoration._cop_comment_cooldown_t = {}

--Fix for Grenade Cases on Pro Jobs
function MenuPrePlanningInitiator:set_locks_to_param(params, key, index)
	local data = tweak_data:get_raw_value("preplanning", key, index) or {}
	local enabled = params.enabled ~= false
	params.tooltip = params.tooltip or {}
	params.tooltip.errors = params.tooltip.errors or {}

	if data.dlc_lock and not Global.game_settings and Global.game_settings.one_down then
		local dlc_unlocked = managers.dlc:is_dlc_unlocked(data.dlc_lock)

		if not dlc_unlocked then
			local error_text_id = tweak_data:get_raw_value("lootdrop", "global_values", data.dlc_lock, "unlock_id")

			table.insert(params.tooltip.errors, managers.localization:to_upper_text(error_text_id))

			enabled = false
		end
	elseif data.upgrade_lock then
		local upgrade_unlocked = managers.player:has_category_upgrade(data.upgrade_lock.category, data.upgrade_lock.upgrade)

		if not upgrade_unlocked then
			table.insert(params.tooltip.errors, managers.localization:to_upper_text("menu_asset_lock_" .. data.upgrade_lock.upgrade))

			enabled = false
		end
	end

	params.enabled = enabled
	params.ignore_disabled = true
end

--Allow Chat in Crime.net Offline
function MenuManager:toggle_chatinput()
	if Application:editor() or SystemInfo:platform() ~= Idstring("WIN32") or self:active_menu() or not managers.network:session() then
		return
	end
	if managers.hud then
		managers.hud:toggle_chatinput()
		return true
	end
end	

function MenuJukeboxHeistTracks:modify_node(node, data)
	managers.menu_component:show_contract_character(false)
	node:clean_items()

	local track_list, track_locked = managers.music:jukebox_music_tracks()
	local option_data = {
		type = "MenuItemMultiChoiceWithIcon"
	}

	table.insert(option_data, {
		value = "all",
		text_id = "menu_jukebox_playlist_all",
		_meta = "option"
	})
	table.insert(option_data, {
		value = "playlist",
		text_id = "menu_jukebox_random_heist_playlist",
		_meta = "option"
	})

	for _, track_name in pairs(track_list) do
		if not track_locked[track_name] then
			table.insert(option_data, {
				_meta = "option",
				text_id = "menu_jukebox_" .. track_name,
				value = track_name
			})
		end
	end

	local track_list = {}
	local unique_jobs = {}

	for _, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_tweak = tweak_data.narrative:job_data(job_id)

		if self:_have_music(job_id) and not table.contains(unique_jobs, job_tweak.name_id) then
			local text_id, color_ranges = tweak_data.narrative:create_job_name(job_id, true)
			local days = #tweak_data.narrative:job_chain(job_id)

			table.insert(unique_jobs, job_tweak.name_id)

			if days > 1 then
				for i = 1, days, 1 do
					table.insert(track_list, {
						job_id = job_id,
						name_id = job_tweak.name_id,
						day = i,
						sort_id = text_id,
						text_id = text_id .. " - " .. managers.localization:text("menu_jukebox_heist_day", {
							day = i
						}),
						color_ranges = color_ranges
					})
				end
			else
				table.insert(track_list, {
					job_id = job_id,
					name_id = job_tweak.name_id,
					sort_id = text_id,
					text_id = text_id,
					color_ranges = color_ranges
				})
			end
		end
	end

	table.sort(track_list, function (x, y)
		return x.sort_id == y.sort_id and x.text_id < y.text_id or x.sort_id < y.sort_id
	end)
	table.insert(track_list, {
		name_id = "escape",
		job_id = "escape",
		text_id = managers.localization:text("menu_jukebox_heist_escape")
	})
	table.insert(track_list, {
		name_id = "ponr",
		job_id = "ponr",
		text_id = managers.localization:text("menu_jukebox_heist_ponr")
	})

	for _, track_data in pairs(track_list) do
		local heist_name = track_data.name_id .. (track_data.day and track_data.day or "")
		local params = {
			localize = "false",
			align = "left",
			callback = "jukebox_option_heist_tracks",
			text_offset = 100,
			name = heist_name,
			text_id = track_data.text_id,
			color_ranges = track_data.color_ranges,
			heist_job = track_data.job_id,
			heist_days = track_data.day,
			icon = tweak_data.hud_icons:get_icon_data("jukebox_playing_icon")
		}
		local item = node:create_item(option_data, params)

		item:set_value(managers.music:track_attachment(heist_name) or "all")
		node:add_item(item)
	end

	managers.menu:add_back_button(node)

	return node
end

function MenuCallbackHandler:jukebox_option_heist_tracks(item)
	local track = item:value()
	local job = item:parameters().heist_job

	if job == "escape" or job == "ponr" then
		managers.music:track_attachment_add(job, track)
	else
		local job_tweak = tweak_data.narrative.jobs[job]

		if not job_tweak then
			return
		end

		local day = item:parameters().heist_days and item:parameters().heist_days or ""

		managers.music:track_attachment_add(job_tweak.name_id .. day, track)
	end

	local item_list = managers.menu:active_menu().logic:selected_node():items()

	for _, item_data in ipairs(item_list) do
		if item_data.set_icon_visible then
			item_data:set_icon_visible(false)
		end
	end

	if track ~= "all" and track ~= "playlist" then
		managers.music:track_listen_start("music_heist_assault", track)
		item:set_icon_visible(true)
	else
		managers.music:track_listen_stop()
	end

	managers.savefile:setting_changed()
end

function restoration:_game_t()
	return TimerManager:game():time()
end

function restoration:start_inform_ene_cooldown(cooldown_t, msg_type)
	local t = self:_game_t()
	self._cop_comment_cooldown_t[msg_type] = self._cop_comment_cooldown_t[msg_type] or {}
	self._cop_comment_cooldown_t[msg_type]._cooldown_t = cooldown_t + t
	self._cooldown_delay_t = t + 5
end

function restoration:ene_inform_has_cooldown_met(msg_type)
	local t = TimerManager:game():time()
	
	if not self._cop_comment_cooldown_t[msg_type] then
		return true
	end
	
	if self._cooldown_delay_t and self._cooldown_delay_t > t then
		return false
	end
	
	if self._cop_comment_cooldown_t[msg_type]._cooldown_t < t then
		return true
	end
	
	return false
end


function restoration:_has_deployable_type(unit, deployable)
	local peer_id = managers.criminals:character_peer_id_by_unit(unit)
	if not peer_id then
		return false
	end
	
	local synced_deployable_equipment = managers.player:get_synced_deployable_equipment(peer_id)
	
	if synced_deployable_equipment then
	
		if not synced_deployable_equipment.deployable or synced_deployable_equipment.deployable ~= deployable then
			return false
		end
		
		--[[if synced_deployable_equipment.amount and synced_deployable_equipment.amount <= 0 then
			return false
		end]]--
		
		
		return true		
	end
	
	return false
end

function restoration:_next_to_cops(data, amount)
	local close_peers = {}
	local range = 5000
	amount = amount or 4
	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		if data.key ~= u_key then
			if u_data.unit and alive(u_data.unit) and not u_data.unit:character_damage():dead() then
				local anim_data = u_data.unit:anim_data()
				if not anim_data.surrender and not anim_data.hands_tied and not anim_data.hands_back then
					if mvector3.distance_sq(data.m_pos, u_data.m_pos) < range * range then
						table.insert(close_peers, u_data.unit)
					end
				end
			end
		end
	end
	return #close_peers >= amount
end

function restoration:inform_law_enforcements(data, debug_enemy)
	if managers.groupai:state()._special_unit_types[data.unit:base()._tweak_table] then
		return
	end
	if data.unit:in_slot(16) or not data.char_tweak.chatter then
		return
	end
	
	local sound_name, cooldown_t, msg_type
	local enemy_target = data.attention_obj
	
	if debug_enemy then
		enemy_target = {
			unit = debug_enemy,
			dis = 0,
			is_deployable = false
		}	
	end
	
	if enemy_target then
		if enemy_target.is_deployable then
			msg_type = "sentry_detected"
			sound_name = "ch2"
			cooldown_t = 30
		elseif enemy_target.unit:in_slot(managers.slot:get_mask("all_criminals")) then
			local weapon = enemy_target.unit.inventory and enemy_target.unit:inventory():equipped_unit()
			if weapon and weapon:base():is_category("saw") then
				msg_type = "saw_maniac"
				sound_name = "ch4"
				cooldown_t = 30
			elseif self:_has_deployable_type(enemy_target.unit, "doctor_bag") then
				msg_type = "doc_bag"
				sound_name = "med"
				cooldown_t = 30
				--log("they have a medic >:c")
			elseif self:_has_deployable_type(enemy_target.unit, "first_aid_kit") then
				msg_type = "first_aid_kit"
				sound_name = "med"
				cooldown_t = 30
				--log("they have a medic >:c")
			elseif self:_has_deployable_type(enemy_target.unit, "ammo_bag") then
				msg_type = "ammo_bag"
				sound_name = "amm"
				cooldown_t = 30
				--log("they have an ammy bag")
			elseif self:_has_deployable_type(enemy_target.unit, "trip_mine") then
				msg_type = "trip_mine"
				sound_name = "ch1"
				cooldown_t = 30
				--log("watch out for the trip mines")
			end
		end
	end
	
	if self:_next_to_cops(data) then
		return
	end
	
	if not enemy_target or enemy_target.dis > 100000 then
		return
	end
	
	if not msg_type or not self:ene_inform_has_cooldown_met(msg_type) then
		return
	end
	
	if data.unit then
		data.unit:sound():say(sound_name, true)
		self:start_inform_ene_cooldown(cooldown_t, msg_type)
	end
end

--[[
Hooks:Add("radialmenu_released_resutilitymenu","resmod_utility_menu_on_selected",function(item)
	if item == 1 then 
				
		local loss_rate = 0.0
		local placement_cost = 0.3
		local ammo_ratio_taken = 0
		local player = managers.player:local_player()
		if player and alive(player) then 
			for index, weapon in pairs(player:inventory():available_selections()) do
				local ammo_taken = weapon.unit:base():remove_ammo(1 - placement_cost)
				ammo_ratio_taken = ammo_ratio_taken + (ammo_taken / weapon.unit:base():get_ammo_max())
--					Log("ammo_ratio_taken: " .. ammo_ratio_taken)
			
				managers.hud:set_ammo_amount(index, weapon.unit:base():ammo_info())
				
			end
			local pos = player:position()
			
			local angle = player:movement():m_head_rot():y()
			local rot = Rotation(angle, angle, 0)
			
			local ammo_upgrade_lvl = 0 --managers.player:upgrade_level("ammo_bag", "ammo_increase")
			local bullet_storm_level = 0 -- managers.player:upgrade_level("player", "no_ammo_cost")

			local function concat(div,...) --yeah that's right i'm too good for table.concat
				local result
				for _,value in pairs({...}) do
					if result then 
						result = result .. div .. tostring(value)
					else
						result = tostring(value)
					end
				end
				return result
			end
			if Network:is_client() then
--						managers.network:session():send_to_host("place_ammo_bag", pos, rot, ammo_upgrade_lvl, bullet_storm_level)
				--use networking instead
				
				LuaNetworking:SendToPeer(1,"restoration_drop_ammo",concat(":",pos.x,pos.y,pos.z,rot:x(),rot:y(),rot:z(),ammo_ratio_taken))
			else
			
				local unit = AmmoBagBase.spawn(pos, rot, ammo_upgrade_lvl, managers.network:session():local_peer():id(), bullet_storm_level)
				unit:base()._ammo_amount = math.floor(math.min(ammo_ratio_taken,placement_cost) * (1 - loss_rate) * 100) / 100
				local current_amount = unit:base()._ammo_amount
				unit:base():_set_visual_stage()
				managers.network:session():send_to_peers_synched("sync_ammo_bag_ammo_taken", unit, current_amount - ammo_ratio_taken)
--					Log("amount: " .. tostring(unit:base()._ammo_amount))
--					LuaNetworking:SendToPeer(1,"restoration_drop_ammo",concat(":",pos.x,pos.y,pos.z,rot:yaw(),rot:pitch(),rot:roll(),ammo_ratio_taken))
				
			end
		elseif item == 2 or item == 3 then 
			local equipped_deployable = managers.blackmarket:equipped_deployable()
			if equipped_deployable == "tripmines" then 
--					Log("Equipped tripmines")
			elseif equipped_deployable == "sentry_gun" then 
--					Log("Equipped sentrygun")
			end
		end
	end
end)
]]

-- if restoration.Options:GetValue("OTHER/PDTHChallenges") then

Hooks:PostHook(MenuManager, "do_clear_progress", "pdth_hud_reset_challenges", function(ply)
	managers.challenges_res:reset_challenges()
end)

-- end

function MenuCallbackHandler:accept_skirmish_contract(item)
    local node = item:parameters().gui_node.node

    managers.menu:active_menu().logic:navigate_back(true)
    managers.menu:active_menu().logic:navigate_back(true)

    local job_id = (node:parameters().menu_component_data or {}).job_id
    local job_data = {
        difficulty = "overkill_290",
        customize_contract = true,
        job_id = job_id or managers.skirmish:random_skirmish_job_id(),
        difficulty_id = tweak_data:difficulty_to_index("overkill_290")
    }

    managers.job:on_buy_job(job_data.job_id, job_data.difficulty_id)

    if Global.game_settings.single_player then
        MenuCallbackHandler:start_single_player_job(job_data)
    else
        MenuCallbackHandler:start_job(job_data)
    end
end

function MenuCallbackHandler:accept_skirmish_weekly_contract(item)
    managers.menu:active_menu().logic:navigate_back(true)
    managers.menu:active_menu().logic:navigate_back(true)

    local weekly_skirmish = managers.skirmish:active_weekly()
    local job_data = {
        difficulty = "overkill_290",
        weekly_skirmish = true,
        job_id = weekly_skirmish.id
    }

    if Global.game_settings.single_player then
        MenuCallbackHandler:start_single_player_job(job_data)
    else
        MenuCallbackHandler:start_job(job_data)
    end
end

function MenuChooseWeaponRewardInitiator:modify_node(original_node, data)
	local node = original_node

	if data and data.reward_data then
		node:parameters().reward_data = data.reward_data
	end

	local all_dlc_data = Global.dlc_manager.all_dlc_data
	local weapon_tweak = tweak_data.weapon
	local x_id, y_id, x_level, y_level, x_unlocked, y_unlocked, x_skill, y_skill, x_gv, y_gv, x_sn, y_sn = nil
	local primaries = managers.blackmarket:get_weapon_category("primaries")
	local secondaries = managers.blackmarket:get_weapon_category("secondaries")
	local items = {}

	local function chk_unlocked_func(weapon)
		return not not weapon.unlocked
	end

	local function chk_dlc_func(weapon)
		x_id = weapon.weapon_id
		x_gv = weapon_tweak[x_id].global_value

		if all_dlc_data[x_gv] and all_dlc_data[x_gv].app_id and not managers.dlc:is_dlc_unlocked(x_gv) then
			return false
		end

		return true
	end

	local function chk_dropable_func(weapon)
		local loot_table = managers.blackmarket:get_lootdropable_mods_by_weapon_id(weapon.weapon_id, nil, true)

		return loot_table and #loot_table > 0 or false
	end

	local function chk_parent_func(weapon)
		return weapon_tweak[weapon.weapon_id] and not weapon_tweak[weapon.weapon_id].parent_weapon_id
	end

	local loot_table, data = nil

	for i, category_data in ipairs({
		primaries,
		secondaries
	}) do
		for _, weapon_data in ipairs(category_data) do
			if chk_dlc_func(weapon_data) and chk_parent_func(weapon_data) then
				loot_table = managers.blackmarket:get_lootdropable_mods_by_weapon_id(weapon_data.weapon_id, nil, true)

				if #loot_table > 0 then
					data = deep_clone(weapon_data)
					data.loot_table = loot_table

					for _, category in ipairs(weapon_tweak[weapon_data.weapon_id].categories) do

						local real_categories = {
							"akimbo",

							"assault_rifle",
							"snp",

							"smg",
							"lmg",

							"pistol",
							"revolver",

							"shotgun",

							"bow",
							"crossbow",
							"grenade_launcher",
							"saw",
							"minigun",
							"flamethrower"
						}

						for i, real_category in ipairs(real_categories) do
							if category == real_category then
								--log("real_category: " .. tostring(real_category))
								category = tweak_data.gui.buy_weapon_category_aliases[category] or category
								items[category] = items[category] or {}
								table.insert(items[category], data)
							end
						end
					end

				end
			end
		end
	end

	local function sort_func(x, y)
		x_unlocked = x.unlocked
		y_unlocked = y.unlocked

		if x_unlocked ~= y_unlocked then
			return x_unlocked
		end

		x_id = x.weapon_id
		y_id = y.weapon_id
		x_gv = weapon_tweak[x_id].global_value
		y_gv = weapon_tweak[y_id].global_value
		x_sn = x_gv and tweak_data.lootdrop.global_values[x_gv].sort_number or 0
		y_sn = y_gv and tweak_data.lootdrop.global_values[y_gv].sort_number or 0

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		x_skill = x.skill_based
		y_skill = y.skill_based

		if x_skill ~= y_skill then
			return y_skill
		end

		x_level = x.level or 0
		y_level = y.level or 0

		if x_level ~= y_level then
			return x_level < y_level
		end

		return x_id < y_id
	end

	local category_list = {}

	for category, data in pairs(items) do
		table.sort(data, sort_func)
		table.insert(category_list, category)
	end

	table.sort(category_list)

	node:parameters().first_weapons = {}

	for index, category in ipairs(category_list) do
		node:parameters().first_weapons[category] = items[category][1].weapon_id
	end

	node:parameters().category_list = category_list
	node:parameters().weapon_items = items
	node = self:setup_node(node)

	node:set_default_item_name("choose_weapon_category")
	node:select_item("choose_weapon_category")

	return node
end


if VakaraAmmoGui then
	function VakaraAmmoGui:set_zoom(amount)
		if alive(self._scope_zoom_counter) then 
			self._scope_zoom_counter:set_text(string.format("%.01fx",amount / 2))
		end
	end
end


-- LuaNetworking Receiver  --本来应该是治疗枪的同步，但是把该同步的都放在这了
Global.Daring_heal_attch_check = Global.Daring_heal_attch_check or ''
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_Daring_sc_heal_player", function(sender, id, data)
	local function ResMod_get_PeerUnit_by_PeerID(peer_id)
		local peer = managers.network:session():peer(peer_id)
		if peer then
			return peer:unit()
		end
	end

    local table_get_from_data = {}
    if data then
        table_get_from_data = json.decode(data)
    end
	-- 应该是检测配件确认治疗枪的存在的
    if id == "Resmod_Daring_heal_num" then
        if table_get_from_data and table_get_from_data.attchment then
            Global.Daring_heal_attch_check = table_get_from_data.attchment
		end
	-- 应该是为了改善专家模式不同步的问题，不确定是否有用
	elseif id == 'Resmod_Daring_is_pro_fixed_sync' then
		local is_pro = Global.game_settings and Global.game_settings.one_down
		if Network:is_server() then
			return
		elseif Network:is_client() then
			if table_get_from_data and table_get_from_data.session then
				if table_get_from_data.session == 'host' then
					local is_pro = Global.game_settings and Global.game_settings.one_down
					local match = 'wait'
					if is_pro then
						match = 'true'
					elseif Global.game_settings and not Global.game_settings.one_down then
						match = 'nil'
					end
					if table_get_from_data.is_pro ~= match then
						if table_get_from_data.is_pro == 'true' then
							if Global.game_settings then
								Global.game_settings.one_down = true
							end
						elseif table_get_from_data.is_pro == 'nil' then
							if Global.game_settings then
								Global.game_settings.one_down = false
							end
						end
					end
				end
			end
		end
	-- HD2战备光束的同步
	elseif id == "sync_hd2offensive_red_trail" then
		table_get_from_data.position = Vector3(table_get_from_data.x, table_get_from_data.y, table_get_from_data.z)

		if HD2OffensiveRedTrail then
			--HD2OffensiveRedTrail:spawn(table_get_from_data)  --没有执行的必要
		elseif HD2OffensiveRedTrail_res then
			HD2OffensiveRedTrail_res:spawn(table_get_from_data)
		else
			managers.mission._fading_debug_output:script().log("HD2OffensiveRedTrail not found!", Color.red)
		end
	elseif message == "sync_hd2offensive_hud" then
		table_get_from_data.position = Vector3(table_get_from_data.x, table_get_from_data.y, table_get_from_data.z)
		
		if HD2OffensiveHUD then
			HD2OffensiveHUD:new(table_get_from_data)
		elseif HD2OffensiveHUD_res then
			HD2OffensiveHUD_res:new(table_get_from_data)
		else
			managers.mission._fading_debug_output:script().log("HD2OffensiveHUD not found!", Color.red)
		end
	-- 同步播放近战反击产生的昊京音效
	elseif id == "HaoJing_Played" then
		local HaoJing_Sync = restoration and restoration.Options:GetValue("OTHER/HaoJing/DaringHaoJingSync")
		local Volume_Sync = restoration and restoration.Options:GetValue("OTHER/HaoJing/SyncHaoJingVolume")

		if HaoJing_Sync then
			local ogg_path
			if SC and SC._path then
				ogg_path = SC._path .. "assets/oggs/haojing/szyf.ogg"
			end
			if ogg_path then
				local unit_play = ResMod_get_PeerUnit_by_PeerID(sender)
				blt.xaudio.setup()
				local source =  XAudio.UnitSource:new(unit_play, XAudio.Buffer:new(ogg_path))
				source:set_volume(Volume_Sync)
			end
		end
	end
end)

-- 接下来的内容是为了修改第三方天赋“解放者”的运作方式以做适配
if not BeardLib or not BeardLib.Utils or not BeardLib.Utils:FindMod("Liberator Perk Deck") then
	return
end

-- 获取mod路径
local file_path
local root_path_result = BeardLib.Frameworks.Base._directory  --通过Beardlib获取mods路径
if root_path_result then
	file_path = root_path_result .. "/Liberator Perk Deck/scripts/playeractiontachi.lua"  --获取解放者天赋的路径
end
if not file_path then
	return
end

-- 要追加的内容
local new_content = "\n\n"..[[
if SC and ChinStringFixes then
    PlayerAction.Tachi = {
        Priority = 1,
        Function = function()
            local pm = managers.player
            
            local base_upgrade_data = pm:upgrade_value("player","tachi_base")
            local timer = TimerManager:game()
            local player = pm:local_player()
            if not alive(player) then 
                return
            end
            local dmg_ext = player:character_damage()
            local start_t = timer:time()
            local regen_interval = base_upgrade_data.regen_interval
            local hot_amount = pm:upgrade_value("player","tachi_hot_amount",0)
            local hot_duration = pm:upgrade_value("player","tachi_hot_duration",0)
            local end_time = start_t + hot_duration
            local has_dmg_resist = pm:has_category_upgrade("player","tachi_hot_cancelled_damage_resistance_consolation")
            local dmg_resist = pm:upgrade_value("player","tachi_hot_cancelled_damage_resistance_consolation",0)

            local function update_ability_radial()
                local time_left = end_time - timer:time()

                managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, time_left, hot_duration)
            end
            
            local has_taken_health_damage = false
            local regen_first_hit_health = false
            local hit_regen = 0
            local cached_player_health = dmg_ext:get_real_health()
            local function cb_on_damage()
                if not has_taken_health_damage then
                    local current_hp = dmg_ext:get_real_health()
                    if current_hp < cached_player_health then
                        has_taken_health_damage = true
                        hit_regen = cached_player_health - current_hp
                    else
                        cached_player_health = current_hp
                    end
                end
            end
            dmg_ext._listener_holder:add(
                "liberator_tachi_on_damage",
                {
                    "on_damage"
                },
                cb_on_damage
            )
            
            local next_heal_t = start_t
            
            update_ability_radial()
            while alive(player) and timer:time() < end_time do 
            
                local t = timer:time()
                if t >= next_heal_t then 
                    next_heal_t = next_heal_t + regen_interval
                    if not has_taken_health_damage then
                        dmg_ext:restore_health(hot_amount,true,false)
                    elseif not regen_first_hit_health then
                        dmg_ext:restore_health(hit_regen,true,false)
                        regen_first_hit_health = true
                    elseif has_dmg_resist then
                        pm:set_property("tachi_damage_resistance",dmg_resist)
                    end
                end
                coroutine.yield()
            end
            
            
            managers.hud:set_teammate_ability_radial(HUDManager.PLAYER_PANEL, {current=0,total=1})
            dmg_ext._listener_holder:remove("liberator_tachi_on_damage")
            pm:remove_property("tachi_damage_resistance")
        end
    }
end
]]

-- 检测文件是否存在
local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- 如果文件不存在，则直接跳过
if not file_exists(file_path) then
    --log("Mod file not found: " .. file_path)
    return
end

-- 读取文件内容
local file = io.open(file_path, "r")
if not file then
    --log("Failed to open file for reading: " .. file_path)
    return
end

local original_content = file:read("*a") -- 读取整个文件内容
file:close()

-- 检查文件尾部是否已有要添加的内容
if original_content:sub(-#new_content) == new_content then
    --log("check exist, no repeating")
else
    -- 追加内容到文件末尾
    file = io.open(file_path, "a")
    if not file then
        --log("Failed to open file for writing: " .. file_path)
        return
    end
    file:write(new_content)
    file:close()
    --log("suc added")
end
