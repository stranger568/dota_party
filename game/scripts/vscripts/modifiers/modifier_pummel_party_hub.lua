modifier_pummel_party_hub = class({})
function modifier_pummel_party_hub:IsHidden() return true end
function modifier_pummel_party_hub:IsPurgable() return false end
function modifier_pummel_party_hub:IsPurgeException() return false end
function modifier_pummel_party_hub:RemoveOnDeath() return false end
function modifier_pummel_party_hub:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end