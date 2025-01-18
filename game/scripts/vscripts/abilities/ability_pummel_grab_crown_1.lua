LinkLuaModifier("modifier_ability_pummel_grab_crown_1", "abilities/ability_pummel_grab_crown_1", LUA_MODIFIER_MOTION_NONE)

ability_pummel_grab_crown_1 = class({})

function ability_pummel_grab_crown_1:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Hoodwink.Scurry.Cast")
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_pummel_grab_crown_1", {duration = 3})
    self:SetHidden(true)
end

modifier_ability_pummel_grab_crown_1 = class({})
function modifier_ability_pummel_grab_crown_1:IsPurgable() return false end
function modifier_ability_pummel_grab_crown_1:RemoveOnDeath() return false end
function modifier_ability_pummel_grab_crown_1:IsPurgeException() return false end
function modifier_ability_pummel_grab_crown_1:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, true, false)
end
function modifier_ability_pummel_grab_crown_1:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end
function modifier_ability_pummel_grab_crown_1:GetModifierMoveSpeed_Absolute()
    return 750
end