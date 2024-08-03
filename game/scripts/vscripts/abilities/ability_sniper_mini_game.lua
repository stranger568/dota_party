ability_sniper_mini_game = class({})

function ability_sniper_mini_game:OnSpellStart()
    if not IsServer() then return end
    local direction = self:GetCaster():GetForwardVector()

    local projectile =
    {
        Ability = self,
        EffectName = "particles/sniper_q/sniper_q.vpcf",
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        fDistance = 2250,
        fStartRadius = 50,
        fEndRadius = 50,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit = false,
        vVelocity = direction * 2300,
        bProvidesVision = false,
    }
    self:GetCaster():EmitSound("Ability.Assassinate")
    ProjectileManager:CreateLinearProjectile(projectile)
end

function ability_sniper_mini_game:OnProjectileHit(target, vLocation)
    if target then
        target:Kill(self, self:GetCaster())
        Timers:CreateTimer(1, function()
            local respawnpoint = target.MINIGAME_RESPAWN_POS
            if respawnpoint == nil then
                respawnpoint = target:GetAbsOrigin()
            end
            target:RespawnHero(false, false)
            FindClearSpaceForUnit(target, respawnpoint, true)
        end)
    end
    return true
end