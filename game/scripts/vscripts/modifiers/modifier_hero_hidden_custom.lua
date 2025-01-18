modifier_hero_hidden_custom = class({})
function modifier_hero_hidden_custom:IsHidden() return true end
function modifier_hero_hidden_custom:IsPurgable() return false end
function modifier_hero_hidden_custom:IsPurgeException() return false end
function modifier_hero_hidden_custom:OnCreated()
    if not IsServer() then return end
    self:GetParent():AddNoDraw()
end
function modifier_hero_hidden_custom:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
    }
end