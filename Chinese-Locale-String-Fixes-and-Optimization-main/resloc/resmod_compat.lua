local schinese = Idstring("schinese"):key() == SystemInfo:language():key()
if not schinese then
	return
end

if not restoration then
	return
else
	log("ChinStringFixes : Restoration_Mod Detected.")
end

if ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 1 then
	return
end

if not ChinStringFixes.settings.Enable_String then
	return
end

----------------------------------------------------------------------------
local old_res = nil
-- 读取 JSON 文件内容
local function read_json_file(file_path)
    -- 使用 BLT 提供的 file I/O 函数
    local file = io.open(file_path, "r")
    if file then
        local content = file:read("*all")  -- 读取整个文件内容
        file:close()

        -- 使用 BLT 内置的 json.decode 解析 JSON 字符串
        local data = json.decode(content)
        if data and data.version then
            return data.version
        else
            log("Failed to parse version information.")
        end
    else
        log("Could not open file: " .. file_path)
        old_res = true
    end
    return nil
end

-- 打开并读取 txt 文件内容
local function read_txt_file(file_path)
    local file = io.open(file_path, "r")  -- 以只读模式打开文件
    if not file then
        log("无法打开文件: " .. file_path)
        return nil
    end

    local content = file:read("*all")  -- 读取文件的全部内容
    file:close()  -- 关闭文件
    return content
end

-- 提取版本号的函数
local function extract_version(content)
    -- 使用正则表达式匹配版本号
    local main_version = content and content:match('"chinsf_res_main"%s*:%s*".-V([%d%.]+)"')
    local dev_version = content and content:match('"chinsf_res_dev"%s*:%s*".-V([%d%.]+)"')
    local dev_new_version = content and content:match('"chinsf_res_dev_new"%s*:%s*".-V([%d%.]+)"')

    return main_version, dev_version, dev_new_version
end


-- 主程序
local all_read = nil

local Using_CSF_Res_Path
local Using_SC_Path

local loc_path = ChinStringFixes.mod_path .. "loc/schinese.txt"  --loc路径
local content = read_txt_file(loc_path)
local version_path = "mods/restoration-mod/update/version.json"
if ChinStringFixes.Res_Path then
	version_path = ChinStringFixes.Res_Path .. "update/version.json"
    Using_CSF_Res_Path = true
elseif SC and SC._path then
    version_path = SC._path .. "update/version.json"
    Using_SC_Path = true
end

local local_version = read_json_file(version_path)  --res版本号路径

local current_version
local main_version
local dev_version
local dev_new_version
if content and local_version then
    all_read = true
    main_version, dev_version, dev_new_version = extract_version(content) --all string
end


--log("Restoration found, running compat")
--log("ResPath"..ChinStringFixes.Res_Path)
if ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat ~= 1 then
    if Using_CSF_Res_Path then
        dofile(ChinStringFixes.Res_Path .. "lua/sc/loc/loc.lua")
    elseif Using_SC_Path then
        dofile(SC._path .. "lua/sc/loc/loc.lua")
    end
end
if ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 2 then
    --[[if not Using_CSF_Res_Path and not Using_SC_Path then
        dofile(ModPath .. "resloc/origin/origin_loc.lua")
    end-]]
    dofile(ModPath .. "resloc/loc/loczh.lua")
    current_version = main_version
elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 3 then
    if not Using_CSF_Res_Path and not Using_SC_Path then
        dofile(ModPath .. "resloc/origin/origin_loc_dev.lua")
    end
    dofile(ModPath .. "resloc/loc/loczh_dev.lua")
    current_version = dev_version
elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 4 then
    --[[if not Using_CSF_Res_Path and not Using_SC_Path then
        dofile(ModPath .. "resloc/origin/origin_loc_dev_new.lua")
    end-]]
    dofile(ModPath .. "resloc/loc/loczh_dev_new.lua")
    current_version = dev_new_version
end


