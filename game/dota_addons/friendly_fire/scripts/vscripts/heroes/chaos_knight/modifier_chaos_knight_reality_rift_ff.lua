if modifier_chaos_knight_reality_rift_ff == nil then
	modifier_chaos_knight_reality_rift_ff = class({})
end

function modifier_chaos_knight_reality_rift_ff:IsHidden()
	return false
end

function modifier_chaos_knight_reality_rift_ff:IsPurgable()
	return true
end

function modifier_chaos_knight_reality_rift_ff:IsDebuff()
	return true
end

function modifier_chaos_knight_reality_rift_ff:OnCreated()
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local armor_reduction = ability:GetSpecialValueFor("armor_reduction")
	
	if IsServer() then
		-- Talent that increases armor reduction
		local talent = caster:FindAbilityByName("special_bonus_unique_chaos_knight_2")
		if talent then
			if talent:GetLevel() ~= 0 then
				local bonus_reduction = talent:GetSpecialValueFor("value")
				armor_reduction = armor_reduction - math.abs(bonus_reduction)
			end
		end
	else
		if caster:HasModifier("modifier_reality_rift_armor_reduction_talent") then
			armor_reduction = armor_reduction - caster.reality_rift_armor_reduction_talent_value
		end
	end
	
	self.armor_reduction = armor_reduction
end

modifier_chaos_knight_reality_rift_ff.OnRefresh = modifier_chaos_knight_reality_rift_ff.OnCreated

function modifier_chaos_knight_reality_rift_ff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_chaos_knight_reality_rift_ff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end

function modifier_chaos_knight_reality_rift_ff:GetEffectName()
	return "particles/custom/chaos_knight_reality_rift_debuff.vpcf"
	-- "particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift_buff.vpcf"
end

function modifier_chaos_knight_reality_rift_ff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
