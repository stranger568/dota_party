ability_pummel_potato_1 = class({})

function ability_pummel_potato_1:OnSpellStart()
    if not IsServer() then return end
    local direction = self:GetCaster():GetForwardVector()
    local distance = 1200
    local point = self:GetCaster():GetAbsOrigin() + direction * distance
    local projectile = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
        vSpawnOrigin = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_hitloc")),
        fDistance = distance,
        fStartRadius = 125,
        fEndRadius = 125,
        Source = self:GetCaster(),
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        fExpireTime = GameRules:GetGameTime() + 5.0,
        bDeleteOnHit = false,
        vVelocity = direction * 1600,
        bProvidesVision = false
    }
    ProjectileManager:CreateLinearProjectile(projectile)
    self:SetHidden(true)
end

function ability_pummel_potato_1:OnProjectileHit(target, vLocation)
    if target then
        local modifier_hot_potato_debuff = self:GetCaster():FindModifierByName("modifier_hot_potato_debuff")
        if modifier_hot_potato_debuff then
            target:AddNewModifier(target, nil, "modifier_hot_potato_debuff", {duration = modifier_hot_potato_debuff:GetRemainingTime()}) 
            modifier_hot_potato_debuff:Destroy()
        end
        return true
    end
end