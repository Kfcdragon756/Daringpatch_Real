-- Local trial for Restoration CN. Loaded by BeardLib after Restoration's GUI override.
if not restoration then return end
dofile(ModPath .. "lua/model.lua")
dofile(ModPath .. "lua/diagnostics.lua")
local M = CN_AI_Weapon_Stats

local function number(value, digits)
    if type(value) ~= "number" then return "—" end
    local precision = 10 ^ (digits or 1)
    local rounded = math.floor(value * precision + 0.50000001) / precision
    local text = string.format("%." .. (digits or 1) .. "f", rounded)
    return text:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
end

local function weapon_id(gui, item)
    if not item or item.empty_slot or item.locked_slot then return end
    local crafted
    if not gui._data.buying_weapon and item.slot and item.category then
        crafted = managers.blackmarket:get_crafted_category_slot(item.category, item.slot)
    end
    return crafted and crafted.weapon_id or item.weapon_id or item.name
end

local function equipped_item(gui)
    for _, tab in ipairs(gui._data or {}) do
        for _, item in ipairs(tab) do
            if item.equipped and not item.empty_slot then return item end
        end
    end
    local scene = managers.menu_scene
    local index = scene and scene:henchmen_player_override()
    local loadout = index and managers.blackmarket:henchman_loadout(index)
    if loadout and (loadout.primary_slot or loadout.primaries_slot) then
        return {category = loadout.primary_category or "primaries", slot = loadout.primary_slot or loadout.primaries_slot}
    end
end

local function difficulty_index(difficulty)
    for i, name in ipairs(M.difficulties) do if difficulty == name then return i end end
    return 1
end

-- Reset on entry/re-entry, not when selecting another weapon in the same page.
local function reset_page(self)
    self._cn_ai_panel = nil
    self._cn_ai_icons = nil
    self._cn_ai_toggle_button = nil
    self._cn_ai_display_mode = "detailed"
    self._cn_ai_previews = {}
    self._cn_ai_scroll = 0
    self._cn_ai_page_logged = false
    self._cn_ai_trace_key = nil
    self._cn_ai_difficulty = M.difficulties[difficulty_index(Global.game_settings and Global.game_settings.difficulty)]
end

function BlackMarketGui:cn_ai_stats_preview()
    local difficulty = self._cn_ai_difficulty
    local cached = self._cn_ai_previews[difficulty]
    if cached ~= nil then return cached or nil end
    local started = os.clock()
    local ok, preview = pcall(M.snapshot, M, tweak_data, difficulty)
    self._cn_ai_previews[difficulty] = ok and preview or false
    M:log_event(ok and "preview_ready" or "preview_error", {difficulty = difficulty,
        elapsed_ms = math.floor((os.clock() - started) * 1000), error = not ok and tostring(preview) or nil})
    return ok and preview or nil
end

