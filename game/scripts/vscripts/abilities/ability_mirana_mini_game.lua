ability_mirana_mini_game = class({})

function ability_mirana_mini_game:OnSpellStart()
    if not IsServer() then return end
    local direction = self:GetCaster():GetForwardVector()
    local projectile =
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
        vSpawnOrigin = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_hitloc")),
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
        vVelocity = direction * 1600,
        bProvidesVision = false,
        ExtraData = {x = self:GetCaster():GetAbsOrigin().x, y = self:GetCaster():GetAbsOrigin().y}
    }
    self:GetCaster():EmitSound("Hero_Mirana.ArrowCast")
    ProjectileManager:CreateLinearProjectile(projectile)
end

function ability_mirana_mini_game:OnProjectileHit_ExtraData(target, vLocation, data)
    if target then
        target:EmitSound("Hero_Mirana.ArrowImpact")
        local direction = target:GetAbsOrigin() - Vector(data.x, data.y, 0)
        local distance = direction:Length2D()
        direction.z = 0
        direction = direction:Normalized()
        local distance_knockback = RandomInt(150, 300)
        if distance > 300 then
            distance_knockback = RandomInt(500, 650)
        end
        local knockback = target:AddNewModifier(
            self:GetCaster(),
            self,
            "modifier_generic_knockback_lua",
            {
                direction_x = direction.x,
                direction_y = direction.y,
                distance = distance_knockback,
                duration = 0.3,
                IsStun = true,
            }
        )
    end
    return true
end