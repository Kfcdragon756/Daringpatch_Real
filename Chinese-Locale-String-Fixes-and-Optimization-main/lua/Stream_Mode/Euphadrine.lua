
Hooks:Add("LocalizationManagerPostInit", "ChinStringFixes_Stream_Euphadrine", function(loc)

	LocalizationManager:add_localized_strings({

		--hud
    	hud_carry_euphadrine_pills = "黄连素药片",
    	hud_heist_nail_1_hl = "加入黄连素药片",
    	hud_heist_nail_4 = "这一批制好了。你们想继续的话就再加一些黄连素药片。或者桶子上有个被盖住的信号棒。撤离载具已经准备好来接应你们了。",
    	hud_heist_nail_1 = "冰毒制作的第一道工序是加入黄连素药片。去找一些来放进标记的容器里。",

    	--ingame
    	
    	--menu

    	--subtitles
    	pln_nai_03_03 = "好的，用黄连素开始这场炼金吧。向混合器里放些药片。",
    	pln_nai_03_01 = "我们需要加入黄连素药片以启动制盐。找一些加入到混合器中。",
    	pln_nai_03_02 = "首先找点黄连素药片，然后丢进混合器里去。"
	})

end)