--检测版本号
Hooks:Add("MenuManagerOnOpenMenu", "CSF_MenuManagerOnOpenMenu_CheckResVersion", function()
    -- json的初始化和写入部分，用于永远不要再显示文本
    local json_data_get
        -- 读取文件
    local file_read = io.open(SavePath .. "CSF_Display_Update_Notification.json", "r")
    if not file_read then
                -- 写入文件
        local config_data = {
            Never_Display_Again_old = false,
            Never_Display_Again_dismatch = false
        }
        local file_write = io.open(SavePath .. "CSF_Display_Update_Notification.json", "w")
        if file_write then
            file_write:write(json.encode(config_data))
            file_write:close()
            --log("JSON文件创建完成")
        else
            log("CSF: CSF_Display_Update_Notification.json created failed, try running the game with Administrator.")
        end
    else
        local json_str = file_read:read("*a")
        file_read:close()
        json_data_get = json.decode(json_str)
    end

    -- “你确定吗？” -- 是否确定永远都不要再提醒
    local function CSF_Never_Display_Again_Confirming(id)
        local menu_options_Confirming = {}
        menu_options_Confirming[1] = {
            text = managers.localization:text('CSF_Miss_QKI_yes'),
            callback = function()  --确定永远不再提醒
                local file_edit = io.open(SavePath .. "CSF_Display_Update_Notification.json", "r")
                if not file_edit then
                    local menu_options_edit_ERROR = {}
                    menu_options_edit_ERROR[1] = {
                        text = managers.localization:text('CSF_Miss_QKI_yes'),
                    }
                    local title_edit_ERROR = managers.localization:text('CSF_BLT_Text_Title')
                    local message_edit_ERROR = managers.localization:text('CSF_DSA_edit_ERROR')
                    local menu_edit_ERROR = QuickMenu:new(title_edit_ERROR, message_edit_ERROR, menu_options_edit_ERROR)
                    menu_edit_ERROR:Show()
                    Global.ChinStringFixes_ShowResVersion = 1
                    return
                end
                local json_str = file_edit:read("*a")
                file_edit:close()
                local config_data = json.decode(json_str)
                if id == "old" then
                    config_data.Never_Display_Again_old = true
                elseif id == "dismatch" then
                    config_data.Never_Display_Again_dismatch = true
                else
                    local menu_options_id_ERROR = {}
                    menu_options_id_ERROR[1] = {
                        text = managers.localization:text('CSF_Miss_QKI_yes'),
                    }
                    local title_id_ERROR = managers.localization:text('CSF_BLT_Text_Title')
                    local message_id_ERROR = managers.localization:text('CSF_DSA_id_ERROR')
                    local menu_id_ERROR = QuickMenu:new(title_id_ERROR, message_id_ERROR, menu_options_id_ERROR)
                    menu_id_ERROR:Show()
                    Global.ChinStringFixes_ShowResVersion = 1
                    return
                end
                --config_data.Last_Modified = os.date("%Y-%m-%d %H:%M:%S")  --测试用
                local updated_json = json.encode(config_data)
                file_edit = io.open(SavePath .. "CSF_Display_Update_Notification.json", "w")
                file_edit:write(updated_json)
                file_edit:close()
            end
        }
        menu_options_Confirming[2] = {
            text = managers.localization:text('CSF_cancel_DontShowAgain'),
            callback = function()
                Global.ChinStringFixes_ShowResVersion = 1
            end
        }
        menu_options_Confirming[3] = {
            text = managers.localization:text('CSF_cancel_WarnMeLater'),
            callback = function()
                Global.ChinStringFixes_WarnMeLater = Global.ChinStringFixes_WarnMeLater + 1       
            end
        }
        local title_Confirming = managers.localization:text('CSF_Miss_QKI_title')
        local message_Confirming = (id == "old" and managers.localization:text('CSF_DSA_cancel_message_old')) or managers.localization:text('CSF_DSA_cancel_message')
        local menu_Confirming = QuickMenu:new(title_Confirming, message_Confirming, menu_options_Confirming)
        menu_Confirming:Show()
    end

    -- 稍后提醒
    local Warn_Me
    if (Global.ChinStringFixes_WarnMeLater == 0) or (Global.ChinStringFixes_WarnMeLater > 0 and Global.ChinStringFixes_WarnMeLater % 10 == 0) then
        Warn_Me = true
    else
        Global.ChinStringFixes_WarnMeLater = Global.ChinStringFixes_WarnMeLater + 1
    end

    -- 主要处理逻辑部分
    local title_first = managers.localization:text('CSF_ResModUpdater_title')
    local message_first
    --log("old_res is "..tostring(old_res)..", json_data_get.Never_Display_Again_old is "..tostring(json_data_get.Never_Display_Again_false))
    if Warn_Me then
        if all_read then
            if (local_version == current_version) or (json_data_get and json_data_get.Never_Display_Again_dismatch == true) then
                --nothing
            else
                local reason = ""
                if local_version ~= main_version and local_version ~= dev_version and local_version ~= dev_new_version then
                    message_first = managers.localization:text('CSF_ResModUpdater_message_r1')
                    reason = "r1"
                else
                    message_first = managers.localization:text('CSF_ResModUpdater_message_r2')
                    reason = "r2"
                end
                if Global.ChinStringFixes_ShowResVersion == 0 then
                    local menu_options_first = {}
                    menu_options_first[1] = {
                        text = managers.localization:text('CSF_DontShowAgain_Permanent'),
                        callback = function()
                            CSF_Never_Display_Again_Confirming("dismatch")
                        end
                    }
                    menu_options_first[2] = {
                        text = managers.localization:text('CSF_DontShowAgain'),
                        callback = function()
                            Global.ChinStringFixes_ShowResVersion = 1
                        end
                    }
                    menu_options_first[3] = {
                        text = managers.localization:text('CSF_WarnMeLater'),
                        callback = function()
                            Global.ChinStringFixes_WarnMeLater = Global.ChinStringFixes_WarnMeLater + 1
                        end
                    }
                    if reason == "r1" then
                        menu_options_first[4] = {
                            text = managers.localization:text('CSF_UpdateNow'),
                            callback = function()
                                local path = ChinStringFixes.Res_Path .. "update\\updater.exe"
                                os.execute('start "" "' .. path .. '"')
                            end
                        }
                    end
                    local menu_first = QuickMenu:new(title_first, message_first, menu_options_first)
                    menu_first:Show()
                end
            end
        elseif (old_res and json_data_get == nil) or (old_res and (json_data_get and json_data_get.Never_Display_Again_old == false)) then
            message_old = managers.localization:text('CSF_ResModUpdater_message_come')
            if Global.ChinStringFixes_ShowResVersion == 0 then
                local menu_options_old = {}
                menu_options_old[1] = {
                    text = managers.localization:text('CSF_DontShowAgain_Permanent'),
                    callback = function()
                        CSF_Never_Display_Again_Confirming("old")
                    end
                }
                menu_options_old[2] = {
                    text = managers.localization:text('CSF_DontShowAgain'),
                    callback = function()
                        Global.ChinStringFixes_ShowResVersion = 1
                    end
                }
                menu_options_old[3] = {
                    text = managers.localization:text('CSF_Quit')
                }
                local menu_old = QuickMenu:new(title_first, message_old, menu_options_old)
                menu_old:Show()
            end
        end
    end
end)




--[[
if ChinStringFixes.settings.res_perk then
	if ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 2 then
		dofile(ModPath .. "resloc/origin/unused/origin_perk.lua")
	elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 3 then
		dofile(ModPath .. "resloc/origin/unused/origin_perk_dev.lua")
	elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 4 then
		dofile(ModPath .. "resloc/origin/unused/origin_perk_dev_new.lua")
	end
end--]]
