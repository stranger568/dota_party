LinkLuaModifier("modifier_gift_or_ability_center_buff", "modifiers/modifier_gift_or_ability_center", LUA_MODIFIER_MOTION_NONE)

modifier_gift_or_ability_center = class({})

function modifier_gift_or_ability_center:IsAura()
    return true
end

function modifier_gift_or_ability_center:GetModifierAura()
    return "modifier_gift_or_ability_center_buff"
end

function modifier_gift_or_ability_center:GetAuraRadius()
    return 1000
end

function modifier_gift_or_ability_center:GetAuraDuration()
    return 0
end

function modifier_gift_or_ability_center:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_gift_or_ability_center:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_gift_or_ability_center:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

modifier_gift_or_ability_center_buff = class({})

function modifier_gift_or_ability_center_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1)
end

function modifier_gift_or_ability_center_buff:OnIntervalThink()
    if not IsServer() then return end
    if not self:GetParent():IsAlive() then return end
    MiniGamesLib:UpdateScore(self:GetParent():GetPlayerOwnerID(), 1)
end