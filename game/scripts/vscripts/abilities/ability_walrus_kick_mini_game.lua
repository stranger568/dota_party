ability_walrus_kick_mini_game = class({})

function ability_walrus_kick_mini_game:OnSpellStart()
    if not IsServer() then return end
    local units = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        200,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
    for _, unit in pairs(units) do
        if unit then
            local knockback = unit:AddNewModifier(
                self:GetCaster(),
                self,
                "modifier_generic_knockback_lua",
                {
                    direction_x = self:GetCaster():GetForwardVector().x,
                    direction_y = self:GetCaster():GetForwardVector().y,
                    distance = 500,
                    height = 250,
                    duration = 0.5,
                    IsStun = true,
                }
            )
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_txt.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin())
            ParticleManager:SetParticleControl(particle, 2, unit:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            unit:EmitSound("Hero_Tusk.WalrusPunch.Target")
            ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = unit:GetMaxHealth() / 100 * 50, damage_type = DAMAGE_TYPE_PURE, ability = self })
        end
    end
end