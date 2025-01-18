modifier_flashlight_debuff = class({})
function modifier_flashlight_debuff:IsHidden() return true end
function modifier_flashlight_debuff:IsPurgable() return false end
function modifier_flashlight_debuff:IsPurgeException() return false end

function modifier_flashlight_debuff:GetBonusVisionPercentage() 
    return -100  
end
    
function modifier_flashlight_debuff:GetFixedDayVision()
    return 0
end
    
function modifier_flashlight_debuff:GetFixedNightVision()
    return 0
end

function modifier_flashlight_debuff:GetModifierNoVisionOfAttacker() 
    return 1  
end 

function modifier_flashlight_debuff:DeclareFunctions()
    return
    {
        MODIFIER_PROPERTY_FIXED_DAY_VISION,
        MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
        MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
        MODIFIER_PROPERTY_DONT_GIVE_VISION_OF_ATTACKER,
    }
end