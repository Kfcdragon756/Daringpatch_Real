if not ChinStringFixes then
    if HopLib then
        dofile(ModPath .. "menu/menu_hoplib.lua")
    else
        dofile(ModPath .. "menu/menu_amb.lua")
    end
end

function ChinStringFixes:containsChars(str, chars, all)
    local str_low = string.lower(str)
    if all then
        for _, char in ipairs(chars) do
            local char_low = string.lower(char)
            if not string.find(str_low, char_low, 1, true) then
                return false
            end
        end
        return true
    else
        for _, char in ipairs(chars) do
            local char_low = string.lower(char)
            if string.find(str_low, char_low) then
                return true
            end
        end
        return false
    end
end
CSF_containsChars = ChinStringFixes.containsChars

ChinStringFixes.start_time = ChinStringFixes.start_time or 0
if Global then
    Global.ChinStringFixesTimer = Global.ChinStringFixesTimer or 0
    Global.ChinStringFixes_ShowResVersion = Global.ChinStringFixes_ShowResVersion or 0
end

local schinese = Idstring("schinese"):key() == SystemInfo:language():key()
function CSF_is_schinese()
    if not schinese and not CHNMOD_PATCH then
        return false
    else
        return true
    end
end
--CSF_is_schinese = ChinStringFixes.is_schinese

function CSF_is_enable()
    if not ChinStringFixes or not ChinStringFixes.settings.Enable_String then
        return false
    else
        return true
    end
end
--CSF_is_enable = ChinStringFixes.is_enable

-- WIP function
function CSF_create_a_simple_menu(title, message, button_text, can_cancle, options_number)
    local menu_options = {}
    if options_number >= 1 then
        menu_options[1] = {
            text = button_text,
            is_cancel_button = can_cancle
        }
        local menu = QuickMenu:new(title, message, menu_options)
        menu:Show()
    end
end

if not CSF_is_schinese() or not CSF_is_enable() or not ChinStringFixes.settings.Mod_Support then
    return
end

-- log("Mod_Support running!")

local Mod_Support_Folder = file.GetDirectories(ChinStringFixes.mod_path .. "lua/Mod_Support")
if Mod_Support_Folder then
    for _, v in pairs(Mod_Support_Folder) do
        local file_name = ChinStringFixes.mod_path .. "lua/Mod_Support/" .. v .. "/" ..
                              RequiredScript:gsub(".+/(.+)", "%1.lua")
        if not ChinStringFixes.required[file_name] then
            if io.file_is_readable(file_name) then
                dofile(file_name)
            end
            ChinStringFixes.required[file_name] = true
        end
    end
else
    log("ChinStringFixes ERROR : Mod Files are missing")
end

if OVKNMSL_PD3 then
    return
end

local function CSF_play_audio(volume, unit, path)
    local oggpath = path
    local unit_play
    local unit_type = type(unit)
    if unit_type == "string" and (unit == "player" or unit == "Player" or unit == "PLAYER") then
        unit_play = XAudio.PLAYER
    else
        unit_play = unit
    end

    if unit then
        if unit_type == "userdata" then
            if not alive(unit) then
                return
            end
        end
        blt.xaudio.setup()
        XAudio.UnitSource:new(unit_play, XAudio.Buffer:new(oggpath)):set_volume(volume)
    else
        blt.xaudio.setup()
        XAudio.Source:new(XAudio.Buffer:new(oggpath)):set_volume(volume)
    end
end

local function CSF_get_PeerUnit_by_PeerID(peer_id)
    local peer = managers.network:session():peer(peer_id)
    if peer then
        return peer:unit()
    end
end

-- LuaNetworking Receiver
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_CSF_OVKNMSL_PD3", function(sender, id, data)
    if not ChinStringFixes.settings.Enable_String or not ChinStringFixes.settings.Mod_Support.OVKNMSL.OVKNMSL_Enable then
        return
    end
    local volume = ChinStringFixes.settings.Mod_Support.OVKNMSL.OVKNMSL_Volume
    local peer_unit = CSF_get_PeerUnit_by_PeerID(sender)
    local table_get_from_data = {}
    if data then
        table_get_from_data = json.decode(data)
    end
    if id == "OVKNMSL_sent_my_id" then
        if table_get_from_data and table_get_from_data.value_1 then
            local preplay_path = table_get_from_data.value_1
            local last_character = string.sub(preplay_path, -5)

            if last_character == "2.ogg" then
                preplay_path = ChinStringFixes.mod_path .. "lua/Mod_Support/OVKNMSL/die2.ogg"
            elseif last_character == "e.ogg" then
                preplay_path = ChinStringFixes.mod_path .. "lua/Mod_Support/OVKNMSL/die.ogg"
            end

            if io.file_is_readable(preplay_path) then
                CSF_play_audio(volume, peer_unit, preplay_path)
            end

        end
    end
end)

