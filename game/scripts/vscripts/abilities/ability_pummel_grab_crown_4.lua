LinkLuaModifier("modifier_ability_pummel_grab_crown_4", "abilities/ability_pummel_grab_crown_4", LUA_MODIFIER_MOTION_NONE)

ability_pummel_grab_crown_4 = class({})

function ability_pummel_grab_crown_4:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Ability.Windrun")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_pummel_grab_crown_4", {duration = 3})
    self:SetHidden(true)
end

modifier_ability_pummel_grab_crown_4 = class({})
function modifier_ability_pummel_grab_crown_4:IsPurgable() return false end
function modifier_ability_pummel_grab_crown_4:RemoveOnDeath() return false end
function modifier_ability_pummel_grab_crown_4:IsPurgeException() return false end
function modifier_ability_pummel_grab_crown_4:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end
function modifier_ability_pummel_grab_crown_4:GetModifierMoveSpeed_Absolute()
    return 750
end
function modifier_ability_pummel_grab_crown_4:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end
function modifier_ability_pummel_grab_crown_4:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end