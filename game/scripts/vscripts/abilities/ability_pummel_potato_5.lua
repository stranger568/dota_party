ability_pummel_potato_5 = class({})

function ability_pummel_potato_5:OnSpellStart()
    if not IsServer() then return end
    local direction = self:GetCaster():GetForwardVector()
    local distance = 600
    local skewer_pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * distance
    for i=1, distance / 10 do
        local check_pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * (10 * i)
        if not GridNav:CanFindPath(self:GetCaster():GetAbsOrigin(), check_pos) then
            distance = (10 * i-1)
            break
        end
    end
    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_generic_knockback_lua",
        {
            direction_x = direction.x,
            direction_y = direction.y,
            distance = distance,
            height = 400,
            duration = distance/700,
        }
    )
    self:SetHidden(true)
end