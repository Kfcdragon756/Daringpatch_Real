local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
local difficulty_index = tweak_data:difficulty_to_index(difficulty)
local pro_job = Global.game_settings and Global.game_settings.one_down
local chance_dozer_var = math.rand(1)
local chance_dozer = 75
local hunt_projob = false
local dozer_check_d = dozer_check_d or 0
--set up the table for the randomizer
local dozer_table = {
	dozer_green = "units/payday2/characters/ene_bulldozer_1_sc/ene_bulldozer_1_sc",
	dozer_black = "units/payday2/characters/ene_bulldozer_2_sc/ene_bulldozer_2_sc",
	dozer_skull = "units/pd2_mod_lapd/characters/ene_bulldozer_3/ene_bulldozer_3",
	dozer_zeal_benelli = "units/pd2_dlc_gitgud/characters/ene_bulldozer_minigun/ene_bulldozer_minigun",
	dozer_zeal_black = "units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3_sc/ene_zeal_bulldozer_3_sc",
	dozer_zeal_skull = "units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_sc/ene_zeal_bulldozer_sc",
	dozer_titan = "units/pd2_dlc_vip/characters/ene_vip_2_assault/ene_vip_2_assault"
}
local Daring_dozer_spring = "units/pd2_dlc_vip/characters/ene_spring/ene_spring"
local Daring_spring_crew = dozer_table.dozer_black
local Daring_enable_spring = nil

--If we're in Pro Job, then do this stuff below
if pro_job then
		hunt_projob = true
	--DSPJ has 100% of spawning the scripted dozer
	if difficulty_index == 8 then
		chance_dozer = 100
	end
end

	--Setting up the dozer randomizer, oh yeah
	if difficulty_index == 6 or difficulty_index == 7 then
		if chance_dozer_var < 0.35 then
			dozer = dozer_table.dozer_skull
		elseif chance_dozer_var < 0.70 then
			dozer = dozer_table.dozer_black
		else
			dozer = dozer_table.dozer_green
		end
		Daring_spring_crew = dozer
		Daring_enable_spring = true
	end

	if difficulty_index == 8 then
		Daring_spring_crew = dozer_table.dozer_zeal_benelli
		Daring_enable_spring = true
		if chance_dozer_var < 0.25 then
			dozer = dozer_table.dozer_zeal_black
		elseif chance_dozer_var < 0.50 then
			dozer = dozer_table.dozer_zeal_skull
		elseif chance_dozer_var < 0.75 then
			dozer = dozer_table.dozer_titan
		else
			dozer = dozer_table.dozer_zeal_benelli
		end
	end

	if difficulty_index <= 5 then
		ponr_value = 540	
	elseif difficulty_index == 6 or difficulty_index == 7 then
		ponr_value = 480	
	else
		ponr_value = 420	
	end
	

