-- CN trial: read actual crew data, never substitute player weapon statistics.
CN_AI_Weapon_Stats = CN_AI_Weapon_Stats or {}
local M = CN_AI_Weapon_Stats
M.difficulties = {"normal", "hard", "overkill", "overkill_145", "easy_wish", "overkill_290", "sm_wish"}
M.risks = {"risk_pd", "risk_swat", "risk_fbi", "risk_death_squad", "risk_easy_wish", "risk_murder_squad", "risk_sm_wish"}

local function copy(value, copies)
    if type(value) ~= "table" then return value end
    if copies[value] then return copies[value] end
    local result = {}
    copies[value] = result
    for key, child in pairs(value) do result[key] = copy(child, copies) end
    return setmetatable(result, getmetatable(value))
end

function M:crew_definitions(td)
    local result = {}
    for _, mod in pairs(BeardLib and BeardLib.Mods or {}) do
        if not mod._disabled then
            for _, module in pairs(mod._modules or {}) do
                local config = module._config and module._config.weapon
                if config and config.id and module.GetCrewBasedOn then
                    result[config.id] = {base = module:GetCrewBasedOn(td.weapon), crew = config.crew or {}}
                end
            end
        end
    end
    return result
end

function M:snapshot(td, difficulty, definitions)
    local valid = false
    for _, name in ipairs(self.difficulties) do valid = valid or name == difficulty end
    assert(valid, "Unknown preview difficulty")
    local copies = {[td] = td}
    -- Difficulty setters do not touch the factory. Avoid copying its asset database.
    if td.weapon.factory then copies[td.weapon.factory] = td.weapon.factory end
    local weapon = copy(td.weapon, copies)
    local character = copy(td.character, copies)
    local method = "_set_" .. difficulty
    if weapon[method] then weapon[method](weapon) end
    if character[method] then character[method](character) end
    -- BeardLib creates custom crew entries from a base during initialization. Some
    -- variants are not covered by Restoration's category loop. Carry forward only
    -- inherited scalar values that the difficulty setter has left unchanged;
    -- preserve explicit XML values and any differing CN customizations.
    definitions = definitions or self:crew_definitions(td)
    local done = {}
    local function inherit(id)
        if done[id] then return end
        done[id] = true
        local def = definitions[id]
        if not def then return end
        local base_id = def.base:match("^(.-)_crew$") or def.base:match("^(.-)_npc$")
        if base_id then inherit(base_id) end
        local previous, target = td.weapon[id .. "_crew"], weapon[id .. "_crew"]
        local old_base, new_base = td.weapon[def.base], weapon[def.base]
        if not previous or not target or not old_base or not new_base then return end
        for _, key in ipairs({"DAMAGE", "CLIP_AMMO_MAX", "custom_single_fire_rate"}) do
            if def.crew[key] == nil and previous[key] == old_base[key] and target[key] == previous[key] then
                target[key] = new_base[key]
            end
        end
        if previous.auto and target.auto and old_base.auto and new_base.auto and
            not (def.crew.auto and def.crew.auto.fire_rate ~= nil) and
            previous.auto.fire_rate == old_base.auto.fire_rate and target.auto.fire_rate == previous.auto.fire_rate then
            target.auto.fire_rate = new_base.auto.fire_rate
        end
    end
    for id in pairs(definitions) do inherit(id) end
    -- Retain crew entries only; release the large temporary player/enemy weapon copy.
    local crew = {}
    for id, data in pairs(weapon) do
        if type(id) == "string" and id:match("_crew$") then crew[id] = data end
    end
    return {weapon = crew, character = character, mappings = td.weapon_npc_mappings or {}, difficulty = difficulty}
end

