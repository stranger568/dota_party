modifier_warning_light_thinker = class({})
function modifier_warning_light_thinker:IsPurgable() return false end
function modifier_warning_light_thinker:IsPurgeException() return false end
function modifier_warning_light_thinker:OnCreated()
    if not IsServer() then return end
    self.radius = 500
    self.warning_light_spawn = Entities:FindByName(nil, "warning_light_spawn")
    self.cooldown = 3
    self:StartIntervalThink(3)
end

function modifier_warning_light_thinker:OnIntervalThink()
    if not IsServer() then return end
    if self.new_position then
        local direction = (self.new_position - self:GetParent():GetAbsOrigin())
        direction.z = 0
        local length = direction:Length2D()
        direction = direction:Normalized()
        if length > 50 then
            local new_point = self:GetParent():GetAbsOrigin() + direction * (1200 * FrameTime())
            self:GetParent():SetAbsOrigin(new_point)
        else
            self.new_position = self.warning_light_spawn:GetAbsOrigin() + RandomVector(RandomInt(400, 2000))
        end
        for i=0,20 do
            AddFOWViewer(i, self:GetParent():GetAbsOrigin(), self.radius, FrameTime()*2, false)
        end
        self.cooldown = math.max(0, self.cooldown - FrameTime())
        if RollPercentage(10) and self.cooldown <= 0 then
            self.cooldown = 10
            local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            for _, unit in pairs(units) do
                if unit and unit:IsRealHero() then
                    self.new_position = unit:GetAbsOrigin() + RandomVector(100)
                end
            end
        end
        local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, unit in pairs(units) do
            if unit and unit:IsRealHero() then
                ApplyDamage({victim = unit, attacker = unit, damage = (unit:GetMaxHealth() / 100 * 25) * FrameTime(), damage_type = DAMAGE_TYPE_PURE})
                if not unit:IsAlive() then
                    table.insert(MiniGamesLib.QUEUE_PLAYERS, unit:GetPlayerOwnerID())
                end
            end
        end
        return
    end
    self:StartLight()
end

function modifier_warning_light_thinker:StartLight()
    if not IsServer() then return end
    self.new_position = self.warning_light_spawn:GetAbsOrigin() + RandomVector(RandomInt(400, 2000))
    self:GetParent():SetAbsOrigin(self.new_position)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ringmaster/ringmaster_spotlight_lightshaft.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, self.radius, self.radius))
    self:AddParticle(particle, false, false, -1, false, false)
    self.new_position = self.warning_light_spawn:GetAbsOrigin() + RandomVector(RandomInt(400, 2000))
    self:GetParent():EmitSound("Hero_Ringmaster.SpotLight.Cast")
    self:StartIntervalThink(FrameTime())
end