function BlackMarketGui:cn_ai_stats_render()
    if alive(self._cn_ai_panel) then self._cn_ai_panel:hide() end
    local override = managers.menu_scene and managers.menu_scene:henchmen_player_override()
    if not M:is_ai_page(self._data, override) or not alive(self._weapon_info_panel) then return end
    local slot = self._slot_data
    if not slot or slot.empty_slot or slot.locked_slot then return end
    if not self._cn_ai_previews then return end -- show_stats can be called during the original setup.
    if not self._cn_ai_page_logged then
        M:log_event("ai_page", {category = self._data.category or "buying", preview = self._cn_ai_difficulty,
            custom_callback = type(self._data.custom_callback), henchmen_override = tostring(override)})
        self._cn_ai_page_logged = true
    end
    local preview = self:cn_ai_stats_preview()
    local selected_id = weapon_id(self, slot)
    local equipped_id = weapon_id(self, equipped_item(self))
    local selected = preview and M:stats(preview, selected_id)
    local equipped = preview and M:stats(preview, equipped_id)
    if alive(self._stats_panel) then self._stats_panel:hide() end
    -- Keep the weapon name; ordinary descriptions and DLC text occupy the same area.
    for i = 2, 5 do
        if self._info_texts and alive(self._info_texts[i]) then self._info_texts[i]:hide() end
        if self._info_texts_bg and alive(self._info_texts_bg[i]) then self._info_texts_bg[i]:hide() end
    end
    if not alive(self._cn_ai_panel) then
        self._cn_ai_panel = self._weapon_info_panel:panel({name = "cn_ai_weapon_stats", x = 10,
            y = 52, w = self._weapon_info_panel:w() - 20, h = self._weapon_info_panel:h() - 56, layer = 10})
    end
    local panel = self._cn_ai_panel
    panel:show()
    panel:clear()
    local w, h = panel:w(), panel:h()
    local colors = tweak_data.screen_colors
    local font = tweak_data.menu.pd2_small_font
    local size = math.min(20, tweak_data.menu.pd2_small_font_size)
    local text_parent = panel
    local function text(value, x, y, width, height, align, color, font_size)
        return text_parent:text({text = tostring(value), x = x, y = y, w = width, h = height,
            font = font, font_size = font_size or size, color = color or colors.text,
            align = align or "left", vertical = "center", layer = 2})
    end
    local rank = difficulty_index(self._cn_ai_difficulty)
    local name_id = tweak_data.difficulty_name_ids and tweak_data.difficulty_name_ids[self._cn_ai_difficulty]
    local name = managers.localization:text(name_id or "menu_difficulty_" .. self._cn_ai_difficulty)
    local button_w = math.min(112, w * 0.38)
    text("难度预览：" .. name, 2, 0, w - button_w - 8, 23, "left", colors.risk)
    self._cn_ai_toggle_button = panel:panel({x = w - button_w, y = 0, w = button_w, h = 23, layer = 4})
    self._cn_ai_toggle_button:rect({color = Color.black:with_alpha(0.3)})
    self._cn_ai_toggle_button:text({text = self._cn_ai_display_mode == "compact" and "切换详细数据显示" or "切换精简数据显示",
        x = 0, y = 0, w = button_w, h = 23,
        font = font, font_size = math.min(14, (button_w - 4) / 8), align = "right", vertical = "center",
        color = self._cn_ai_display_mode == "compact" and colors.risk or colors.button_stage_3 or colors.text,
        layer = 2})
    self._cn_ai_icons = {}
    local cell = math.min(36, (w - 90) / 6)
    text("难度", 2, 24, 65, 28)
    for i = 2, 7 do
        local x = 70 + (i - 2) * cell
        local hit = panel:panel({x = x, y = 24, w = cell, h = 28, layer = 3})
        local texture, rect = tweak_data.hud_icons:get_icon_data(M.risks[i])
        hit:bitmap({texture = texture, texture_rect = rect, w = 26, h = 26,
            color = colors.risk, alpha = rank >= i and 1 or 0.25})
        self._cn_ai_icons[i] = hit
    end
    local rows = {
        {"弹匣容量", function(s) return number(s.clip, 0) end},
        {"弹道扩散", function(s) return number(s.spread) end},
        {"武器射速", function(s) return number(s.rpm, 0) end},
        {"连发射击", function(s) return s.burst and number(s.burst[1], 0) .. " | " .. number(s.burst[2], 0) or "—" end},
        {"装弹倍率", function(s) return "×" .. number(s.reload, 2) end},
        {"瞄准延迟", function(s) return number(s.aim[1], 2) .. " | " .. number(s.aim[2], 2) end}
    }
    local display_distances
    if self._cn_ai_display_mode == "compact" then
        display_distances = {100, 300, 500, 1000, 1500, 2000, 3000, 4000, 5000}
    else
        display_distances = M:display_distances(equipped, selected, preview and M:distances(preview))
    end
    for _, distance in ipairs(display_distances) do
        local d = distance
        rows[#rows + 1] = {"伤|命中" .. number(d / 100, 2) .. "米", function(s)
            local damage, chance = M:at_range(s, d)
            return number(damage) .. " | " .. number(chance, 0) .. "%"
        end}
    end
    local row_h = 20
    size = math.min(size, 18)
    local label_w = w * 0.40
    local value_w = (w - label_w) / 2
    local top = 57
    panel:rect({x = 0, y = top, w = w, h = row_h, color = Color.black:with_alpha(0.5)})
    text("AI武器统计", 2, top, label_w - 2, row_h)
    text("已装备", label_w, top, value_w, row_h, "center", colors.text:with_alpha(0.75))
    text("所选", label_w + value_w, top, value_w, row_h, "center")
    local viewport_h = math.max(20, h - top - row_h - 59)
    local viewport = panel:panel({x = 0, y = top + row_h, w = w, h = viewport_h})
    self._cn_ai_scroll_max = math.max(0, #rows * row_h - viewport_h)
    self._cn_ai_scroll = math.max(0, math.min(self._cn_ai_scroll or 0, self._cn_ai_scroll_max))
    self._cn_ai_canvas = viewport:panel({x = 0, y = -self._cn_ai_scroll, w = w, h = #rows * row_h})
    text_parent = self._cn_ai_canvas
    for i, row in ipairs(rows) do
        local y = row_h * (i - 1)
        if i % 2 == 0 then text_parent:rect({x = 0, y = y, w = w, h = row_h, color = Color.black:with_alpha(0.3)}) end
        text(row[1], 2, y, label_w - 2, row_h)
        text(equipped and row[2](equipped) or "—", label_w, y, value_w, row_h, "center", colors.text:with_alpha(0.75))
        text(selected and row[2](selected) or "—", label_w + value_w, y, value_w, row_h, "center")
    end
    text_parent = panel
    local note = not preview and "难度预览失败，详情见BLT日志。" or
        not selected and "此武器没有可用的AI专用数据。" or
        "基础伤害与满专注命中率；单发射速以15米为准。\n不含队友能力、暴击和临时增益。\n可以使用滚轮滚动页面；点击骷髅查看不同难度的数据。"
    local note_text = text(note, 2, h - 57, w - 4, 57,
        "left", colors.text:with_alpha(0.65), 13)
    note_text:set_wrap(true)
    note_text:set_word_wrap(true)
    M:trace_selection(self, preview, equipped_id, selected_id, equipped, selected, display_distances)
end

-- Restoration assigns these methods directly after earlier mods have registered
-- BLT hooks. Those hook records can point to discarded wrappers, so adding another
-- Hooks:PostHook silently misses the live method. Wrap the current implementation
-- locally, without reviving earlier callbacks against Restoration's replacement.
local function after_render(gui, ...)
    -- PAYDAY 2 does not expose xpcall. Keep diagnostics on its supported pcall path.
    local ok, err = pcall(gui.cn_ai_stats_render, gui)
    if not ok then
        M:log_event("render_error", {error = err})
        error(err, 0)
    end
    return ...
end
local setup = BlackMarketGui._setup
local function after_setup(gui, ...)
    M:log_event("page_setup", {category = gui._data and gui._data.category or "none",
        ai_detected = M:is_ai_page(gui._data, managers.menu_scene and managers.menu_scene:henchmen_player_override()),
        default_difficulty = gui._cn_ai_difficulty})
    return after_render(gui, ...)
end
function BlackMarketGui:_setup(...)
    reset_page(self)
    return after_setup(self, setup(self, ...))
end
local show_stats = BlackMarketGui.show_stats
function BlackMarketGui:show_stats(...)
    return after_render(self, show_stats(self, ...))
end
local update_info_text = BlackMarketGui.update_info_text
function BlackMarketGui:update_info_text(...)
    return after_render(self, update_info_text(self, ...))
end

local function icon_at(gui, x, y)
    if not alive(gui._cn_ai_panel) or not gui._cn_ai_panel:visible() then return end
    for index, icon in pairs(gui._cn_ai_icons or {}) do
        if alive(icon) and icon:inside(x, y) then return index end
    end
end

local function over_toggle(gui, x, y)
    return alive(gui._cn_ai_panel) and gui._cn_ai_panel:visible() and
        alive(gui._cn_ai_toggle_button) and gui._cn_ai_toggle_button:inside(x, y)
end

local mouse_pressed = BlackMarketGui.mouse_pressed
function BlackMarketGui:mouse_pressed(button, x, y, ...)
    if self._enabled and not self._no_input and not self._renaming_item and
        not (managers.menu_scene and managers.menu_scene:input_focus()) then
        if button == Idstring("0") and over_toggle(self, x, y) then
            local previous = self._cn_ai_display_mode
            self._cn_ai_display_mode = previous == "compact" and "detailed" or "compact"
            self._cn_ai_scroll = 0
            M:log_event("display_mode_changed", {from = previous == "compact" and "精简模式" or "详细显示",
                to = self._cn_ai_display_mode == "compact" and "精简模式" or "详细显示"})
            managers.menu_component:post_event("menu_enter")
            after_render(self)
            return true
        end
        if alive(self._cn_ai_panel) and self._cn_ai_panel:visible() and self._cn_ai_panel:inside(x, y) and
            (button == Idstring("mouse wheel down") or button == Idstring("mouse wheel up")) then
            local step = button == Idstring("mouse wheel down") and 40 or -40
            self._cn_ai_scroll = math.max(0, math.min((self._cn_ai_scroll or 0) + step, self._cn_ai_scroll_max or 0))
            if alive(self._cn_ai_canvas) then self._cn_ai_canvas:set_y(-self._cn_ai_scroll) end
            return true
        end
        local rank = icon_at(self, x, y)
        if rank and button == Idstring("0") then
            local previous = difficulty_index(self._cn_ai_difficulty)
            self._cn_ai_difficulty = M.difficulties[rank == previous and rank - 1 or rank]
            M:log_event("difficulty_changed", {from = M.difficulties[previous], to = self._cn_ai_difficulty})
            managers.menu_component:post_event("menu_enter")
            after_render(self)
            return true
        end
    end
    return mouse_pressed(self, button, x, y, ...)
end

local mouse_moved = BlackMarketGui.mouse_moved
function BlackMarketGui:mouse_moved(o, x, y, ...)
    if self._enabled and not self._no_input and (over_toggle(self, x, y) or icon_at(self, x, y)) then return true, "link" end
    return mouse_moved(self, o, x, y, ...)
end

local close = BlackMarketGui.close
function BlackMarketGui:close(...)
    if self._cn_ai_page_logged then M:log_event("page_close", {preview = self._cn_ai_difficulty}) end
    self._cn_ai_previews = nil
    self._cn_ai_icons = nil
    self._cn_ai_toggle_button = nil
    self._cn_ai_panel = nil
    return close(self, ...)
end
if log then log("[CN AI Weapon Stats] UI compatibility loaded (local trial 0.4)") end
