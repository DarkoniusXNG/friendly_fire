if modifier_tidebringer_ff == nil then
	modifier_tidebringer_ff = class({})
end

function modifier_tidebringer_ff:IsHidden()
	return true
end

function modifier_tidebringer_ff:IsPurgable()
	return false
end

function modifier_tidebringer_ff:IsDebuff()
	return false
end

function modifier_tidebringer_ff:RemoveOnDeath()
	return false
end

function modifier_tidebringer_ff:OnCreated(kv)
	local parent = self:GetParent()
	local ability = self:GetAbility()
	-- Add weapon glow effect when the modifier is created
	if IsServer() then
		parent:AddNewModifier(parent, ability, "modifier_tidebringer_ff_weapon_effect", {})
		self:StartIntervalThink(0.2)
	end
end

function modifier_tidebringer_ff:OnRefresh()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	-- Add weapon glow effect only if the ability is off cooldown
	if IsServer() then
		if ability:IsCooldownReady() then
			parent:AddNewModifier(parent, ability, "modifier_tidebringer_ff_weapon_effect", {})
		end
	end
end

function modifier_tidebringer_ff:OnIntervalThink()
	if IsServer() then
		self:ForceRefresh()
	end
end

function modifier_tidebringer_ff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function modifier_tidebringer_ff:GetModifierPreAttack_BonusDamage(keys)
	if IsServer() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local bonus_damage = ability:GetSpecialValueFor("bonus_damage")
		
		if ability:IsCooldownReady() and ability:GetAutoCastState() == true and (not parent:IsSilenced()) then
			return bonus_damage
		end
		-- Bonus damage when manually cast is added during OnAttackLanded event in TidebringerCleave function
		return 0
	else
		return 0
	end
end

function modifier_tidebringer_ff:OnAttack(event)
    local parent = self:GetParent()
	local ability = self:GetAbility()
	
	if event.attacker ~= parent then
		return
	end

	if parent:GetCurrentActiveAbility() ~= ability then
		return
	end
	
	-- Manual cast detected
	self.manual_cast = true
end

function modifier_tidebringer_ff:OnAttackLanded(event)
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local target = event.target
	
	if event.attacker == parent and ability:IsCooldownReady() and (not parent:IsSilenced()) then
		if ability:GetAutoCastState() == true then
			-- The Attack while autocast is on
			self:TidebringerCleave(event)
		else
			-- The Attack while autocast is off
			if self.manual_cast then
				self:TidebringerCleave(event)
			end
		end
	end
end

function modifier_tidebringer_ff:TidebringerCleave(event)
	if IsServer() and event then
		local attacker = event.attacker or self:GetParent()
		local target = event.target
		local ability = self:GetAbility()
		local cleave_origin = attacker:GetAbsOrigin()
		local start_radius = ability:GetSpecialValueFor("start_radius")
		local end_radius = ability:GetSpecialValueFor("end_radius")
		local distance = ability:GetSpecialValueFor("distance")
		local particle_cleave = "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf"
		
		local main_damage
		local damage_percent
		
		if attacker:IsIllusion() then
			main_damage = 0
			damage_percent = 0
		else
			main_damage = event.damage
			damage_percent = ability:GetSpecialValueFor("cleave_percent")
		end
		
		if self.manual_cast then
			-- Add bonus damage if tidebringer is manually cast
			main_damage = main_damage + ability:GetSpecialValueFor("bonus_damage")
			-- Primary target is not damaged with this bonus damage --> needs fix
		end
		
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end
		
		CustomCleaveAttack(attacker, target, ability, main_damage, damage_percent, cleave_origin, start_radius, end_radius, distance, particle_cleave)
		attacker:EmitSound("Hero_Kunkka.Tidebringer.Attack")
		
		ability:UseResources(true, false, true)
		
		-- Remove weapon glow effect
		attacker:RemoveModifierByName("modifier_tidebringer_ff_weapon_effect")
		
		self.manual_cast = nil
	end
end
