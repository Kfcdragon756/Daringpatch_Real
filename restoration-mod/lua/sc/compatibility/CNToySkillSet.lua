-- The three-piece toy set grants the union of learnable skills, not skill points.
-- Use real upgrade acquisition so cached effects and normal peer sync see it too.
_G.CNToySkillSet = _G.CNToySkillSet or {}
local T = CNToySkillSet
T.source = "CN_ToySkillSet"
-- These names collide with upgrade keys but are queries/pickup actions, not
-- acquisition setters. In particular, restoring a passive skill is not a pickup.
local non_setters = {movement_speed_multiplier = true, regain_throwable_from_ammo = true}

local function pack(...)
	return {n = select("#", ...), ...}
end

local function copy_cooldowns(source)
	local result = {}
	for category, upgrades in pairs(source) do
		result[category] = clone(upgrades) -- Keep real running cooldown objects.
	end
	return result
end

local function keep_running_cooldowns(target, running)
	for category, upgrades in pairs(running or {}) do
		for key, timer in pairs(upgrades) do
			local current = target[category] and target[category][key]
			if current and timer.cooldown_time >= current.cooldown_time then target[category][key] = timer end
		end
	end
end

local function replace_contents(target, source)
	for key in pairs(target) do target[key] = nil end
	for key, value in pairs(source) do target[key] = value end
end

function T:equipped()
	local bm = managers.blackmarket
	if not bm or not bm._global or not bm._global.armors or not bm._global.armors.level_7 then return false end
	local primary, secondary = bm:equipped_primary(), bm:equipped_secondary()
	return primary and primary.weapon_id == "toym16" and secondary and secondary.weapon_id == "toy1911"
		and bm:equipped_melee_weapon() == "toyknife" or false
end

