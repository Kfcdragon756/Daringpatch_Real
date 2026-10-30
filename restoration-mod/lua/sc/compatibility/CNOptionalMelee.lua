-- Restoration replaces this method directly after Murasama registers its hook.
-- Rebind the current CN method through BLT so the existing force-use hook runs.
if BeardLib.Utils:FindMod("HF Murasama") then
    Hooks:OverrideFunction(PlayerStandard, "_check_action_melee", PlayerStandard._check_action_melee)
end
