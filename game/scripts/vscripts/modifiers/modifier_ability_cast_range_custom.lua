modifier_ability_cast_range_custom = class({})
function modifier_ability_cast_range_custom:IsHidden() return true end
function modifier_ability_cast_range_custom:IsPurgable() return false end
function modifier_ability_cast_range_custom:IsPurgeException() return false end
function modifier_ability_cast_range_custom:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_CAST_RANGE_BONUS,
    }
end
function modifier_ability_cast_range_custom:GetModifierCastRangeBonus()
    return 5000
end
function modifier_ability_cast_range_custom:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
    }
end