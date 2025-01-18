ability_pummel_grab_crown_6 = class({})

function ability_pummel_grab_crown_6:OnSpellStart()
    if not IsServer() then return end
    local direction = self:GetCaster():GetForwardVector()
    local distance = 600
    local point = self:GetCaster():GetAbsOrigin() + direction * distance
    for i=1, distance / 10 do
        local check_pos = self:GetCaster():GetAbsOrigin() + direction * (10 * i)
        if not GridNav:CanFindPath(self:GetCaster():GetAbsOrigin(), check_pos) then
            point = self:GetCaster():GetAbsOrigin() + direction * (10 * i-1)
            break
        end
    end
    self:GetCaster():EmitSound("Hero_FacelessVoid.TimeWalk")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_walk_preimage.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, point)
    ParticleManager:SetParticleControlEnt(particle, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetForwardVector(), true)
    ParticleManager:ReleaseParticleIndex(particle)
    FindClearSpaceForUnit(self:GetCaster(), point, true)
    self:SetHidden(true)
end