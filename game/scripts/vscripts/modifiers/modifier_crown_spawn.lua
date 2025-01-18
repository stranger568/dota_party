modifier_crown_spawn = class({})
function modifier_crown_spawn:IsHidden() return true end
function modifier_crown_spawn:OnCreated()
    if not IsServer() then return end
    local particle = ParticleManager:CreateParticle("particles/leader/leader_overhead.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    self:AddParticle(particle, false, false, -1, false, false)
    self:StartIntervalThink(0.1)
end
function modifier_crown_spawn:OnIntervalThink()
    if not IsServer() then return end
    local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, 100, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
    if #units > 0 then
        local unit = units[1]
        if unit then
            unit:AddNewModifier(unit, nil, "modifier_crown_spawn_buff", {})
        end
        self:Destroy()
    end
end