ChinStringFixes = class()

-- Table to String & String to Table
function CSF_ToStringEx(value)
    if type(value) == 'table' then
        return CSF_TableToStr(value)
    elseif type(value) == 'string' then
        return "\'" .. value .. "\'"
    else
        return tostring(value)
    end
end

function CSF_StrToTable(str)
    if str == nil or type(str) ~= "string" then
        return
    end

    local success, CSF_f = pcall(loadstring, "return " .. str)
    return success and CSF_f and CSF_f()
    -- return loadstring("return "..str)
end

function CSF_TableToStr(t)
    if t == nil then
        return ""
    end
    local retstr = "{"

    local i = 1
    for key, value in pairs(t) do
        local signal = ","
        if i == 1 then
            signal = ""
        end

        if key == i then
            retstr = retstr .. signal .. CSF_ToStringEx(value)
        else
            if type(key) == 'number' or type(key) == 'string' then
                retstr = retstr .. signal .. '[' .. CSF_ToStringEx(key) .. "]=" .. CSF_ToStringEx(value)
            else
                if type(key) == 'userdata' then
                    retstr = retstr .. signal .. "*s" .. CSF_TableToStr(getmetatable(key)) .. "*e" .. "=" ..
                                 CSF_ToStringEx(value)
                else
                    retstr = retstr .. signal .. key .. "=" .. CSF_ToStringEx(value)
                end
            end
        end

        i = i + 1
    end

    retstr = retstr .. "}"
    return retstr
end

-- ===================================================================--

-- init loc stuffs
local CSF_Quit = ""
if managers.localization then
    CSF_Quit = managers.localization:text('CSF_Quit')
end
local CSF_BLT_title = ""
local CSF_BLT_message = ""

local CSF_QKI_title = ""
local CSF_QKI_message = ""

local CSF_QKI_depend_title = ""
local CSF_QKI_depend_message = ""
local CSF_Miss_QKI = ""

local CSF_Miss_QKI_title = ""
local CSF_Miss_QKI_message = ""
local CSF_Miss_QKI_no = ""
local CSF_Miss_QKI_yes = ""

-- QKI callback function
function CSF_QKI_callback_ok(text)

    -- log("user typed: " .. tostring(text))
    local CSF_Stream_table = {}
    local CSF_Steam_Text = text
    local CSF_Stream_path = SavePath .. "chin_string_fixes_steam_mode.json"
    local CSF_Stream_Check = true
    local CSF_menu_options = {}
    if managers.localization then
        CSF_BLT_title = managers.localization:text('CSF_BLT_Text_Title')
        CSF_BLT_message = managers.localization:text('CSF_BLT_Text_Message')
        ERROR_CODE_56 = managers.localization:text('CSF_ERROR_CODE_56')
        ERROR_CODE_23 = managers.localization:text('CSF_ERROR_CODE_23')
        ERROR_CODE_0 = managers.localization:text('CSF_ERROR_CODE_0')
    end
    local CSF_menu
    local CSF_SaveText_to_txt

    local text_check_begin = string.find(CSF_Steam_Text, ";", 1)
    local text_check_end = string.find(CSF_Steam_Text, ";", -1)

    CSF_Stream_table = CSF_Steam_Text:split(";")

    if not text_check_begin then
        if managers.localization then
            CSF_Quit = managers.localization:text('CSF_Quit')
        end
        CSF_menu_options[1] = {
            text = CSF_Quit,
            is_cancel_button = true
        }
        CSF_menu = QuickMenu:new(CSF_BLT_title, CSF_BLT_message .. ERROR_CODE_56, CSF_menu_options)
        CSF_menu:Show()
    elseif text_check_begin == 1 or text_check_end == #CSF_Steam_Text then
        if managers.localization then
            CSF_Quit = managers.localization:text('CSF_Quit')
        end
        CSF_menu_options[1] = {
            text = CSF_Quit,
            is_cancel_button = true
        }
        CSF_menu = QuickMenu:new(CSF_BLT_title, CSF_BLT_message .. ERROR_CODE_23, CSF_menu_options)
        CSF_menu:Show()
    elseif CSF_Stream_table and CSF_Stream_Check then
        CSF_SaveText_to_txt = io.open(SavePath .. "chin_string_fixes_text.txt", "w+")
        if CSF_SaveText_to_txt then
            CSF_SaveText_to_txt:write(CSF_Steam_Text)
            CSF_SaveText_to_txt:close()
        end
        io.save_as_json(CSF_Stream_table, CSF_Stream_path)
    else
        if managers.localization then
            CSF_Quit = managers.localization:text('CSF_Quit')
        end
        CSF_menu_options[1] = {
            text = CSF_Quit,
            is_cancel_button = true
        }
        CSF_menu = QuickMenu:new(CSF_BLT_title, CSF_BLT_message .. ERROR_CODE_0, CSF_menu_options)
        CSF_menu:Show()
    end

