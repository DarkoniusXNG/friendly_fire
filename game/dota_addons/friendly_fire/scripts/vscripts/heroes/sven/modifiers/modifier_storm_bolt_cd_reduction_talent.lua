if modifier_storm_bolt_cd_reduction_talent == nil then
	modifier_storm_bolt_cd_reduction_talent = class({})
end

function modifier_storm_bolt_cd_reduction_talent:IsHidden()
    return true
end

function modifier_storm_bolt_cd_reduction_talent:IsPurgable()
    return false
end

function modifier_storm_bolt_cd_reduction_talent:AllowIllusionDuplicate() 
	return false
end

function modifier_storm_bolt_cd_reduction_talent:RemoveOnDeath()
    return false
end

function modifier_storm_bolt_cd_reduction_talent:OnCreated(event)
	if IsServer() then
		local parent = self:GetParent()
		local talent = parent:FindAbilityByName("special_bonus_unique_sven")
		if talent then
			parent.storm_bolt_cd_reduction = talent:GetSpecialValueFor("value")
		end
	end
end
