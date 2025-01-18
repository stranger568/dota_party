ability_walrus_punch_mini_game = class({})

function ability_walrus_punch_mini_game:OnSpellStart()
    if not IsServer() then return end
    local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
    self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
    local modifier_ability_pummel_grab_crown_2 = self:GetCaster():FindModifierByName("modifier_ability_pummel_grab_crown_2")
    if modifier_ability_pummel_grab_crown_2 then
        modifier_ability_pummel_grab_crown_2:Destroy()
    end
    for _, unit in pairs(units) do
        if unit and (unit:HasModifier("modifier_crown_spawn_buff") or IsInToolsMode()) then
            if not unit:HasModifier("modifier_ability_pummel_grab_crown_4") then
                local knockback = unit:AddNewModifier(
                    self:GetCaster(),
                    self,
                    "modifier_generic_knockback_lua",
                    {
                        direction_x = unit:GetForwardVector().x,
                        direction_y = unit:GetForwardVector().y,
                        distance = 0,
                        height = 150,
                        duration = 0.5,
                        IsStun = true,
                    }
                )
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_txt.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
                ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(particle, 2, unit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                unit:EmitSound("Hero_Tusk.WalrusPunch.Target")
                local modifier_crown_spawn_buff = unit:FindModifierByName("modifier_crown_spawn_buff")
                if modifier_crown_spawn_buff then
                    modifier_crown_spawn_buff:Destroy()
                    self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_crown_spawn_buff", {})
                end
                if IsInToolsMode() then
                    if not modifier_crown_spawn_buff then
                        unit:AddNewModifier(self:GetCaster(), nil, "modifier_crown_spawn_buff", {})
                    end
                end
            end
        end
    end
end