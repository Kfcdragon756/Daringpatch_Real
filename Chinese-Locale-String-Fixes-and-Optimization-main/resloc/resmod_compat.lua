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

local loc_path = ChinStringFixes.mod_path .. "loc/schinese.txt"  --loc路径
local content = read_txt_file(loc_path)
local version_path = "mods/restoration-mod/update/version.json"
if ChinStringFixes.Res_Path then
	version_path = ChinStringFixes.Res_Path .. "update/version.json"
elseif SC and SC._path then
    version_path = SC._path .. "update/version.json"
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
if ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 2 then
    dofile(ModPath .. "resloc/loc/loczh.lua")
    current_version = main_version
elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 3 then
    dofile(ModPath .. "resloc/loc/loczh_dev.lua")
    current_version = dev_version
elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 4 then
    dofile(ModPath .. "resloc/loc/loczh_dev_new.lua")
    current_version = dev_new_version
end


--检测版本号
Hooks:Add("MenuManagerOnOpenMenu", "CSF_MenuManagerOnOpenMenu_CheckResVersion", function()
    local title = managers.localization:text('CSF_ResModUpdater_title')
    local message
    if all_read then
        if local_version == current_version then
            --nothing
        else
            local reason = ""
            if local_version ~= main_version and local_version ~= dev_version and local_version ~= dev_new_version then
                message = managers.localization:text('CSF_ResModUpdater_message_r1')
                reason = "r1"
            else
                message = managers.localization:text('CSF_ResModUpdater_message_r2')
                reason = "r2"
            end
            if Global.ChinStringFixes_ShowResVersion == 0 then
                local menu_options = {}
                menu_options[1] = {
                    text = managers.localization:text('CSF_DontShowAgain'),
                    callback = function()
                        Global.ChinStringFixes_ShowResVersion = 1
                    end
                }
                menu_options[2] = {
                    text = managers.localization:text('CSF_WarnMeLater')
                }
                if reason == "r1" then
                    menu_options[3] = {
                        text = managers.localization:text('CSF_UpdateNow'),
                        callback = function()
                            local path = ChinStringFixes.Res_Path .. "update\\updater.exe"
                            os.execute('start "" "' .. path .. '"')
                        end
                    }
                end
                local menu = QuickMenu:new(title, message, menu_options)
                menu:Show()
            end
        end
    elseif old_res then
        message = managers.localization:text('CSF_ResModUpdater_message_come')
        if Global.ChinStringFixes_ShowResVersion == 0 then
            local menu_options = {}
            menu_options[1] = {
                text = managers.localization:text('CSF_DontShowAgain'),
                callback = function()
                    Global.ChinStringFixes_ShowResVersion = 1
                end
            }
            menu_options[2] = {
                text = managers.localization:text('CSF_Quit')
            }
            local menu = QuickMenu:new(title, message, menu_options)
            menu:Show()
        end
    end
end)



--[[
if ChinStringFixes.settings.res_perk then
	if ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 2 then
		dofile(ModPath .. "resloc/origin/origin_perk.lua")
	elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 3 then
		dofile(ModPath .. "resloc/origin/origin_perk_dev.lua")
	elseif ChinStringFixes.settings.Mod_Support.Resmod.Resmod_Compat == 4 then
		dofile(ModPath .. "resloc/origin/origin_perk_dev_new.lua")
	end
end--]]
