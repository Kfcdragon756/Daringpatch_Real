-- CN optional weapon compatibility; baseline and sources are recorded outside the mod.
local aliases = {["wpn_fps_ass_ar23_barrel"]="wpn_fps_ass_ar23_b_std",["wpn_fps_ass_ar23_ext_std"]="wpn_fps_ass_ar23_ns_std",["wpn_fps_ass_ar23_body"]="wpn_fps_ass_ar23_receiver_std",["wpn_fps_ass_ar23_dh"]="wpn_fps_ass_ar23_dustcover_std",["wpn_fps_ass_ar23_mag"]="wpn_fps_ass_ar23_m_std",["wpn_fps_ass_ar23_laser"]="wpn_fps_upg_hd2_fl_laser",["wpn_fps_ass_ar23_optic"]="wpn_fps_upg_hd2_4x_scope_ar23",["wpn_fps_ass_ar23_optic_ck"]="wpn_fps_upg_hd2_4x_scope_ar23",["wpn_fps_ass_ar23_optic_steelsight"]="wpn_fps_upg_hd2_4x_scope_ar23_steelsight",["wpn_fps_ass_ar23_optic_2"]="wpn_fps_upg_hd2_2x_scope_ar23",["wpn_fps_ass_ar23_optic_2_steelsight"]="wpn_fps_upg_hd2_2x_scope_ar23_steelsight",["wpn_fps_ass_ar23_optic_3"]="wpn_fps_upg_hd2_holo_sight_ar23",["wpn_fps_ass_ar23_optic_3_ck"]="wpn_fps_upg_hd2_holo_sight_ar23",["wpn_fps_ass_ar23_optic_3_steelsight"]="wpn_fps_upg_hd2_1_5x_scope_ar23_steelsight",["wpn_fps_ass_ar23_o_carbine"]="wpn_fps_upg_hd2_1x_scope_ar23",["wpn_fps_ass_ar23_o_carbine_ck"]="wpn_fps_upg_hd2_1x_scope_ar23",["wpn_fps_ass_ar23_b_carbine"]="wpn_fps_ass_ar23_b_std",["wpn_fps_ass_ar23_ext_carbine_dummy"]="wpn_fps_ass_ar23_ns_std",["wpn_fps_ass_ar23_ck_carbine"]="wpn_fps_ck_ar23a",["wpn_fps_ass_ar23_ck_penetrator"]="wpn_fps_ck_ar23p",["wpn_fps_ass_ar23_ck_concussive"]="wpn_fps_ck_ar23c"}
local legacy_values = {["wpn_fps_ass_ar23_barrel"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_ext_std"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_body"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_dh"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_mag"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_laser"]={["stats"]={["value"]=0,["concealment"]=0,["spread"]=0,["recoil"]=0},["custom_stats"]=nil,["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic"]={["stats"]={["value"]=1,["zoom"]=30},["custom_stats"]={["big_scope"]=true,["ads_speed_mult"]=1.09},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_ck"]={["stats"]={["value"]=1,["zoom"]=30},["custom_stats"]={["big_scope"]=true,["ads_speed_mult"]=1.09},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_steelsight"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_2"]={["stats"]={["value"]=1,["base_zoom_off"]=1,["zoom"]=10},["custom_stats"]={["ads_speed_mult"]=1},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_2_steelsight"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_3"]={["stats"]={["value"]=1,["zoom"]=5},["custom_stats"]={["ads_speed_mult"]=1.015},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_3_ck"]={["stats"]={["value"]=1,["zoom"]=5},["custom_stats"]={["ads_speed_mult"]=1.015},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_optic_3_steelsight"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_o_carbine"]={["stats"]={["value"]=1,["zoom"]=1},["custom_stats"]={["ads_speed_mult"]=1},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_o_carbine_ck"]={["stats"]={["value"]=1,["zoom"]=1},["custom_stats"]={["ads_speed_mult"]=1},["supported"]=true,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_b_carbine"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_ext_carbine_dummy"]={["stats"]={["value"]=0},["custom_stats"]=nil,["supported"]=nil,["keep_damage"]=nil,["override_weapon"]=nil},["wpn_fps_ass_ar23_ck_carbine"]={["stats"]={["value"]=10,["concealment"]=2,["zoom"]=-9,["recoil"]=-6,["spread"]=-6},["custom_stats"]={["ads_speed_mult"]=0.95,["alt_desc"]="bm_wp_ck_carbine_desc",["rof_mult"]=1.4375,["falloff_start_mult"]=0.66667,["falloff_end_mult"]=0.75},["supported"]=true,["keep_damage"]=true,["override_weapon"]=nil},["wpn_fps_ass_ar23_ck_penetrator"]={["stats"]={["value"]=10,["concealment"]=-3,["zoom"]=20,["spread"]=2,["recoil"]=-4,["damage"]=-5},["custom_stats"]={["hs_mult"]=1.384615,["hs_mult_desc"]=true,["ammo_pickup_min_mul"]=1.2,["damage_min_mult"]=1.385,["alt_desc"]="bm_wp_ck_penetrator_desc",["alt_ammo_pickup_max_mul"]=1.2,["alt_ammo_pickup_min_mul"]=1.2,["armor_piercing_override"]=0.5,["ammo_pickup_max_mul"]=1.2,["falloff_start_mult"]=0.8333,["falloff_end_mult"]=0.9166},["supported"]=true,["keep_damage"]=true,["override_weapon"]=nil},["wpn_fps_ass_ar23_ck_concussive"]={["stats"]={["value"]=10,["concealment"]=-1,["zoom"]=-5,["spread"]=-3,["recoil"]=-6,["damage"]=-3},["custom_stats"]={["rof_mult"]=0.625,["ignore_rof_mult_anims"]=true,["alt_desc"]="bm_wp_ck_concussive_desc",["damage_min_mult"]=1.2,["info_burst_to_auto"]=true,["natascha"]=2000,["block_burst"]=true,["falloff_start_mult"]=0.5,["falloff_end_mult"]=0.5},["supported"]=true,["keep_damage"]=true,["override_weapon"]=nil}}
local legacy_visible = {["wpn_fps_ass_ar23_barrel"]=false,["wpn_fps_ass_ar23_ext_std"]=false,["wpn_fps_ass_ar23_body"]=false,["wpn_fps_ass_ar23_dh"]=false,["wpn_fps_ass_ar23_mag"]=false,["wpn_fps_ass_ar23_laser"]=true,["wpn_fps_ass_ar23_optic"]=true,["wpn_fps_ass_ar23_optic_ck"]=false,["wpn_fps_ass_ar23_optic_steelsight"]=false,["wpn_fps_ass_ar23_optic_2"]=false,["wpn_fps_ass_ar23_optic_2_steelsight"]=false,["wpn_fps_ass_ar23_optic_3"]=true,["wpn_fps_ass_ar23_optic_3_ck"]=false,["wpn_fps_ass_ar23_optic_3_steelsight"]=false,["wpn_fps_ass_ar23_o_carbine"]=true,["wpn_fps_ass_ar23_o_carbine_ck"]=false,["wpn_fps_ass_ar23_b_carbine"]=false,["wpn_fps_ass_ar23_ext_carbine_dummy"]=false,["wpn_fps_ass_ar23_ck_carbine"]=true,["wpn_fps_ass_ar23_ck_penetrator"]=true,["wpn_fps_ass_ar23_ck_concussive"]=true}
local promo = {["type"]="sight",["a_obj"]="a_o",["has_description"]=true,["desc_id"]="bm_wp_promo_irons_desc",["unit"]="units/mods/weapons/wpn_fps_upg_ar23_o_promo/wpn_fps_upg_ar23_o_promo",["third_unit"]="units/mods/weapons/wpn_fps_upg_ar23_o_promo/wpn_fps_upg_ar23_o_promo",["hidden"]=false,["global_value"]="helldivers2_mod",["stats"]={["value"]=1},["supported"]=true,["custom_stats"]=nil}

