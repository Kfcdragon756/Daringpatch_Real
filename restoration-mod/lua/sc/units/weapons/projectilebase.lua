local mvec1 = Vector3()
local mvec2 = Vector3()
local mrot1 = Rotation()

function ProjectileBase:update(unit, t, dt)

	--Something to cull
	if self._timer and self._no_timer and not self._collided then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._timer = nil
			self._no_timer = nil

			managers.game_play_central:remove_projectile_trail(self._unit)
			self._unit:set_slot(0)

			return
		end
	elseif not self._timer then
		self._timer = 10
		self._no_timer = true
	end

	if not self._simulated and not self._collided then
		self._unit:m_position(mvec1)
		mvector3.set(mvec2, self._velocity * dt)
		mvector3.add(mvec1, mvec2)
		self._unit:set_position(mvec1)

		if self._orient_to_vel then
			mrotation.set_look_at(mrot1, mvec2, math.UP)
			self._unit:set_rotation(mrot1)
		end

		self._velocity = Vector3(self._velocity.x, self._velocity.y, self._velocity.z - 980 * dt)
	end

	if self._sweep_data and not self._collided then
		self._unit:m_position(self._sweep_data.current_pos)

		local raycast_params = {
			"ray",
			self._sweep_data.last_pos,
			self._sweep_data.current_pos,
			"slot_mask",
			self._sweep_data.slot_mask
		}

		local col_ray = nil
		local ignore_units = {}

		if alive(self._thrower_unit) then
			--to avoid colliding with the thrower, this prevents NPCs from hitting themselves with the projectile when launching it, along with player husks when FF is enabled
			table.insert(ignore_units, self._thrower_unit)

			--if the thrower has a shield equipped, ignore it as well (pretty important, even if the shield throw animation is used and the throw is timed, a collision can still easily happen)
			if alive(self._thrower_unit:inventory() and self._thrower_unit:inventory()._shield_unit) then
				table.insert(ignore_units, self._thrower_unit:inventory()._shield_unit)
			end
		end

		if #ignore_units > 0 then
			col_ray = World:raycast("ray", self._sweep_data.last_pos, self._sweep_data.current_pos, "slot_mask", self._sweep_data.slot_mask, "ignore_unit", ignore_units) --prevent husks from hitting themselves with RPGs/grenade launchers
		else
			col_ray = World:raycast(unpack(raycast_params))
		end
		
		if self._sphere_cast_radius then
			table.list_append(raycast_params, {
				"sphere_cast_radius",
				self._sphere_cast_radius,
				"bundle",
				4
			})
		end		

		if self._draw_debug_trail then
			if self._sphere_cast_radius then
				Draw:brush(Color(0.25, 0, 0, 1), nil, 3):cylinder(self._sweep_data.last_pos, self._sweep_data.current_pos, self._sphere_cast_radius, 4)
			else
				Draw:brush(Color(1, 0, 0, 1), nil, 3):line(self._sweep_data.last_pos, self._sweep_data.current_pos)
			end
		end

		if col_ray and col_ray.unit then
			mvector3.direction(mvec1, self._sweep_data.last_pos, self._sweep_data.current_pos)
			mvector3.add(mvec1, col_ray.position)
			self._unit:set_position(mvec1)
			self._unit:set_position(mvec1)

			if self._draw_debug_impact then
				Draw:brush(Color(0.5, 0, 0, 1), nil, 10):sphere(col_ray.position, 4)
				Draw:brush(Color(0.5, 1, 0, 0), nil, 10):sphere(self._unit:position(), 3)
			end

			col_ray.velocity = self._unit:velocity()
			self._collided = true

			self:_on_collision(col_ray)
		end

		self._unit:m_position(self._sweep_data.last_pos)
	end
	
	if self._warning_fx_vfx_data then
		self:_warning_fx_vfx_upd(unit, t, dt, self._warning_fx_vfx_data)
	end
	
end

function ProjectileBase:create_sweep_data()
	self._sweep_data = {
		slot_mask = self._slot_mask
	}

	if Global.game_settings and Global.game_settings.one_down then
		self._sweep_data.slot_mask = self._sweep_data.slot_mask + 3
	else
		self._sweep_data.slot_mask = managers.mutators:modify_value("ProjectileBase:create_sweep_data:slot_mask", self._sweep_data.slot_mask)
		self._sweep_data.slot_mask = managers.modifiers:modify_value("ProjectileBase:create_sweep_data:slot_mask", self._sweep_data.slot_mask)
	end

	self._sweep_data.current_pos = self._unit:position()
	self._sweep_data.last_pos = mvector3.copy(self._sweep_data.current_pos)
end

-- Fuck it
function ProjectileBase.check_time_cheat(projectile_type, owner_peer_id)
	return true
end


