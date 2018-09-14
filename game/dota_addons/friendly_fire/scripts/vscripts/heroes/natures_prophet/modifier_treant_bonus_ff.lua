if modifier_treant_bonus_ff == nil then
	modifier_treant_bonus_ff = class({})
end

function modifier_treant_bonus_ff:IsHidden()
	return true
end

function modifier_treant_bonus_ff:IsPurgable()
	return false
end

function modifier_treant_bonus_ff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
  }

  return funcs
end

function modifier_treant_bonus_ff:OnCreated(keys)
  if IsServer() then
    local parentUnit = self:GetParent()
    -- Get parent unit's base health and damage at time of modifier application
    self.parentMaxHealth = parentUnit:GetBaseMaxHealth()
    self.parentMinDamage = parentUnit:GetBaseDamageMin()
    self.parentMaxDamage = parentUnit:GetBaseDamageMax()
  end
end

function modifier_treant_bonus_ff:GetModifierExtraHealthBonus()
  return self.parentMaxHealth
end

function modifier_treant_bonus_ff:GetModifierBaseAttack_BonusDamage()
  -- Check that min and max damage values have been fetched to prevent errors
  if self.parentMinDamage and self.parentMaxDamage then
    return (self.parentMinDamage + self.parentMaxDamage) / 2
  end
end
