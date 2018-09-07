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

function modifier_storm_bolt_cd_reduction_talent:OnCreated()
	if IsClient() then
		local parent = self:GetParent()
		local talent = self:GetAbility()
		local talent_value = talent:GetSpecialValueFor("value")
		parent.storm_bolt_cd_reduction_talent_value = talent_value
	end
end