function ProjectileBase:throw(params)
	self._owner = params.owner
	local velocity = params.dir
	local adjust_z = 50
	local launch_speed = 250
	local push_at_body_index = 0

	self._unit:body(0):set_collision_script_filter(0) --This stops "impact" detonation explosives from bouncing first when shooting close-by surfaces

	if params.projectile_entry and tweak_data.projectiles[params.projectile_entry] then
		adjust_z = tweak_data.projectiles[params.projectile_entry].adjust_z or adjust_z
		launch_speed = tweak_data.projectiles[params.projectile_entry].launch_speed or launch_speed
		push_at_body_index = tweak_data.projectiles[params.projectile_entry].push_at_body_index
	end
	velocity = velocity * launch_speed
	velocity = Vector3(velocity.x, velocity.y, velocity.z + adjust_z)
	local mass_look_up_modifier = self._mass_look_up_modifier or 2
	local mass = math.max(mass_look_up_modifier * (1 + math.min(0, params.dir.z)), 1)

	if self._simulated then
		if push_at_body_index then
			self._unit:push_at(mass, velocity, self._unit:body(push_at_body_index):center_of_mass())
		else
			self._unit:push_at(mass, velocity, self._unit:position())
		end
	else
		self._velocity = velocity
	end

	if params.projectile_entry and tweak_data.blackmarket.projectiles[params.projectile_entry] then
		local tweak_entry = tweak_data.blackmarket.projectiles[params.projectile_entry]
		local physic_effect = tweak_entry.physic_effect

		if physic_effect then
			World:play_physic_effect(physic_effect, self._unit)
		end

		if tweak_entry.add_trail_effect then
			self:add_trail_effect(tweak_entry.add_trail_effect)
		end

		local unit_name = tweak_entry.sprint_unit

		if unit_name then
			local new_dir = Vector3(params.dir.y * -1, params.dir.x, params.dir.z)
			local sprint = World:spawn_unit(Idstring(unit_name), self._unit:position() + new_dir * 50, self._unit:rotation())
			local rot = Rotation(params.dir, math.UP)

			mrotation.x(rot, mvec1)
			mvector3.multiply(mvec1, 0.15)
			mvector3.add(mvec1, new_dir)
			mvector3.add(mvec1, math.UP / 2)
			mvector3.multiply(mvec1, 100)
			sprint:push_at(mass, mvec1, sprint:position())
		end

		self:set_projectile_entry(params.projectile_entry)
	end
end

