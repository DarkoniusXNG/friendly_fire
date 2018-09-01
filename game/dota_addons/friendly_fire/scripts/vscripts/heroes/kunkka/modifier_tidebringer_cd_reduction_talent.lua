if modifier_tidebringer_cd_reduction_talent == nil then
	modifier_tidebringer_cd_reduction_talent = class({})
end

function modifier_tidebringer_cd_reduction_talent:IsHidden()
    return true
end

function modifier_tidebringer_cd_reduction_talent:IsPurgable()
    return false
end

function modifier_tidebringer_cd_reduction_talent:AllowIllusionDuplicate()
	return false
end

function modifier_tidebringer_cd_reduction_talent:RemoveOnDeath()
    return false
end
