if not ChinStringFixes then
    if HopLib then
        dofile(ModPath .. "menu/menu_hoplib.lua")
    else
        dofile(ModPath .. "menu/menu_amb.lua")
    end
end


-- 将B除以A并保留keep位小数进行四舍五入的函数
function ChinStringFixes:smart_divide(A, B, keep, method)

    -- 先确保参数正确
    keep = keep or 2
    assert(type(A) == "number" and A ~= 0,                           "A 必须是非 0 数字")
    assert(type(B) == "number",                                      "B 必须是数字")
    assert(type(keep) == "number" and keep >= 0 and keep % 1 == 0,   "keep 必须是非负整数")
    if not (type(A) == "number" and A ~= 0) then
        return "ERROR : A"
    end
    if not (type(B) == "number") then
        return "ERROR : B"
    end
    if not (type(keep) == "number" and keep >= 0 and keep % 1 == 0) then
        return "ERROR : keep"
    end


    if method and (method == 1 or method == "o1") then

        --[[
          formatDivision(A, B, keep)
          A, B：做除法的两个数
          keep：当小数部分长度 >= 2 时，需要保留的小数位数
        ]]
        -- 做除法
        local result = B / A

        -- 判断是否为整数（或非常接近整数）
        -- 用一个小的阈值(如 1e-9)来避免浮点精度问题
        local floorVal = math.floor(result + 1e-9)
        if math.abs(result - floorVal) < 1e-9 then
            -- 结果是整数
            return tostring(floorVal)
        end

        -- 若不是整数，则先用指定的 keep 位数进行四舍五入
        local formatStr = "%." .. keep .. "f"
        local s = string.format(formatStr, result)
        
        -- 去掉可能存在的多余的尾随 0
        s = s:gsub("0+$", "")       -- 去掉小数部分末尾的 0
        s = s:gsub("%.$", "")       -- 若只剩下一个 '.', 则去掉 '.'
        
        return s

    else

        --------------------------------------------------------------------
        -- 智能除法：B ÷ A，结果至多保留 keep 位小数
        -- A : 分母（非 0）
        -- B : 分子
        -- keep : 最多保留的小数位，默认 2
        --------------------------------------------------------------------

        -- ① 原始结果
        local r = B / A
    
        -- ② 先统一按 keep 位四舍五入
        local fmt = "%." .. keep .. "f"
        local s   = string.format(fmt, r)
    
        -- ③ 把末尾 0 及孤立的 '.' 去掉
        s = s:gsub("(%..-)0+$", "%1")  -- 去掉末尾 0（保留小数点前已有的内容）
        s = s:gsub("%.$", "")          -- 如果结尾是 '.'，再去掉 '.'
    
        -- ④ 返回数值（若想保留字符串格式，可直接 return s）
        return tonumber(s)

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

-- 阿拉伯数字转换为中文数字
function ChinStringFixes:number_to_chinese(n)
    if n < 0 or n > 99 then
        return "错误：[超出范围]"
    end

    local digits = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
    
    if n < 10 then
        return digits[n + 1]
    elseif n < 20 then
        if n == 10 then
            return "十"
        else
            return "十" .. digits[n % 10 + 1]
        end
    else
        local tens = math.floor(n / 10)
        local ones = n % 10
        local result = digits[tens + 1] .. "十"
        if ones ~= 0 then
            result = result .. digits[ones + 1]
        end
        return result
    end
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