return {
	--Pro Job PONR
	[100818] = {
		ponr = ponr_value,
		hunt = hunt_projob
	},
	--Should fix enemies getting stuck
	[101088] = {
		values = {
			enabled = true
		}
	},
	[101238] = {
		values = {
			enabled = true
		}
	},
	[100999] = {
		values = {
			enabled = true
		}
	},
	[101265] = {
		values = {
			enabled = true
		}
	},
	[101262] = {
		values = {
			enabled = true
		}
	},
	[101264] = {
		values = {
			enabled = true
		}
	},
	--Fixed snipers being able to spawn only once
	[100368] = {
		values = {
            trigger_times = 0
		}
	},
	[100369] = {
		values = {
            trigger_times = 0
		}
	},
	[100370] = {
		values = {
            trigger_times = 0
		}
	},
	[100371] = {
		values = {
            trigger_times = 0
		}
	},
	[100372] = {
		values = {
            trigger_times = 0
		}
	},
	[100373] = {
		values = {
            trigger_times = 0
		}
	},
	[100374] = {
		values = {
            trigger_times = 0
		}
	},
	[100375] = {
		values = {
            trigger_times = 0
		}
	},
	[100376] = {
		values = {
            trigger_times = 0
		}
	},
	[100377] = {
		values = {
            trigger_times = 0
		}
	},
	--Technically should fix softlock when blowtorch interactions are unavailable. Also player can't abuse keys in loud
	[102704] = {
		on_executed = {
			{id = 101278, delay = 0}
		}
	},
	--Allow plant c4 when escape sequence is started (At least this works when player picked up c4 before escape trigger)
	[102146] = {
		values = {
			enabled = false
		}
	},
	[100821] = {
		values = {
			trigger_times = 1
		}
	},
	[102127] = {
		values = {
			trigger_times = 1
		}
	},
	--Always comment that all c4 are placed (why it's chance based to begin with, Overkill...)
	[103810] = {
		values = {
            chance = 100
		}
	},
	-- Need for scripted dozer changes
	[103809] = {
		on_executed = {
			{id = 102869, delay = 0}
		}
	},
	-- 100% chance to spawn dozer on DS
	[102869] = {
		values = {
            chance = chance_dozer
		}
	},
	--Dozer gets randomized + repositioned to the boat loot drop point
	[102870] = {
		pre_func = function (self)
			if not Daring_enable_spring then
				return
			end
			if dozer_check_d and dozer_check_d ~= 0 then
				return
			end

			local function Daring_Spawn_Spring()
				if not Utils or not Utils.IsInHeist or not Utils:IsInHeist() then
					return
				end
				local pos_spring = Vector3(-5450, 5087, -399.229)
				local pos_crew_1 = Vector3(-5394, 4986.5, -399.229)
				local pos_crew_2 = Vector3(-5506, 4986.5, -399.229)
  				local rot = Rotation(180, 0, -0)
  				local unit_idstr = Idstring(Daring_dozer_spring)

  				--[[local player_pos_check = nil
  				local player_position = managers.player and managers.player.player_unit() and managers.player:player_unit():position()
  				managers.mission._fading_debug_output:script().log("player pos "..player_position.x, Color.white)
  				if player_position and player_position.x < 5000 and player_position.y > 5000 then
  					player_pos_check = true
  				end]]

  				local spring_area_used = nil
  				for id = 1,4,1 do
  					local client_position = managers.network._session:peer(id) and managers.network._session:peer(id):unit() and managers.network._session:peer(id):unit():position()
  					if client_position then
  						if client_position.y > 4785 and client_position.z < 105 then
  							pos_spring = Vector3(-1366.96, 4886.84, 525)
							pos_crew_1 = Vector3(-1489.19, 4974.09, 525)
							pos_crew_2 = Vector3(-1190.24, 4808.77, 525)
  							spring_area_used = true
  						end
  						if spring_area_used then
  							if (client_position.y > 4710.82 and client_position.y < 5128.52 and client_position.z > 139.061) or (client_position.x > -1584.37 and client_position.x < -1135.6 and client_position.z > -153.645) then
  								pos_spring = Vector3(-2533.21, 5243.91, 539.063)
								pos_crew_1 = Vector3(-2827.67, 5244.9, 539.063)
								pos_crew_2 = Vector3(-2283.91, 5245.22, 539.063)
								break
  							end
  						end
  					end
  				end


				local team_daring_script = managers.groupai:state():team_data("law1")

				--if PackageManager:has(Idstring("unit"), unit_idstr) then
					local unit_spawn = World:spawn_unit(unit_idstr, pos_spring, rot)
					unit_spawn:movement():set_team(team_daring_script)
				--end
			
				local unit_ben = Idstring(Daring_spring_crew)
				--if PackageManager:has(Idstring("unit"), unit_ben) then
			
					local unit_1 = World:spawn_unit(unit_ben, pos_crew_1, rot)
					unit_1:movement():set_team(team_daring_script)

					local unit_2 = World:spawn_unit(unit_ben, pos_crew_2, rot)
					unit_2:movement():set_team(team_daring_script)

				--end
				if dozer_check_d then
					dozer_check_d = dozer_check_d + 1
				end
			end

			DelayedCalls:Add("RES_Script_Daring_Spawn_Spring", 2, Daring_Spawn_Spring)

		end,
		values = {
            enemy = dozer,
			position = Vector3(-4627, 5521, -400),
			rotation = Rotation(140, 0, -0)
		}--[[,
		on_executed = {
			{id = 'daring', delay = 0}
		}--]]
	},
	--[[['daring'] = {
		values = {
            enemy = Daring_dozer_spring,
			position = Vector3(-4627, 5521, -400),
			rotation = Rotation(140, 0, -0)
		}
	},--]]
	[101190] = {
		reinforce = {
			{
				name = "store_front1",
				force = 3,
				position = Vector3(-2000, 300, -10)
			},
			{
				name = "store_front2",
				force = 3,
				position = Vector3(-1000, 300, -10)
			}
		}
	},
	[101647] = {
		reinforce = {
			{
				name = "store_front2"
			},
			{
				name = "back_alley",
				force = 3,
				position = Vector3(-1400, 4900, 540)
			}
		}
	}
}