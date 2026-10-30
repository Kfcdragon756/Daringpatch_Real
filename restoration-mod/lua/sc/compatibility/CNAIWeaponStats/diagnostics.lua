-- AI statistics diagnostics use a separate append-only session file, independent of BLT's log.
local M = CN_AI_Weapon_Stats

function M:init_diagnostics(save_path)
    if self._diagnostic_path or not save_path then return end
    local directory = save_path .. "CN_AI_Weapon_Stats/"
    local ok = pcall(function()
        if file and file.CreateDirectory then file.CreateDirectory(directory) end
        self._diagnostic_path = directory .. "trial-" .. os.date("%Y%m%d-%H%M%S") .. ".log"
    end)
    if not ok then self._diagnostic_path = nil end
end

function M:log_event(event, fields)
    -- Logging failures must not interrupt the menu or change a weapon's data.
    pcall(function()
        local parts = {os.date("%Y-%m-%d %H:%M:%S"), event}
        local keys = {}
        for key in pairs(fields or {}) do keys[#keys + 1] = key end
        table.sort(keys)
        for _, key in ipairs(keys) do
            parts[#parts + 1] = key .. "=" .. tostring(fields[key]):gsub("\r", "\\r"):gsub("\n", "\\n")
        end
        local line = table.concat(parts, " | ")
        if log then log("[CN AI Weapon Stats] " .. line) end
        if self._diagnostic_path then
            local handle = io.open(self._diagnostic_path, "a")
            if handle then handle:write(line .. "\n"); handle:close() end
        end
    end)
end

function M:describe_stats(preview, player_id, stats)
    if not stats then return tostring(player_id) .. ": unavailable" end
    local weapon = preview.weapon[stats.id]
    local live_weapon = tweak_data.weapon[stats.id]
    local live_usage = live_weapon and tweak_data.character.russian.weapon[live_weapon.usage]
    local live_aim = live_usage and live_usage.aim_delay
    local live_aim_text = live_aim and string.format("%.4f,%.4f", live_aim[1], live_aim[2]) or "missing"
    local last_range = stats.usage.FALLOFF[#stats.usage.FALLOFF]
    return string.format("%s -> %s; usage=%s; aim=%.4f,%.4f; aim_explicit=%s; live_aim=%s; damage=%.4f; clip=%s; rpm=%s; last_node_m=%s; range_far_m=%s",
        tostring(player_id), stats.id, tostring(weapon.usage), stats.aim[1], stats.aim[2],
        tostring(stats.usage.aim_delay ~= nil), live_aim_text, stats.damage, tostring(stats.clip), tostring(stats.rpm),
        tostring(last_range.r / 100), tostring(stats.usage.range and stats.usage.range.far and stats.usage.range.far / 100))
end

function M:trace_selection(gui, preview, equipped_id, selected_id, equipped, selected, distances)
    local key = tostring(equipped_id) .. "/" .. tostring(selected_id) .. "/" .. tostring(gui._cn_ai_difficulty) .. "/" .. tostring(gui._cn_ai_display_mode)
    if gui._cn_ai_trace_key == key then return end
    gui._cn_ai_trace_key = key
    local points = {}
    for _, distance in ipairs(distances) do
        local a, b = "unavailable", "unavailable"
        if equipped then local d, c = self:at_range(equipped, distance); a = string.format("%.4f/%.4f%%", d, c) end
        if selected then local d, c = self:at_range(selected, distance); b = string.format("%.4f/%.4f%%", d, c) end
        points[#points + 1] = string.format("%.2fm:%s;%s", distance / 100, a, b)
    end
    self:log_event("selection", {difficulty = gui._cn_ai_difficulty,
        display_mode = gui._cn_ai_display_mode == "compact" and "精简模式" or "详细显示",
        live_difficulty = Global.game_settings and Global.game_settings.difficulty,
        equipped = self:describe_stats(preview, equipped_id, equipped),
        selected = self:describe_stats(preview, selected_id, selected),
        rows = table.concat(points, ", "), panel = tostring(gui._cn_ai_panel:w()) .. "x" .. tostring(gui._cn_ai_panel:h())})
end

M:init_diagnostics(SavePath)
M:log_event("loaded", {component = "Restoration CN AI Weapon Stats", log_path = M._diagnostic_path or "BLT log only"})
