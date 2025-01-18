modifier_hot_potato_debuff = class({})
function modifier_hot_potato_debuff:IsHidden() return true end
function modifier_hot_potato_debuff:IsPurgable() return false end

function modifier_hot_potato_debuff:OnCreated()
    if not IsServer() then return end
    self.particle = ParticleManager:CreateParticle("particles/potato_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    local timer_x = math.ceil(self:GetRemainingTime()) / 10
    local timer_y = math.ceil(self:GetRemainingTime()) % 10
    ParticleManager:SetParticleControl(self.particle, 1, Vector(timer_x, timer_y, 0))
    self:AddParticle(self.particle, false, false, -1, false, false)
    self.sound = 0
    self:StartIntervalThink(0.1)
end

function modifier_hot_potato_debuff:OnIntervalThink()
    if not IsServer() then return end
    if self.particle then
        local timer_x = math.floor(math.ceil(self:GetRemainingTime()) / 10)
        local timer_y = math.ceil(self:GetRemainingTime()) % 10
        print(timer_x, timer_y)
        ParticleManager:SetParticleControl(self.particle, 1, Vector(timer_x, timer_y, 0))
    end
    self.sound = self.sound + 0.1
    if self.sound >= 0.6 then
        self:GetParent():EmitSound("Hero_Techies.RemoteMine.Activate")
        self.sound = 0
    end
end

function modifier_hot_potato_debuff:GetEffectName()
    return "particles/econ/events/ti10/hot_potato/hot_potato_debuff.vpcf"
end

function modifier_hot_potato_debuff:OnDestroy()
    if not IsServer() then return end
    if self:GetRemainingTime() <= 0.1 then
        self:GetParent():ForceKill(false)
        table.insert(MiniGamesLib.QUEUE_PLAYERS, self:GetParent():GetPlayerOwnerID())
        MiniGamesLib:UpdatePotato(nil, 30)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
        ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, Vector(200, 200, 200))
        ParticleManager:ReleaseParticleIndex(particle)
        self:GetParent():EmitSound("Hero_Techies.Suicide")
    end
end