-- Load npc throwables dynamically
local unit_ids = Idstring("unit")
Hooks:PreHook(ProjectileBase, "throw_projectile_npc", "sh_throw_projectile_npc", function (projectile_type)
	local tweak_entry = tweak_data.blackmarket.projectiles[projectile_type]
	local unit_name = Idstring(not Network:is_server() and tweak_entry.local_unit or tweak_entry.unit)
	if not PackageManager:has(unit_ids, unit_name) then
		managers.dyn_resource:load(unit_ids, unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
	end
end)


--为HD2战备光束设置同步
if not HD2OffensiveRedTrail then

	HD2OffensiveRedTrail_res = HD2OffensiveRedTrail_res or {}

	function HD2OffensiveRedTrail_res:spawn(data)
		local effect_id = World:effect_manager():spawn({
			effect = Idstring("effects/particles/weapons/hd2offensive/hd2offensive_red_trail"),
			position = data.position,
			normal = Vector3(0,0,1)
		})

		local delayed_id = "HD2OffensiveRedTrail_res" .. tostring(effect_id)
		local delay = TimerManager:game():time() + data.timer

		managers.enemy:add_delayed_clbk(delayed_id, callback(self, self, "_kill", effect_id), delay)
	end

	function HD2OffensiveRedTrail_res:_kill(effect_id)
		if World:effect_manager():alive(effect_id) then
			World:effect_manager():kill(effect_id)
		end
	end

end

--为HD2战备HUD设置同步
if not HD2OffensiveHUD then
	HD2OffensiveHUD_res = HD2OffensiveHUD_res or class()

	function HD2OffensiveHUD_res:init(data)
		--self._id = tostring(data.id)
		self._id = "HD2oHUD" .. tostring(data.position) .. tostring(TimerManager:main():time())
		self._position = data.position
		self._left_time = data.time
		self._duration = data.duration
		self._progress = data.progress
	
		self._wait_text = managers.localization:to_upper_text("hud_hd2offensive_inbound") .. " "
	
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		local hud_panel = hud.panel
	
		self._panel = hud_panel:panel({
			w = 200,
			h = 45
		})
	
		--- [[ Left
		self._base_panel = self._panel:panel({
			w = 30,
			h = self._panel:h()	
		})
	
		local base_panel = self._base_panel
	
		-- base_panel:set_left(0)
		base_panel:set_center_y(self._panel:h() / 2)
	
		local bg_size_sub = 5
		local bg = base_panel:bitmap({
			render_template = "VertexColorTexturedBlur3D",
			texture = "guis/textures/test_blur_df",
			w = base_panel:w() - bg_size_sub,
			h = base_panel:w() - bg_size_sub,
			color = Color.white
		})
	
		bg:set_center_x(base_panel:w() / 2)
		bg:set_center_y(bg:h() / 2 + bg_size_sub - 2.5)
	
		if data.name_id then
			local stratagem_icon = base_panel:bitmap({
				texture = "guis/dlcs/pd2_dlc_hd2o/textures/pd2/hud/icons/" .. data.name_id,
				layer = 2,
				w = 32,
				h = 32
			})
	
			stratagem_icon:set_center(bg:center_x(), bg:center_y())
		end
		
		local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local arrow = base_panel:bitmap({
			visible = true,
			color = Color.yellow,
			rotation = 180,
			texture = arrow_icon,
			texture_rect = arrow_texture_rect,
			w = 12,
			h = 6
		})
	
		arrow:set_center_x(bg:center_x())
		arrow:set_bottom(base_panel:bottom() - 1)
	
		self._distance = base_panel:text({
			font = tweak_data.hud_players.ammo_font,
			text = "0",
			vertical = "bottom",
			align = "center",
			font_size = 10
		})
	
		self._distance:set_center_x(bg:center_x())
		self._distance:set_bottom(arrow:top())
		-- ]]
	
		--- [[ Right
		local bname = data.name_id and managers.localization:to_upper_text(data.name_id)
	
		local name_text = nil
		if bname then
			name_text = self._panel:text({
				font = tweak_data.hud_players.ammo_font,
				text = bname,
				-- vertical = "top",
				-- align = "left",
				font_size = 15,
				color = Color.red
			})
	
			name_text:set_left(base_panel:right())
		end
	
		self._time_text = self._panel:text({
			font = tweak_data.hud_players.ammo_font,
			text = self._wait_text .. os.date("%M:%S", self._left_time),
			vertical = "top",
			align = "left",
			font_size = 15
		})
	
	
		self._time_text:set_left(base_panel:right())
	
		if name_text then
			self._time_text:set_top(15)
		end
		-- ]]
	
		-- 添加update
		managers.hud:add_updator(self._id, callback(self, self, "update"))
	end
	
	function HD2OffensiveHUD_res:update(t, dt)
		local camera = managers.viewport:get_current_camera()
	
		if not camera then
			return
		end
	
		-- 获取并设置HUD在self._position上的2D空间位置
		local ws = managers.hud._workspace
		local screen_pos = ws:world_to_screen(camera, self._position)
		self._panel:set_left(screen_pos.x - self._base_panel:w() / 2)
		self._panel:set_bottom(screen_pos.y)
	
		-- 获取并设置玩家距离HUD原点的距离
		local distance = mvector3.distance(camera:position(), self._position)
		local m_text = managers.localization:text("hud_hd2offensive_m")
		self._distance:set_text(tostring(math.floor(distance / 100)) .. m_text)
	
		-- 检测HUD有没有在视野范围内
		if screen_pos.z > 1 then
			local screen_center = Vector3(ws:panel():center_x(), ws:panel():center_y(), 0)
			local HUDPos = Vector3(screen_pos.x, screen_pos.y, 0)
			local cen_to_hud_dis = mvector3.distance(screen_center, HUDPos)
	
			local max_alpha_dis = 150  -- 准心低于HUD距离多少开始透明度衰减
			local min_alpha = 0.6  -- 最低的(不)透明度
			if cen_to_hud_dis < max_alpha_dis then
				local new_alpha = math.max(cen_to_hud_dis / max_alpha_dis, min_alpha)
				self._panel:set_alpha(new_alpha)
			else
				self._panel:set_alpha(1)
			end
		else
			self._panel:set_alpha(0)
		end
	
		if self._left_time > 0 then
			self._left_time = self._left_time - dt
			self._time_text:set_text(self._wait_text .. os.date("%M:%S", self._left_time))
		elseif self._duration > 0 then
			self._duration = self._duration - dt
	
			local text = managers.localization:to_upper_text("hud_hd2offensive_impact")
	
			if self._progress then
				text = managers.localization:to_upper_text("hud_hd2offensive_ongoing")
				text = text .. " " .. os.date("%M:%S", self._duration)
			end
	
			self._time_text:set_text(text)
		end
	
		-- 如果倒计时结束，摧毁HUD
		if (self._left_time + self._duration) <= 0 then
			self:destroy()  -- 摧毁HUD
	
			managers.hud:remove_updator(self._id)  -- 关闭update
		end
	end
	
	function HD2OffensiveHUD_res:destroy()
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		local hud_panel = hud.panel
		hud_panel:remove(self._panel)
	end

end