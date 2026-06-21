local old_init = old_init or LootDropTweakData.init
 
function LootDropTweakData:init(tweak_data)
    old_init(self, tweak_data)
	
	for i = 10, 100, 10 do
		self.WEIGHTED_TYPE_CHANCE[i].weapon_mods = self.WEIGHTED_TYPE_CHANCE[i].weapon_mods + self.WEIGHTED_TYPE_CHANCE[i].cash + self.WEIGHTED_TYPE_CHANCE[i].xp
		self.WEIGHTED_TYPE_CHANCE[i].cash = 0
		self.WEIGHTED_TYPE_CHANCE[i].xp = 0
	end
	
	self.global_values.gage_pack_assault.value_multiplier = 0
	self.global_values.gage_pack_snp.value_multiplier = 0
    self.global_values.sc = {}
    self.global_values.sc.name_id = "loot_sc"
    self.global_values.sc.desc_id = "loot_sc_desc"
    self.global_values.sc.color = Color('FF69B4')
    self.global_values.sc.dlc = false
    self.global_values.sc.chance = 0.84
    self.global_values.sc.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
    self.global_values.sc.durability_multiplier = 1
    self.global_values.sc.drops = false
    self.global_values.sc.track = false
    self.global_values.sc.sort_number = 30
    self.global_values.sc.category = "sc"

    --此处添加
      --这是一件鹰姐的物品
    self.global_values.daring = {}
    self.global_values.daring.name_id = "loot_daring"  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.desc_id = "loot_daring_desc"  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.color = Color('009900')  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.dlc = false  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.chance = 0.84  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.durability_multiplier = 1  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.drops = false  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.track = false  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.sort_number = 30  -- [GPT合并1] ybspatch 新增/修改项
    self.global_values.daring.category = "daring"  -- [GPT合并1] ybspatch 新增/修改项
      --这是sbkfc的物品
      --[[self.global_values.sbkfc = {}
      self.global_values.sbkfc.name_id = "loot_sbkfc"  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.desc_id = "loot_sbkfc_desc"  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.color = Color('8B4513')  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.dlc = false  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.chance = 0.84  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.durability_multiplier = 1  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.drops = false  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.track = false  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.sort_number = 30  -- [GPT合并1] ybspatch 新增/修改项
      self.global_values.sbkfc.category = "sbkfc"  -- [GPT合并1] ybspatch 新增/修改项  --]]
    --到此结束

        self.global_values.sc_wcc = {}
        self.global_values.sc_wcc.name_id = "loot_sc_wcc"
        self.global_values.sc_wcc.desc_id = "loot_sc_wcc_desc"
        self.global_values.sc_wcc.color = Color('FF69B4')
        self.global_values.sc_wcc.dlc = false
        self.global_values.sc_wcc.chance = 0
        self.global_values.sc_wcc.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
        self.global_values.sc_wcc.durability_multiplier = 1
        self.global_values.sc_wcc.drops = false
        self.global_values.sc_wcc.track = false
        self.global_values.sc_wcc.sort_number = 31
        self.global_values.sc_wcc.category = "sc"
        self.global_values.sc_ocp = {}
        self.global_values.sc_ocp.name_id = "loot_sc_ocp"
        self.global_values.sc_ocp.desc_id = "loot_sc_ocp_desc"
        self.global_values.sc_ocp.color = Color('FF69B4')
        self.global_values.sc_ocp.dlc = false
        self.global_values.sc_ocp.chance = 0
        self.global_values.sc_ocp.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
        self.global_values.sc_ocp.durability_multiplier = 1
        self.global_values.sc_ocp.drops = false
        self.global_values.sc_ocp.track = false
        self.global_values.sc_ocp.sort_number = 32
        self.global_values.sc_ocp.category = "sc"
        self.global_values.sc_faco = {}
        self.global_values.sc_faco.name_id = "loot_sc_faco"
        self.global_values.sc_faco.desc_id = "loot_sc_faco_desc"
        self.global_values.sc_faco.color = Color('FF69B4')
        self.global_values.sc_faco.dlc = false
        self.global_values.sc_faco.chance = 0
        self.global_values.sc_faco.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
        self.global_values.sc_faco.durability_multiplier = 1
        self.global_values.sc_faco.drops = false
        self.global_values.sc_faco.track = false
        self.global_values.sc_faco.sort_number = 33
        self.global_values.sc_faco.category = "sc"

	--HERE I COME, ROUGHER THAN THE REST OF THEM 
    self.global_values.rest = {}
    self.global_values.rest.name_id = "menu_l_global_value_veritas"
    self.global_values.rest.desc_id = "menu_l_global_value_veritas_desc"
    self.global_values.rest.color = Color('A30C1D')
    self.global_values.rest.dlc = false
    self.global_values.rest.chance = 0
    self.global_values.rest.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
    self.global_values.rest.durability_multiplier = 1
    self.global_values.rest.drops = false
    self.global_values.rest.track = false
    self.global_values.rest.sort_number = 30
    self.global_values.rest.category = "rest"	
	
    self.global_values.rest_omnia = {}
    self.global_values.rest_omnia.name_id = "menu_l_global_value_omnia"
    self.global_values.rest_omnia.desc_id = "menu_l_global_value_omnia_desc"
    self.global_values.rest_omnia.color = Color('314E52')
	self.global_values.rest_omnia.dlc = false
    self.global_values.rest_omnia.chance = 0
    self.global_values.rest_omnia.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
    self.global_values.rest_omnia.durability_multiplier = 1
    self.global_values.rest_omnia.drops = false
    self.global_values.rest_omnia.track = false
	self.global_values.rest_omnia.hide_unavailable = true
    self.global_values.rest_omnia.sort_number = 30
    self.global_values.rest_omnia.category = "rest"		
	
	self.global_values.rest_omnia_fake = deep_clone(self.global_values.rest_omnia)
	self.global_values.rest_omnia_fake.dlc = true

    self.global_values.xmas_snowball.unlock_id = nil
end