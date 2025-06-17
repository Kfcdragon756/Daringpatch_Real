dofile(ModPath .. "automenubuilder.lua")

ChinStringFixes = class()

ChinStringFixes.settings = {
    perk_deck_tip = 1,
    -- res_perk = false,
    others_tip = true,
    Enable_String = true,
    Achievement_Guide = true,
    Mod_Support = {
        NoMA = {
            NoMA_Enable = true
        },
        Resmod = {
            Resmod_Compat = 2
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
            CSF_Text_Chat = false --[[,
				CSF_Text_Name = false--]]
        }
    }
}

ChinStringFixes.values = {
    perk_deck_tip = {"chinsf_dialog_ovk", "chinsf_dialog_sig", "chinsf_dialog_ovkplussig", "chinsf_dialog_origin",
                     "chinsf_dialog_LtyR"},
    Resmod_Compat = {"chinsf_res_disable", "chinsf_res_main", "chinsf_res_dev", "chinsf_res_dev_new"},
    CSF_Name_Display = {"chinsf_name_block", "chinsf_name_accid"}
}

ChinStringFixes.order = {
    Mod_Support = 1,
    Stream_Mode = 3,
    Achievement_Guide = 5,
    perk_deck_tip = 10,
    others_tip = 11,
    Resmod_Compat = 12,
    -- res_perk = 13,
    Enable_String = 14,

    CSF_Cocaine = 20,
    CSF_Meth = 15,
    CSF_Euphadrine = 10,
    CSF_Name = 8,
    CSF_Text = 7,

    CSF_Text_Chat = 20,
    CSF_Text_Name = 10,

    OVKNMSL = -10,
    OVKNMSL_Enable = 10,
    OVKNMSL_Volume = 5
}

ChinStringFixes.required = {}

ChinStringFixes.mod_path = ModPath

ChinStringFixes.settings_path = SavePath .. "chin_string_fixes.txt"

AutoMenuBuilder:load_settings(ChinStringFixes.settings, "chin_string_fixes")
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusChinStringFixes", function(menu_manager, nodes)

    AutoMenuBuilder:create_menu_from_table(nodes, ChinStringFixes.settings, "chin_string_fixes", "blt_options",
        ChinStringFixes.values, ChinStringFixes.order)
end)

dofile(ModPath .. "menu/menu_localization.lua")

