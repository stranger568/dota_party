modifier_pummel_party_pre_mini_game = class({})
function modifier_pummel_party_pre_mini_game:IsHidden() return true end
function modifier_pummel_party_pre_mini_game:IsPurgable() return false end
function modifier_pummel_party_pre_mini_game:IsPurgeException() return false end
function modifier_pummel_party_pre_mini_game:RemoveOnDeath() return false end
function modifier_pummel_party_pre_mini_game:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end