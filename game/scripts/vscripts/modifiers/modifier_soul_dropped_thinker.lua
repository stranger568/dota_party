modifier_soul_dropped_thinker = class({})
function modifier_soul_dropped_thinker:IsHidden() return true end
function modifier_soul_dropped_thinker:IsPurgable() return false end
function modifier_soul_dropped_thinker:IsPurgeException() return false end
function modifier_soul_dropped_thinker:OnCreated()
    if not IsServer() then return end
    self.target = nil
    self.particle = ParticleManager:CreateParticle("particles/soul/thresh_base_passive_soul.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
    self:StartIntervalThink(FrameTime())
end
function modifier_soul_dropped_thinker:OnIntervalThink()
    if not IsServer() then return end
    if not self.target then
        local heroes = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _,hero in pairs(heroes) do
            self.target = hero
            break
        end
    end
    local target = self.target
    if target then
        local direction = target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
        direction.z = 0
        local distance = direction:Length2D()
        direction = direction:Normalized()
        local new_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + direction * (550 * FrameTime()), nil)
        self:GetParent():SetAbsOrigin(new_pos)
        if self.particle then
            ParticleManager:SetParticleControl(self.particle, 0, new_pos)
        end
        if distance < 50 then
            player_system:HeroModifyKeys(target:GetPlayerOwnerID(), 1)
            self:Destroy()
        end
    end
end