if modifier_acid_spray_ff_debuff == nil then
	modifier_acid_spray_ff_debuff = class({})
end

function modifier_acid_spray_ff_debuff:IsHidden()
	return false
end

function modifier_acid_spray_ff_debuff:IsDebuff()
	return true
end

function modifier_acid_spray_ff_debuff:IsPurgable()
	return false
end

function modifier_acid_spray_ff_debuff:OnCreated(kv)
	local ability = self:GetAbility()
	
	self.armor_reduction = ability:GetSpecialValueFor("armor_reduction")
	self.damage = ability:GetSpecialValueFor("damage")
	local tick_rate = ability:GetSpecialValueFor("tick_rate")
	
	if IsServer() then
		local parent = self:GetParent()
		
		-- Sound on unit that is damaged
		parent:EmitSound("Hero_Alchemist.AcidSpray.Damage")
		
		local damage_table = {}
		damage_table.victim = parent
		damage_table.attacker = ability:GetCaster()
		damage_table.damage = self.damage
		damage_table.damage_type = ability:GetAbilityDamageType()
		damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
		
		ApplyDamage(damage_table)
		
		self:StartIntervalThink(tick_rate)
	end
end

modifier_acid_spray_ff_debuff.OnRefresh = modifier_acid_spray_ff_debuff.OnCreated

function modifier_acid_spray_ff_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_acid_spray_ff_debuff:GetModifierPhysicalArmorBonus(params)
	return self.armor_reduction
end

function modifier_acid_spray_ff_debuff:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		
		-- Sound on unit that is damaged
		parent:EmitSound("Hero_Alchemist.AcidSpray.Damage")
		
		local damage_table = {}
		damage_table.victim = parent
		damage_table.attacker = ability:GetCaster()
		damage_table.damage = self.damage
		damage_table.damage_type = ability:GetAbilityDamageType()
		damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
		
		ApplyDamage(damage_table)
	end
end
