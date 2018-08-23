if modifier_sven_great_cleave_ff == nil then
	modifier_sven_great_cleave_ff = class({})
end

function modifier_sven_great_cleave_ff:IsHidden()
	return true
end

function modifier_sven_great_cleave_ff:IsPurgable()
	return false
end

function modifier_sven_great_cleave_ff:IsDebuff()
	return false
end

function modifier_sven_great_cleave_ff:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_sven_great_cleave_ff:OnCreated(kv)
	local ability = self:GetAbility()
	self.cleave_damage_percent = ability:GetSpecialValueFor("cleave_percent")
	self.cleave_start_radius = ability:GetSpecialValueFor("start_radius")
	self.cleave_distance = ability:GetSpecialValueFor("distance")
	self.cleave_end_radius = ability:GetSpecialValueFor("end_radius")
end

modifier_sven_great_cleave_ff.OnRefresh = modifier_sven_great_cleave_ff.OnCreated

function modifier_sven_great_cleave_ff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_sven_great_cleave_ff:OnAttackLanded(event)
	if IsServer() then
		local owner = self:GetParent()
		if owner == event.attacker then
			if owner:PassivesDisabled() then
				return 0
			end
			
			local target = event.target
			local ability = self:GetAbility()
			local cleave_origin = owner:GetAbsOrigin()
			local start_radius = self.cleave_start_radius
			local end_radius = self.cleave_end_radius
			local distance = self.cleave_distance
			local particle_cleave = nil
			local particle_hit = nil --"particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf"
			local main_damage
			local damage_percent
			
			if owner:IsIllusion() then
				main_damage = 0
				damage_percent = 0
			else
				main_damage = event.damage
				damage_percent = self.cleave_damage_percent
			end
			
			CustomCleaveAttack(owner, target, ability, main_damage, damage_percent, cleave_origin, start_radius, end_radius, distance, particle_cleave, particle_hit)
			target:EmitSound("Hero_Sven.GreatCleave")
		end
	end
end