end

--local getaf = os.date('*t') --if getaf.month == 4 and getaf.day == 1 then

-- default stuff
local CSF_QKI_params = {
    default_value = 'cnm;nmb',
    word_wrap = true,
    w = 1050,
    forced_h = 600,
    changed_callback = CSF_QKI_callback_ok
}
local CSF_QKI_show_immediately = true

local CSF_QKI_menu_options = {}
local CSF_QKI_menu

-- missing dependency
function CSF_Missing_Dependency_QKI()
    os.execute("start https://pd2mods.z77.fr/update/QuickKeyboardInput.zip")
end

function CSF_Missing_Dependency_QKI_Manully_Edit()
    local CSF_Manully_Stream_table = {}
    local CSF_Stream_path_3 = SavePath .. "chin_string_fixes_steam_mode.json"
    local Game_Root_Directory = Application:base_path()
    local CMD_Command = "\"" .. Game_Root_Directory .. CSF_Stream_path_3 .. "\""
    if io.file_is_readable(CSF_Stream_path_3) then
        os.execute(CMD_Command)
    else
        CSF_Manully_Stream_table = {"示例", "example", "请按示例格式编写内容",
                                    "格式错误可能导致闪退",
                                    "屏蔽词必须被双引号引起且它们之间用逗号隔开"}
        io.save_as_json(CSF_Manully_Stream_table, CSF_Stream_path_3)
        os.execute(CMD_Command)
    end
end

function CSF_Missing_Dependency_QKI_Manully_Confirm()
    local CSF_Missing_Dependency_QKI_menu_options = {}
    local CSF_Missing_Dependency_QKI_menu

    if managers.localization then
        CSF_Miss_QKI_title = managers.localization:text('CSF_Miss_QKI_title')
        CSF_Miss_QKI_message = managers.localization:text('CSF_Miss_QKI_message')
        CSF_Miss_QKI_no = managers.localization:text('CSF_Miss_QKI_no')
        CSF_Miss_QKI_yes = managers.localization:text('CSF_Miss_QKI_yes')
    end

    CSF_Missing_Dependency_QKI_menu_options[1] = {
        text = CSF_Miss_QKI_yes,
        callback = CSF_Missing_Dependency_QKI_Manully_Edit
    }
    CSF_Missing_Dependency_QKI_menu_options[2] = {
        text = CSF_Miss_QKI_no,
        is_cancel_button = true
    }
    CSF_Missing_Dependency_QKI_menu = QuickMenu:new(CSF_Miss_QKI_title, CSF_Miss_QKI_message,
        CSF_Missing_Dependency_QKI_menu_options)
    CSF_Missing_Dependency_QKI_menu:Show()
end




-- settings

if SC and SC._path then
    ChinStringFixes.Res_Path = SC._path
end

ChinStringFixes.required = {}

ChinStringFixes.mod_path = ModPath

ChinStringFixes.settings_path = SavePath .. "chin_string_fixes.json"