local dummy = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy"
local ar23_factory = "wpn_fps_ass_ar23"
local kits = {
    wpn_fps_ass_ar23_ck_carbine = "wpn_fps_ass_ar23_o_carbine_ck",
    wpn_fps_ass_ar23_ck_penetrator = "wpn_fps_ass_ar23_optic_ck",
    wpn_fps_ass_ar23_ck_concussive = "wpn_fps_ass_ar23_optic_3_ck"
}

local function append_unique(list, value)
    if not table.contains(list, value) then list[#list + 1] = value end
end

local function copy_values(part, values, include_stats)
    if include_stats then part.stats = deep_clone(values.stats) end
    part.custom_stats = values.custom_stats and deep_clone(values.custom_stats) or nil
    part.supported = values.supported
    part.keep_damage = values.keep_damage
    part.override_weapon = values.override_weapon and deep_clone(values.override_weapon) or nil
end

local function extend_alias_references(part)
    if part.override then
        for old_id, new_id in pairs(aliases) do
            if part.override[new_id] and not part.override[old_id] then
                part.override[old_id] = deep_clone(part.override[new_id])
            end
        end
    end
    if part.forbids then
        for old_id, new_id in pairs(aliases) do
            -- Forced sights have separate hidden IDs so a conversion can add them.
            if legacy_visible[old_id] and table.contains(part.forbids, new_id) then
                append_unique(part.forbids, old_id)
            end
        end
    end
end

local function repair_missing_unit(parts, id, absent_path, correct_unit, correct_third_unit)
    local part = parts[id]
    if part and correct_unit and not DB:has(Idstring("unit"), Idstring(absent_path))
        and DB:has(Idstring("unit"), Idstring(correct_unit)) then
        part.unit = correct_unit
        part.third_unit = correct_third_unit or correct_unit
        local thq = Idstring(correct_unit .. "_thq")
        part.supports_sync = DB:has(Idstring("material_config"), thq)
        part.cc_thq_material_config = part.supports_sync and thq or nil
    end
end

-- The original callback assumes every second sight has a TTI stance. New sights
-- are allowed to omit it; keep the author's alignment for those that provide it.
if BeardLib.Utils:FindMod("Marlin Model 1894 Custom") then
    Hooks:RemovePostHook("M1894ModInit", WeaponFactoryTweakData)
    Hooks:PostHook(WeaponFactoryTweakData, "create_bonuses", "CNMarlinSightAlignment", function(self)
        local factory = self.wpn_fps_snp_m1894
        if not factory then return end
        local offset = Vector3(0.48, 6, -1.8)
        for _, id in ipairs(factory.uses_parts) do
            local part = self.parts[id]
            if part and (part.type == "sight" or part.type == "gadget") and part.stance_mod
                and part.stance_mod.wpn_fps_snp_tti then
                part.stance_mod.wpn_fps_snp_m1894 = deep_clone(part.stance_mod.wpn_fps_snp_tti)
            end
        end
        for _, part in pairs(self.parts) do
            if part.type == "second_sight" and part.a_obj == "a_o" and part.stance_mod then
                local stances = part.stance_mod
                if not stances.wpn_fps_snp_m1894 and stances.wpn_fps_snp_tti then
                    stances.wpn_fps_snp_m1894 = deep_clone(stances.wpn_fps_snp_tti)
                end
                local stance = stances.wpn_fps_snp_m1894
                if stance and stance.translation and not stance.offset_applied then
                    stance.translation = stance.translation + offset
                    stance.offset_applied = true
                end
            end
        end
    end)
end

Hooks:PostHook(WeaponFactoryTweakData, "create_bonuses", "CNOptionalWeaponFactoryCompatibility", function(self)
    if self.parts.wpn_fps_snp_pd3_lynx_scope_piggyback then
        self.parts.wpn_fps_snp_pd3_lynx_scope_piggyback.supported = true
    end
    repair_missing_unit(self.parts, "wpn_fps_x_smg_lc10_xmag_01",
        "units/mods/weapons/wpn_fps_smg_lc10_pts/wpn_fps_x_smg_lc10_xmag_01",
        "units/mods/weapons/wpn_fps_smg_lc10_pts/wpn_fps_smg_x_lc10_xmag_01")
    local m7_receiver = self.parts.wpn_fps_smg_m7caseless_receiver
    if m7_receiver then
        repair_missing_unit(self.parts, "wpn_fps_smg_m7caseless_receiver_dual",
            "units/mods/weapons/wpn_fps_smg_m7caseless_pts/wpn_fps_smg_m7caseless_receiver_dual",
            m7_receiver.unit, m7_receiver.third_unit)
    end
    local m203 = self.parts.wpn_fps_ass_contraband_gl_m203
    if m203 then
        repair_missing_unit(self.parts, "wpn_fps_snp_iuhTTIPlus_gl_m203",
            "units/mods/weapons/wpn_fps_snp_iuhTTIPlus_pts/wpn_fps_snp_iuhTTIPlus_gl_m203",
            m203.unit, m203.third_unit)
    end

    -- These sights were available in the previous pack; their weapon geometry is unchanged.
    local jackhammer = self.wpn_fps_shot_jackhammer
    if jackhammer then
        for _, id in ipairs({"wpn_fps_upg_o_sig", "wpn_fps_upg_o_xpsg33_magnifier"}) do
            if self.parts[id] then append_unique(jackhammer.uses_parts, id) end
        end
        if self.wpn_fps_shot_jackhammer_npc then
            self.wpn_fps_shot_jackhammer_npc.uses_parts = deep_clone(jackhammer.uses_parts)
        end
    end

    -- The unused old helper ID can remain in saved inventories. Recoil now lives on the weapon.
    if self.wpn_fps_snp_m107cq and not self.parts.wpn_fps_snp_m107cq_recoil_anim then
        self.parts.wpn_fps_snp_m107cq_recoil_anim = {
            type = "extra", unit = dummy, third_unit = dummy, hidden = true,
            custom = true, supported = true, stats = {value = 0}, stance_mod = {}
        }
    end

    local factory = self[ar23_factory]
    if not factory or not self.parts.wpn_fps_ass_ar23_receiver_std then return end

    local carbine = self.parts.wpn_fps_ck_ar23a
    local dustcover = carbine and carbine.override and carbine.override.wpn_fps_ass_ar23_dustcover_std
    if dustcover and dustcover.third_unit == "units/mods/weapons/wpn_third_ck_ar23a/wpn_third_ck_ar23c_dustcover" then
        dustcover.third_unit = "units/mods/weapons/wpn_third_ck_ar23a/wpn_third_ck_ar23a_dustcover"
    end

    for old_id in pairs(kits) do
        local part = self.parts[aliases[old_id]]
        if part then
            -- Keep v6's independent sight selection and geometry, with the original CN ballistics.
            copy_values(part, legacy_values[old_id], false)
        end
    end

    for old_id, new_id in pairs(aliases) do
        local source = self.parts[new_id]
        if source then
            local part = self.parts[old_id]
            if not part or part._cn_optional_alias then
                part = deep_clone(source)
                part._cn_optional_alias = true
                part.name_id = "bm_wp_" .. old_id
                part.hidden = not legacy_visible[old_id]
                -- Use v6 models and their animation attachments; retain v5 numeric effects.
                copy_values(part, legacy_values[old_id], true)
                self.parts[old_id] = part
            else
                -- A supplemented pack may already supply the ID and its own geometry.
                copy_values(part, legacy_values[old_id], true)
            end
            append_unique(factory.uses_parts, old_id)
        end
    end

    -- The separate charging handle and carbine barrel were folded into v6's animated units.
    for _, id in ipairs({"wpn_fps_ass_ar23_dh", "wpn_fps_ass_ar23_b_carbine", "wpn_fps_ass_ar23_ext_carbine_dummy"}) do
        local part = self.parts[id]
        if part and part._cn_optional_alias then
            part.unit, part.third_unit = dummy, dummy
            part.type, part.animations, part.adds = "extra", nil, nil
        end
    end

    if not self.parts.wpn_fps_upg_ar23_o_promo then
        self.parts.wpn_fps_upg_ar23_o_promo = deep_clone(promo)
        self.parts.wpn_fps_upg_ar23_o_promo.name_id = "bm_wp_wpn_fps_upg_ar23_o_promo"
        self.parts.wpn_fps_upg_ar23_o_promo.type = "sight"
        self.parts.wpn_fps_upg_ar23_o_promo.custom = true
    end
    local irons = self.parts.wpn_fps_upg_ar23_o_promo
    irons.stance_mod = irons.stance_mod or {}
    irons.stance_mod[ar23_factory] = irons.stance_mod[ar23_factory] or {translation = Vector3(-0.1, -13.2, 0.09)}
    append_unique(factory.uses_parts, "wpn_fps_upg_ar23_o_promo")

    extend_alias_references(factory)
    for _, part in pairs(self.parts) do extend_alias_references(part) end

    for id, forced_sight in pairs(kits) do
        local part = self.parts[id]
        if part and part._cn_optional_alias then
            part.adds = part.adds or {}
            append_unique(part.adds, forced_sight)
            part.override = part.override or {}
            for _, default_scope in ipairs({"wpn_fps_upg_hd2_2x_scope_ar23", "wpn_fps_ass_ar23_optic_2", "wpn_fps_upg_hd2_2x_scope_ar23_steelsight", "wpn_fps_ass_ar23_optic_2_steelsight"}) do
                part.override[default_scope] = part.override[default_scope] or {}
                part.override[default_scope].unit = dummy
                part.override[default_scope].third_unit = dummy
            end
        end
    end

    -- Give visible legacy options the same initial ownership as BeardLib's current parts.
    if TweakDataHelper and not self._cn_optional_loot_registered then
        self._cn_optional_loot_registered = true
        for id in pairs(aliases) do
            local part = self.parts[id]
            if part and legacy_visible[id] then
                part.dlc = part.dlc or "cn_optional_legacy"
                TweakDataHelper:ModifyTweak({{type_items = "weapon_mods", item_entry = id, amount = 1, global_value = part.global_value}}, "dlc", part.dlc, "content", "loot_drops")
            end
        end
        irons.dlc = irons.dlc or self.parts.wpn_fps_ck_ar23p.dlc or "cn_optional_legacy"
        TweakDataHelper:ModifyTweak({{type_items = "weapon_mods", item_entry = "wpn_fps_upg_ar23_o_promo", amount = 1, global_value = irons.global_value}}, "dlc", irons.dlc, "content", "loot_drops")
    end

    if self[ar23_factory .. "_npc"] then
        self[ar23_factory .. "_npc"].uses_parts = deep_clone(factory.uses_parts)
    end
end)
