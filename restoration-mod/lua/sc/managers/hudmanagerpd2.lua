HUDManager._USE_BURST_MODE = true

HUDManager.set_teammate_weapon_firemode_burst = HUDManager.set_teammate_weapon_firemode_burst or function(self, id)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_weapon_firemode_burst(id)
end

Hooks:PreHook(HUDManager, "show_point_of_no_return_timer", "res_show_point_of_no_return_timer", function(self)
	if managers.groupai:state():use_ponr_music() then
		local ponr_track = managers.music:jukebox_menu_track("ponr")
		local assault = managers.music:track_listen_start("music_heist_assault", ponr_track)
		managers.music:post_event(assault)
	end
end)

function HUDManager:on_ineffective_hit_confirmed(damage_scale)
	if not managers.user:get_setting("hit_indicator") then
		return
	end

	self._hud_hit_confirm:on_ineffective_hit_confirmed(damage_scale)
end

function HUDManager:on_effective_hit_confirmed(damage_scale)
	if not managers.user:get_setting("hit_indicator") then
		return
	end

	self._hud_hit_confirm:on_effective_hit_confirmed(damage_scale)
end

 -- MUI HUD support to let it show absolute Leech notches instead of the vanilla relative ones.
if MUITeammate then
	local function MUISetNewHealthValue(self)
		if not self._muiHealthNr then return; end
		if self._health_numbers then
			local data = self._health_data;
			local Value = math.clamp(data.current / data.total, 0, 1);
			local real_value = math.round((data.total * 10) * Value);
			self._health_numbers:set_text(real_value);
			if real_value > 35 then
				self._health_numbers:show();
				self._health_numbers:set_color(Color(71 / 255, 255 / 255, 120 / 255), Color.black:with_alpha(0.5));
			elseif real_value < 35 and not self._custardy then
				self._health_numbers:set_color(Color.red:with_alpha(0.8));
			elseif self._custardy then
				self._health_numbers:hide();
			end
		end
	end

	function MUITeammate:set_health(data)
		self._health_data = data;
		MUISetNewHealthValue(self);

		local dt, dc = data.total, data.current;
		local hp, rip = self._radial_health, self._radial_rip;
		local radial_rip_bg = self.radial_rip_bg;
		local red = data.current / data.total;
		if not self._custardy and dc <= 0 then
			self._custardy = true;
		end
		if dc > 0 then
			self._custardy = false;
		end

		if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and self._id == HUDManager.PLAYER_PANEL and not (self._muiLeech or self._muiColor) then
			local static_damage_segment_size = managers.player:upgrade_value_nil("player", "copr_static_damage_ratio")
			hp:stop();

			if static_damage_segment_size then
				local static_damage_ratio = static_damage_segment_size / data.total
				red = math.floor((red + 0.01) / static_damage_ratio) * static_damage_ratio
			end

			local copr_overlay_panel = self.copr_overlay_panel;

			if alive(copr_overlay_panel) then
				for _, notch in ipairs(copr_overlay_panel:children()) do
					notch:set_visible(notch:script().red <= red + 0.01);
				end
			end

			if red < hp:color().red then
				self:_damage_taken();
				hp:set_color(Color(1, red, 1, 1));
			else
				hp:animate(function(o)
					local s = hp:color().r;
					local e = red;
					local health_ratio = nil;

					over(0.2, function(p)
						health_ratio = math.lerp(s, e, p);

						hp:set_color(Color(1, health_ratio, 1, 1));

						if alive(copr_overlay_panel) then
							for _, notch in ipairs(copr_overlay_panel:children()) do
								notch:set_visible(notch:script().red <= health_ratio + 0.01);
							end
						end
					end)
				end)
			end
		end

		if self._main_player and rip:visible() then
			self:rot_radial(rip, dc, dt, self._muiHPASPD);
		end

		self:set_radial(hp, (self._muiColor and dt - dc or dc), dt, self._muiHPASPD);
		self:update_delayed_damage();
		self:update_absorb();
	end

end



--要害防护HUD
Hooks:PostHook(HUDManager, "init", "HUDManagerSwanSongEffectModifierInit_Liberty", function(self)
	self._swan_song_left_modifier_t = 0
	self._swan_song_alpha_left = 0
end)

Hooks:PostHook(HUDManager, "update", "HUDManagerSwanSongEffectModifierUpdate_Liberty", function(self, t, dt)
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	if not hud.panel:child("swan_song_left_modifier") then
		local swan_song_left_modifier = hud.panel:bitmap({
			name = "swan_song_left_modifier",
			visible = false,
			texture = "guis/textures/alphawipe_test",
			layer = 0,
			color = Color(0, 0.7, 1),
			blend_mode = "add",
			w = hud.panel:w(),
			h = hud.panel:h(),
			x = 0,
			y = 0 
		})
	end

	local swan_song_left_modifier = hud.panel:child("swan_song_left_modifier")
	if swan_song_left_modifier and self._swan_song_left_modifier_t > 0 then
		swan_song_left_modifier:set_visible(true)

		local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		--swan_song_left_modifier:animate(hudinfo.flash_icon, 4000000000)
		
		if self._swan_song_alpha_left >= self._swan_song_left_modifier_t then
			swan_song_left_modifier:set_alpha(self._swan_song_left_modifier_t / self._swan_song_alpha_left)
		end

		self._swan_song_left_modifier_t = self._swan_song_left_modifier_t  - dt
	elseif swan_song_left_modifier then
		swan_song_left_modifier:set_visible(false)
	end
end)

function HUDManager:SetLibertySaveEffect(time, color)
	self._swan_song_left_modifier_t = time * 0.7
	self._swan_song_alpha_left = time * 0.3
	
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local swan_song_left_modifier = hud.panel:child("swan_song_left_modifier")
	
	if swan_song_left_modifier then
		swan_song_left_modifier:set_alpha(1)
		
		if color then
			swan_song_left_modifier:set_color(color)
		end
	end
end