function M:falloff(usage, distance)
    local ranges = usage.FALLOFF
    if not ranges or #ranges == 0 then return end
    for _, range in ipairs(ranges) do
        if distance <= range.r then return range end
    end
    return ranges[#ranges]
end

function M:stats(preview, id)
    if not preview or not id then return end
    local crew_id = preview.mappings[id]
    if not crew_id and preview.weapon[id .. "_crew"] then crew_id = id .. "_crew" end
    local weapon = crew_id and preview.weapon[crew_id]
    local russian = preview.character.russian
    local usage = weapon and russian and russian.weapon[weapon.usage]
    if not usage or type(weapon.DAMAGE) ~= "number" or not usage.FALLOFF then return end
    local auto = weapon.auto and usage.autofire_rounds
    local delay
    if auto then
        delay = weapon.auto.fire_rate or 0.1
    else
        -- Restoration single shots interpolate recoil by distance, including its custom override.
        local range = self:falloff(usage, 1500)
        local last = usage.FALLOFF[#usage.FALLOFF]
        local a = weapon.custom_single_fire_rate or range.recoil[1]
        local b = weapon.custom_single_fire_rate and weapon.custom_single_fire_rate * #usage.FALLOFF * 1.5 or range.recoil[2]
        delay = a + (b - a) * math.min(1, 1500 / last.r)
    end
    return {id = crew_id, damage = weapon.DAMAGE * 10, clip = weapon.CLIP_AMMO_MAX,
        rpm = delay and delay > 0 and 60 / delay or nil, automatic = not not auto,
        burst = auto and usage.autofire_rounds or nil, spread = usage.spread or 20,
        reload = usage.RELOAD_SPEED or 1, aim = usage.aim_delay or {0, 0}, usage = usage}
end

function M:at_range(stats, distance)
    local range = self:falloff(stats.usage, distance)
    if range then return stats.damage * (range.dmg_mul or 1), 100 * range.acc[2] end
end

function M:distances(preview)
    local found, result = {}, {}
    local russian = preview.character.russian
    for _, usage in pairs(russian and russian.weapon or {}) do
        if type(usage) == "table" and usage.FALLOFF then
            for _, range in ipairs(usage.FALLOFF) do
                if not found[range.r] then found[range.r] = true; result[#result + 1] = range.r end
            end
        end
    end
    table.sort(result)
    return result
end

function M:display_distances(equipped, selected, candidates)
    local found, result, stable_from = {}, {}, nil
    local function add(distance)
        if not found[distance] then found[distance] = true; result[#result + 1] = distance end
    end
    local function collect(stats)
        if not stats then return end
        local distances, seen = {}, {}
        for _, range in ipairs(stats.usage.FALLOFF) do
            if not seen[range.r] then seen[range.r] = true; distances[#distances + 1] = range.r end
        end
        -- Preserve the old table's sampling points when provided, so the first
        -- displayed changed value stays at the same distance after compression.
        for _, distance in ipairs(candidates or {}) do
            if not seen[distance] then seen[distance] = true; distances[#distances + 1] = distance end
        end
        table.sort(distances)
        local points, previous = {}, nil
        for _, distance in ipairs(distances) do
            local damage, chance = self:at_range(stats, distance)
            -- Match the precision of the displayed columns; floating point noise
            -- and changes invisible in the table should not generate extra rows.
            local signature = string.format("%.1f|%.0f", math.floor(damage * 10 + 0.50000001) / 10,
                math.floor(chance + 0.50000001))
            if signature ~= previous then
                points[#points + 1] = {r = distance, damage = damage}
                previous = signature
            end
        end
        local i = 1
        while i <= #points do
            local current, next_point = points[i], points[i + 1]
            local prior = points[i - 1]
            local j = i
            if next_point and (not prior or math.abs(current.damage - prior.damage) > 1e-8) then
                local direction = next_point.damage - current.damage
                if math.abs(direction) > 1e-8 then
                    while points[j + 1] and points[j + 1].r - points[j].r <= 100.001 and
                        (points[j + 1].damage - points[j].damage) * direction > 1e-8 do
                        j = j + 1
                    end
                end
            end
            add(current.r)
            if j >= i + 2 then
                -- A dense monotonic damage run: show its first changed value,
                -- five-metre checkpoints, and the point where it becomes stable.
                for distance = (math.floor(current.r / 500) + 1) * 500, points[j].r - 0.001, 500 do add(distance) end
                add(points[j].r)
                i = j + 1
            else
                i = i + 1
            end
        end
        if #points > 0 then stable_from = math.max(stable_from or 0, points[#points].r) end
    end
    collect(equipped)
    collect(selected)
    -- FALLOFF's last entry remains in use beyond its final node. It is not a
    -- firing-range cutoff. One final checkpoint makes that constant tail visible.
    if stable_from then add((math.floor(stable_from / 500) + 1) * 500) end
    table.sort(result)
    return result
end

function M:is_ai_page(data, override)
    data = data or {}
    local category = data.category
    local weapons = category == "primaries" or category == "secondaries"
    local tab = data[1]
    return (weapons and (not not data.custom_callback or not not override)) or
        (not not data.buying_weapon and tab and not tab.on_create_func_name and not not tab.on_create_func) or false
end
