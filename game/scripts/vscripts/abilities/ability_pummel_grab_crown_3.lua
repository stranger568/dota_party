LinkLuaModifier("modifier_ability_pummel_grab_crown_3", "abilities/ability_pummel_grab_crown_3", LUA_MODIFIER_MOTION_NONE)

ability_pummel_grab_crown_3 = class({})

function ability_pummel_grab_crown_3:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Dark_Seer.Surge")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_pummel_grab_crown_3", {duration = 3})
    self:SetHidden(true)
end

modifier_ability_pummel_grab_crown_3 = class({})
function modifier_ability_pummel_grab_crown_3:IsPurgable() return false end
function modifier_ability_pummel_grab_crown_3:RemoveOnDeath() return false end
function modifier_ability_pummel_grab_crown_3:IsPurgeException() return false end
function modifier_ability_pummel_grab_crown_3:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end
function modifier_ability_pummel_grab_crown_3:GetModifierMoveSpeed_Absolute()
    return 850
end
function modifier_ability_pummel_grab_crown_3:GetEffectName()
	return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end
function modifier_ability_pummel_grab_crown_3:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end