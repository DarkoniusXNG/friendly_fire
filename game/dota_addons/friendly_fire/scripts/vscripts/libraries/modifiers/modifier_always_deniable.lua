if modifier_always_deniable == nil then
	modifier_always_deniable = class({})
end

function modifier_always_deniable:IsHidden()
    return true
end

function modifier_always_deniable:IsPurgable()
    return false
end

function modifier_always_deniable:AllowIllusionDuplicate() 
	return false
end

function modifier_always_deniable:CheckState() 
  local state = {
	[MODIFIER_STATE_SPECIALLY_DENIABLE] = true
  }
  return state
end

function modifier_always_deniable:RemoveOnDeath()
    return false
end
