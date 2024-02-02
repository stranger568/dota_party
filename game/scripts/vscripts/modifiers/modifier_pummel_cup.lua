modifier_pummel_cup = class({})
function modifier_pummel_cup:IsHidden() return true end
function modifier_pummel_cup:IsPurgable() return false end
function modifier_pummel_cup:IsPurgeException() return false end
function modifier_pummel_cup:RemoveOnDeath() return false end
function modifier_pummel_cup:CheckState()
    return
    {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    }
end
function modifier_pummel_cup:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(FrameTime())
end
function modifier_pummel_cup:OnIntervalThink()
    if self:GetParent():GetAbsOrigin().z > GetGroundHeight(self:GetParent():GetAbsOrigin(), nil) then
        local new_origin = self:GetParent():GetAbsOrigin()
        new_origin.z = new_origin.z - 350 * FrameTime()
        self:GetParent():SetAbsOrigin(new_origin)
    else
        local effect_cast = ParticleManager:CreateParticle( "particles/cup_down.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetAbsOrigin() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 150, 150, 200 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
        self:StartIntervalThink(-1)
    end
end