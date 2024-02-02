ability_change_rotate_left = class({})
function ability_change_rotate_left:OnSpellStart()
    if not IsServer() then return end
    if self.next_point == nil then return end
    HubGame:PlayerLetsStep(self:GetCaster(), nil, self.next_point)
    HiddenAbilities({"ability_random_steps", "ability_change_rotate_left", "ability_change_rotate_right", "ability_change_rotate_up", "ability_change_rotate_down"})
    self.next_point = nil
end

ability_change_rotate_right = class({})
function ability_change_rotate_right:OnSpellStart()
    if not IsServer() then return end
    if self.next_point == nil then return end
    HubGame:PlayerLetsStep(self:GetCaster(), nil, self.next_point)
    HiddenAbilities({"ability_random_steps", "ability_change_rotate_left", "ability_change_rotate_right", "ability_change_rotate_up", "ability_change_rotate_down"})
    self.next_point = nil
end

ability_change_rotate_up = class({})
function ability_change_rotate_up:OnSpellStart()
    if not IsServer() then return end
    if self.next_point == nil then return end
    HubGame:PlayerLetsStep(self:GetCaster(), nil, self.next_point)
    HiddenAbilities({"ability_random_steps", "ability_change_rotate_left", "ability_change_rotate_right", "ability_change_rotate_up", "ability_change_rotate_down"})
    self.next_point = nil
end

ability_change_rotate_down = class({})
function ability_change_rotate_down:OnSpellStart()
    if not IsServer() then return end
    if self.next_point == nil then return end
    HubGame:PlayerLetsStep(self:GetCaster(), nil, self.next_point)
    HiddenAbilities({"ability_random_steps", "ability_change_rotate_left", "ability_change_rotate_right", "ability_change_rotate_up", "ability_change_rotate_down"})
    self.next_point = nil
end