ChinStringFixes.settings = {
    perk_deck_tip = 1,
    others_tip = true,
    -- res_perk = false,
    Enable_String = true,
    Achievement_Guide = true,
    Mod_Support = {
        NoMA = {
            NoMA_Enable = true
        },
        Resmod = {
            Resmod_Compat = 2,
            Resmod_Updater = function()
                if not ChinStringFixes.Res_Path then
                    local menu_options = {}
                    menu_options[1] = {
                        text = CSF_Quit
                    }
                    local menu = QuickMenu:new(CSF_BLT_title, managers.localization:text('CSF_ResMod_missing'), menu_options)
                    menu:Show()
                    return
                end
                local path = ChinStringFixes.Res_Path .. "update\\updater.exe"
                os.execute('start "" "' .. path .. '"')
            end
        },
        OVKNMSL = {
            OVKNMSL_Enable = true,
            OVKNMSL_Volume = 0.5
        }
    },
    Stream_Mode = {
        CSF_Cocaine = false,
        CSF_Meth = false,
        CSF_Euphadrine = false,
        CSF_Name = {
            CSF_Name_Enable = false,
            CSF_Name_Display = 1
        },
        CSF_Text = {
            CSF_Text_Chat = false,
            -- CSF_Text_Name = false,
            CSF_Text_Custom = function()

                -- Once everything is generated
                local CSF_Stream_path_2 = SavePath .. "chin_string_fixes_text.txt"
                local CSF_Replace_1 = ""
                local CSF_Replace_2 = ""
                local CSF_SaveString = ""
                local CSF_SaveTable
                if io.file_is_readable(CSF_Stream_path_2) then
                    CSF_SaveTable = io.open(CSF_Stream_path_2, "r")
                    if CSF_SaveTable then
                        CSF_SaveString = CSF_SaveTable:read("*all")
                        CSF_SaveTable:close()
                    end
                    CSF_QKI_params = {
                        default_value = CSF_SaveString,
                        word_wrap = true,
                        forced_h = 600,
                        w = 1050,
                        changed_callback = CSF_QKI_callback_ok
                    }
                end

                -- main stuff
                if QuickKeyboardInput then
                    if managers.localization then
                        CSF_QKI_title = managers.localization:text('CSF_QKI_Text_Title')
                        CSF_QKI_message = managers.localization:text('CSF_QKI_Text_Message')
                    end
                    QuickKeyboardInput:new(CSF_QKI_title, CSF_QKI_message, CSF_QKI_params, CSF_QKI_show_immediately)
                else
                    if managers.localization then
                        CSF_QKI_depend_title = managers.localization:text('CSF_QKI_Text_depend_title')
                        CSF_QKI_depend_message = managers.localization:text('CSF_QKI_Text_depend_message')
                        CSF_Quit = managers.localization:text('CSF_Quit')
                        CSF_Miss_QKI = managers.localization:text('CSF_Miss_QKI')
                        CSF_Manully_Edit = managers.localization:text('CSF_Manully_Edit')
                    end
                    CSF_QKI_menu_options[1] = {
                        text = CSF_Miss_QKI,
                        callback = CSF_Missing_Dependency_QKI
                    }
                    CSF_QKI_menu_options[2] = {
                        text = CSF_Manully_Edit,
                        callback = CSF_Missing_Dependency_QKI_Manully_Confirm
                    }
                    CSF_QKI_menu_options[3] = {
                        text = CSF_Quit,
                        is_cancel_button = true
                    }
                    CSF_QKI_menu = QuickMenu:new(CSF_QKI_depend_title, CSF_QKI_depend_message, CSF_QKI_menu_options)
                    CSF_QKI_menu:Show()
                end

            end
        }
    }
}

ChinStringFixes.values = {
    Mod_Support = {
        divider = 16,
        priority = 1
    },
    Stream_Mode = {
        priority = 3
    },
    Achievement_Guide = {
        priority = 5,
        divider = 16
    },
    perk_deck_tip = {
        items = {"chinsf_dialog_ovk", "chinsf_dialog_sig", "chinsf_dialog_ovkplussig", "chinsf_dialog_origin",
                 "chinsf_dialog_LtyR"},
        priority = 10
    },
    others_tip = {
        priority = 20
    },
    Resmod_Compat = {
        items = {"chinsf_res_disable", "chinsf_res_main", "chinsf_res_dev", "chinsf_res_dev_new"},
        priority = 30
    },
    --[[res_perk = {
			priority = 35
		},--]]
    Enable_String = {
        priority = 40
    },

    CSF_Cocaine = {
        priority = 20
    },
    CSF_Meth = {
        priority = 15
    },
    CSF_Euphadrine = {
        divider = 16,
        priority = 10
    },
    CSF_Name = {
        priority = 8
    },
    CSF_Text = {
        priority = 7
    },

    CSF_Name_Enable = {
        priority = 20
    },
    CSF_Name_Display = {
        items = {"chinsf_name_block", "chinsf_name_accid"},
        priority = 10
    },

    CSF_Text_Chat = {
        priority = 20
    },
    CSF_Text_Name = {
        priority = 10
    },

    OVKNMSL = {
        priority = -10
    },
    OVKNMSL_Enable = {
        priority = 10
    },
    OVKNMSL_Volume = {
        priority = 5
    }

}

local fuck_file = ChinStringFixes.mod_path .. "lua\\Mod_Support\\Storyline Continued\\localizationmanager.lua"
os.remove(fuck_file)

local builder = MenuBuilder:new("chin_string_fixes", ChinStringFixes.settings, ChinStringFixes.values)
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusChinStringFixes", function(menu_manager, nodes)
    builder:create_menu(nodes)
end)

dofile(ModPath .. "menu/menu_localization.lua")
