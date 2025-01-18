ability_normal_punch_mini_game = class({})

function ability_normal_punch_mini_game:OnSpellStart()
    if not IsServer() then return end
    self:GetCaster():EmitSound("Hero_Dark_Seer.NormalPunch.Lv3")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_punch_glove_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
    self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
    Timers:CreateTimer(0.2, function()
        local end_point = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 200
        local units = FindUnitsInLine( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), end_point, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES )
        for _, unit in pairs(units) do
            if unit then
                local modifier_hot_potato_debuff = self:GetCaster():FindModifierByName("modifier_hot_potato_debuff")
                if modifier_hot_potato_debuff then
                    local direction = unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
                    local distance = direction:Length2D()
                    direction.z = 0
                    direction = direction:Normalized()
                    local distance_knockback = 250
                    unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = 1})
                    local knockback = unit:AddNewModifier(
                        self:GetCaster(),
                        self,
                        "modifier_generic_knockback_lua",
                        {
                            direction_x = direction.x,
                            direction_y = direction.y,
                            distance = distance_knockback,
                            duration = 0.3,
                        }
                    )
                    unit:AddNewModifier(unit, nil, "modifier_hot_potato_debuff", {duration = modifier_hot_potato_debuff:GetRemainingTime()}) 
                    modifier_hot_potato_debuff:Destroy()
                end
                break
            end
        end
    end)
end