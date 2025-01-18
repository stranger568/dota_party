modifier_magma_block_custom = class({})
function modifier_magma_block_custom:IsPurgable() return false end
function modifier_magma_block_custom:IsPurgeException() return false end
function modifier_magma_block_custom:OnCreated()
    if not IsServer() then return end
    self.radius = 150
    self:StartIntervalThink(FrameTime())
end

function modifier_magma_block_custom:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, unit in pairs(units) do
        if unit and unit:IsRealHero() then
            ApplyDamage({victim = unit, attacker = unit, damage = (unit:GetMaxHealth() / 100 * 20) * FrameTime(), damage_type = DAMAGE_TYPE_PURE})
            if not unit:IsAlive() then
                table.insert(MiniGamesLib.QUEUE_PLAYERS, unit:GetPlayerOwnerID())
            end
        end
    end
end