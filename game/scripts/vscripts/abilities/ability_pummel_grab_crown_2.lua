LinkLuaModifier("modifier_ability_pummel_grab_crown_2", "abilities/ability_pummel_grab_crown_2", LUA_MODIFIER_MOTION_NONE)

ability_pummel_grab_crown_2 = class({})

function ability_pummel_grab_crown_2:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Dark_Seer.Surge")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_pummel_grab_crown_2", {duration = 3})
    self:SetHidden(true)
end

modifier_ability_pummel_grab_crown_2 = class({})
function modifier_ability_pummel_grab_crown_2:IsPurgable() return false end
function modifier_ability_pummel_grab_crown_2:RemoveOnDeath() return false end
function modifier_ability_pummel_grab_crown_2:IsPurgeException() return false end
function modifier_ability_pummel_grab_crown_2:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
end
function modifier_ability_pummel_grab_crown_2:CheckState()
    return
    {
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end
function modifier_ability_pummel_grab_crown_2:GetModifierMoveSpeed_Absolute()
    return 750
end
function modifier_ability_pummel_grab_crown_2:GetEffectName()
	return "particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf"
end
function modifier_ability_pummel_grab_crown_2:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_ability_pummel_grab_crown_2:GetModifierInvisibilityLevel()
	return 1
end