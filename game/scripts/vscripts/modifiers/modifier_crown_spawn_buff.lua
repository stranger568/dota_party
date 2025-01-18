modifier_crown_spawn_buff = class({})
function modifier_crown_spawn_buff:IsPurgable() return false end
function modifier_crown_spawn_buff:IsHidden() return true end
function modifier_crown_spawn_buff:OnCreated()
    self:StartIntervalThink(1)
end
function modifier_crown_spawn_buff:OnIntervalThink()
    if not IsServer() then return end
    MiniGamesLib:UpdateScore(self:GetCaster():GetPlayerOwnerID(), 1)
end
function modifier_crown_spawn_buff:GetEffectName()
    return "particles/leader/leader_overhead.vpcf"
end
function modifier_crown_spawn_buff:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end