function T:catalog()
	if self.ids then return self.ids end
	local ids, seen = {}, {}
	for _, tree in ipairs(tweak_data.skilltree.trees) do
		for _, tier in ipairs(tree.tiers) do
			for _, skill_id in ipairs(tier) do
				local skill = tweak_data.skilltree.skills[skill_id]
				for step = 1, 2 do
					for _, id in ipairs(skill[step].upgrades or {}) do
						if not seen[id] then
							seen[id] = true
							ids[#ids + 1] = id
						end
					end
				end
			end
		end
	end
	self.ids = ids
	return ids
end

-- Do not decrement upgrades one by one here. Vanilla's unaquire can decrement a
-- higher real level while removing a lower temporary level of the same upgrade.
function T:restore(pm, callbacks, leaving_set)
	if not callbacks or leaving_set then pm._cn_toy_running = nil end
	local g = pm._global or Global.player_manager
	local state = g and g._cn_toy_skills
	if not state then return end
	if callbacks and not leaving_set then pm._cn_toy_running = copy_cooldowns(g.cooldown_upgrades) end
	g._cn_toy_skills = nil
	local changed = {}
	if callbacks then
		for category, upgrades in pairs(g.upgrades) do
			for key, level in pairs(upgrades) do
				local previous = state.upgrades[category] and state.upgrades[category][key]
				if level ~= previous and not non_setters[key] and type(pm[key]) == "function" then
					changed[#changed + 1] = {category, key, previous}
				end
			end
		end
	end
	local had_second = g.upgrades.player and g.upgrades.player.second_deployable
	replace_contents(g.upgrades, state.upgrades)
	replace_contents(g.synced_upgrades, state.synced)
	replace_contents(g.team_upgrades, state.team)
	replace_contents(g.cooldown_upgrades, state.cooldowns)
	local acquired = Global.upgrades_manager and Global.upgrades_manager.aquired
	local source_key = Idstring(self.source):key()
	for _, id in ipairs(state.ids) do
		if acquired and acquired[id] then
			acquired[id][source_key] = nil
			if not next(acquired[id]) then acquired[id] = nil end
		end
	end
	local armors = Global.blackmarket_manager and Global.blackmarket_manager.armors
	for id, previous in pairs(state.armors) do
		local armor = armors and armors[id]
		if armor then
			if leaving_set and not previous.unlocked and armor.equipped then
				managers.blackmarket:on_unaquired_armor(previous.definition, id)
			end
			armor.unlocked, armor.owned = previous.unlocked, previous.owned
		end
	end
	for _, entry in ipairs(changed) do
		local values = tweak_data.upgrades.values[entry[1]][entry[2]]
		pm[entry[2]](pm, entry[3] and values[entry[3]] or nil)
	end
	if leaving_set and had_second and not (g.upgrades.player and g.upgrades.player.second_deployable) then
		pm:set_equipment_in_slot(nil, 2)
	end
end

function T:ensure(pm)
	if not pm or not pm._cn_toy_ready or pm._cn_toy_busy or not managers.upgrades then return end
	local equipped = self:equipped()
	if not equipped then pm._cn_toy_running = nil end
	local state = pm._global._cn_toy_skills
	if equipped == (state ~= nil) then return end
	pm._cn_toy_busy = true
	if not equipped then
		self:restore(pm, true, true)
	else
		local g = pm._global
		keep_running_cooldowns(g.cooldown_upgrades, pm._cn_toy_running)
		state = {
			upgrades = deep_clone(g.upgrades), synced = deep_clone(g.synced_upgrades),
			team = deep_clone(g.team_upgrades), cooldowns = copy_cooldowns(g.cooldown_upgrades),
			ids = {}, armors = {}
		}
		g._cn_toy_skills = state
		for _, id in ipairs(self:catalog()) do
			-- In particular, never acquire an already learned incremental upgrade.
			if not managers.upgrades:aquired(id) then
				local definition = tweak_data.upgrades.definitions[id]
				if definition.category == "armor" then
					local armor = managers.blackmarket._global.armors[definition.armor_id]
					state.armors[definition.armor_id] = {unlocked = armor.unlocked, owned = armor.owned, definition = definition}
				end
				state.ids[#state.ids + 1] = id
				local key = definition.upgrade and definition.upgrade.upgrade
				-- Vanilla dispatches same-named methods as acquisition setters.
				-- Do not run a movement/HUD query while registering its passive skill.
				local suppressed = non_setters[key]
				local non_setter = suppressed and rawget(pm, key)
				if suppressed then pm[key] = false end
				managers.upgrades:aquire(id, true, self.source)
				if suppressed then pm[key] = non_setter end
			end
		end
		keep_running_cooldowns(g.cooldown_upgrades, pm._cn_toy_running)
		pm._cn_toy_running = nil
	end
	pm._cn_toy_busy = nil
end

-- Real skill/perk changes must operate on the real build, never the toy layer.
function T:mutate(pm, original, object, ...)
	if not pm or pm._cn_toy_busy then return original(object, ...) end
	pm._cn_toy_busy = true
	self:restore(pm, true, false)
	local result = pack(original(object, ...))
	pm._cn_toy_busy = nil
	return unpack(result, 1, result.n)
end

local script = RequiredScript and RequiredScript:lower()
if script == "lib/managers/playermanager" and not T.player_installed then
	T.player_installed = true
	Hooks:PreHook(PlayerManager, "_setup", "CN_ToySkillsRestoreBeforeSetup", function(self)
		-- Global survives scene changes; manager instances and cached callbacks do not.
		T:restore(self, false, false)
	end)
	Hooks:PostHook(PlayerManager, "init", "CN_ToySkillsReady", function(self)
		self._cn_toy_ready = true
	end)
	for _, name in ipairs({"has_category_upgrade", "upgrade_value", "upgrade_value_nil", "upgrade_level", "upgrade_level_nil", "team_upgrade_value", "has_team_category_upgrade", "is_upgrade_synced"}) do
		local original = PlayerManager[name]
		PlayerManager[name] = function(self, ...)
			T:ensure(self)
			return original(self, ...)
		end
	end
	function PlayerManager:wpn_is_138_max()
		return T:equipped()
	end
	for _, name in ipairs({"check_skills", "_internal_load", "update_team_upgrades_to_peers", "update_team_upgrades_to_peer"}) do
		Hooks:PreHook(PlayerManager, name, "CN_ToySkillsBefore_" .. name, function(self) T:ensure(self) end)
	end
	for _, name in ipairs({"aquire_upgrade", "unaquire_upgrade", "aquire_incremental_upgrade", "unaquire_incremental_upgrade", "aquire_team_upgrade", "unaquire_team_upgrade", "aquire_cooldown_upgrade", "unaquire_cooldown_upgrade"}) do
		local original = PlayerManager[name]
		PlayerManager[name] = function(self, ...) return T:mutate(self, original, self, ...) end
	end
	for _, name in ipairs({"aquire", "aquire_default", "unaquire"}) do
		local original = UpgradesManager[name]
		UpgradesManager[name] = function(self, ...) return T:mutate(managers.player, original, self, ...) end
	end
elseif script == "lib/managers/blackmarketmanager" and not T.blackmarket_installed then
	T.blackmarket_installed = true
	for _, name in ipairs({"equip_weapon", "equip_weapon_in_game", "equip_melee_weapon"}) do
		local original = BlackMarketManager[name]
		BlackMarketManager[name] = function(self, ...)
			local was_equipped = T:equipped()
			local result = pack(original(self, ...))
			local pm = managers.player
			T:ensure(pm)
			if pm and pm._cn_toy_ready and was_equipped ~= T:equipped() then pm:check_skills() end
			return unpack(result, 1, result.n)
		end
	end
	Hooks:PostHook(BlackMarketManager, "load", "CN_ToySkillsAfterLoad", function() T:ensure(managers.player) end)
elseif script == "lib/units/beings/player/playerbase" and not T.base_installed then
	T.base_installed = true
	for _, name in ipairs({"sync_unit_upgrades", "save"}) do
		Hooks:PreHook(PlayerBase, name, "CN_ToySkillsBefore_" .. name, function() T:ensure(managers.player) end)
	end
end
