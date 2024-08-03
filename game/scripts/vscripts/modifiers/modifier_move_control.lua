modifier_move_control = class({})
function modifier_move_control:IsHidden() return true end
function modifier_move_control:IsPurgable() return false end
function modifier_move_control:IsPurgeException() return false end
function modifier_move_control:RemoveOnDeath() return false end
function modifier_move_control:CheckState()
    return
    {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_move_control:OnCreated()
	self.parent = self:GetParent()
	self.run = false
	self.vMovePoint = nil
    if not IsServer() then return end
	self:StartIntervalThink(0.03)
end

function modifier_move_control:OnIntervalThink()
    if self.parent:HasModifier("modifier_pummel_party_hub") then
        self.parent:FadeGesture(ACT_DOTA_IDLE)
		self.parent:FadeGesture(ACT_DOTA_RUN)
        return 
    end
    if self.parent:HasModifier("modifier_pummel_party_pre_mini_game") then
        self.parent:FadeGesture(ACT_DOTA_IDLE)
		self.parent:FadeGesture(ACT_DOTA_RUN)
        return 
    end
	if not self.parent:IsAlive() then
		self.parent:FadeGesture(ACT_DOTA_IDLE)
		self.parent:FadeGesture(ACT_DOTA_RUN)
	end
	local vDirection = nil
	if not self.parent:IsStunned() and not self.parent:IsCommandRestricted() and self.parent:IsAlive() then
		local vDir = Vector(0,0,0)
		if self.parent.up then
			if GridNav:CanFindPath(self.parent:GetOrigin(), self.parent:GetOrigin() + Vector(0,1,0) * 50) 
				or self.parent:HasFlyMovementCapability() then
				vDir = vDir + Vector(0,1,0)
			end
		end
		if self.parent.down then
			if GridNav:CanFindPath(self.parent:GetOrigin(), self.parent:GetOrigin() + Vector(0,-1,0) * 50) 
				or self.parent:HasFlyMovementCapability() then
				vDir = vDir + Vector(0,-1,0)
			end
		end
		if self.parent.left then
			if GridNav:CanFindPath(self.parent:GetOrigin(), self.parent:GetOrigin() + Vector(-1,0,0) * 50)
				or self.parent:HasFlyMovementCapability() then
				vDir = vDir + Vector(-1,0,0)
			end
		end
		if self.parent.right then
			if GridNav:CanFindPath(self.parent:GetOrigin(), self.parent:GetOrigin() + Vector(1,0,0) * 50)
				or self.parent:HasFlyMovementCapability() then
				vDir = vDir + Vector(1,0,0)
			end
		end
		if vDir ~= Vector(0,0,0) then
			self.vMovePoint = self.parent:GetOrigin() + vDir * 50
		end
		if self.vMovePoint ~= nil then
			if not GridNav:CanFindPath(self.parent:GetOrigin(), self.vMovePoint) and not self.parent:HasFlyMovementCapability() then
				self.vMovePoint = nil
			end
		end
		if self.parent.toDirect ~= nil then
			local vPosition = Vector(self.parent.toDirect["0"],self.parent.toDirect["1"], self.parent:GetOrigin().z)
			vDirection = (vPosition - self.parent:GetOrigin()):Normalized()
			self.parent:SetForwardVector(vDirection)
		end
	end
	if self.vMovePoint ~= nil then
		vDirection = (self.vMovePoint - self.parent:GetOrigin()):Normalized()
		local vPosition = self.parent:GetOrigin() + vDirection * (self.parent:GetMoveSpeedModifier(self.parent:GetBaseMoveSpeed(), false)*(1/30))
		FindClearSpaceForUnit(self.parent, vPosition, false)
        self.parent:SetForwardVector(vDirection)
		self.parent:InterruptChannel()
		if (self.vMovePoint - self.parent:GetOrigin()):Length2D() < 25 then
			self.vMovePoint = nil
		end
		
		if not self.run and not self.parent:HasOverrideAnimation() then
			self.run = true
			self.parent:FadeGesture(ACT_DOTA_IDLE)
			self.parent:StartGestureFadeWithSequenceSettings(ACT_DOTA_RUN)
		end
	else
		if self.run and not self.parent:HasOverrideAnimation() then
			self.run = false
			self.parent:FadeGesture(ACT_DOTA_RUN)
			self.parent:StartGestureFadeWithSequenceSettings(ACT_DOTA_IDLE)
		end
	end
	if self.parent:HasOverrideAnimation() then
		self.parent:FadeGesture(ACT_DOTA_RUN)
		self.parent:FadeGesture(ACT_DOTA_IDLE)
		self.run = false
	end
end