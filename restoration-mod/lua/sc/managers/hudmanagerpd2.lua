HUDManager._USE_BURST_MODE = true	

local job = Global.level_data and Global.level_data.level_id

HUDManager.set_teammate_weapon_firemode_burst = HUDManager.set_teammate_weapon_firemode_burst or function(self, id)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_weapon_firemode_burst(id)
end

local ponr_random1 = math.random(50)

local show_point_of_no_return_timer_orig = HUDManager.show_point_of_no_return_timer
function HUDManager:show_point_of_no_return_timer(tweak_id)
	if not restoration.Options:GetValue("OTHER/MusicShuffle") then
		if managers.groupai:state()._ponr_is_on and Global.game_settings.one_down and restoration.Options:GetValue("OTHER/PONRTrack") then
			local ponr_track = managers.music:jukebox_menu_track("ponr")
			--Don't do it during stealth jeez!
			if not managers.groupai:state():whisper_mode() and not table.contains(restoration.alternate_ponr_behavior, job) then
				managers.music:post_event(managers.music:track_listen_start("music_heist_assault", ponr_track))
			end
		end
	end
	return show_point_of_no_return_timer_orig(self, tweak_id)
end

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