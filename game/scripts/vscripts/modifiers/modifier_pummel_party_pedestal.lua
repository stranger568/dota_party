modifier_pummel_party_pedestal = class({})
function modifier_pummel_party_pedestal:IsHidden() return true end
function modifier_pummel_party_pedestal:IsPurgable() return false end
function modifier_pummel_party_pedestal:IsPurgeException() return false end
function modifier_pummel_party_pedestal:RemoveOnDeath() return false end
function modifier_pummel_party_pedestal:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }
end