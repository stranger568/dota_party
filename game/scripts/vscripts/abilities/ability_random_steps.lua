LinkLuaModifier("modifier_ability_random_steps_count", "abilities/ability_random_steps", LUA_MODIFIER_MOTION_NONE)

ability_random_steps = class({})

function ability_random_steps:OnSpellStart()
    if not IsServer() then return end
    local steps = RandomInt(1, 9)
    Timers:CreateTimer(0.25, function()
        if self:GetCaster().particle_dice then
            ParticleManager:DestroyParticle(self:GetCaster().particle_dice, false)
            ParticleManager:ReleaseParticleIndex(self:GetCaster().particle_dice)
            self:GetCaster().particle_dice = nil
        end
        self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_ability_random_steps_count", {count = steps})
        HubGame:PlayerSelectSteps(self:GetCaster():GetPlayerOwnerID(), steps)
    end)
    self:SetHidden(true)
end

modifier_ability_random_steps_count = class({})
function modifier_ability_random_steps_count:IsPurgable() return false end
function modifier_ability_random_steps_count:IsPurgeException() return false end
function modifier_ability_random_steps_count:OnCreated(data)
    if not IsServer() then return end
    self:SetStackCount(data.count)
    self.particle_step = ParticleManager:CreateParticle("particles/step_particle_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.particle_step, 1, Vector(0, self:GetStackCount(), 0))
    self:AddParticle(self.particle_step, false, false, -1, false, false)
end

function modifier_ability_random_steps_count:OnStackCountChanged(iStackCount)
    if not IsServer() then return end
    if self.particle_step then
        ParticleManager:SetParticleControl(self.particle_step, 1, Vector(0, self:GetStackCount(), 0))
    end
end

function modifier_ability_random_steps_count:OnDestroy()
    if not IsServer() then return end
    if self.particle_step then
        ParticleManager:DestroyParticle(self.particle_step, true)
    end
end