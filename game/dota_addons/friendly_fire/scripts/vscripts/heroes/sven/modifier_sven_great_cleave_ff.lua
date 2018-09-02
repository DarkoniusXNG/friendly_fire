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
		local parent = self:GetParent()
		if parent == event.attacker then
			if parent:PassivesDisabled() then
				return 0
			end
			
			local target = event.target
			local ability = self:GetAbility()
			local cleave_origin = parent:GetAbsOrigin()
			local start_radius = self.cleave_start_radius
			local end_radius = self.cleave_end_radius
			local distance = self.cleave_distance
			local particle_cleave = "particles/custom/sven_ti7_sword_spell_great_cleave.vpcf"
			
			local main_damage
			local damage_percent
			
			if parent:IsIllusion() then
				main_damage = 0
				damage_percent = 0
			else
				main_damage = event.damage
				damage_percent = self.cleave_damage_percent
			end
			
			CustomCleaveAttack(parent, target, ability, main_damage, damage_percent, cleave_origin, start_radius, end_radius, distance, particle_cleave)
			target:EmitSound("Hero_Sven.GreatCleave")
		end
	end
end
