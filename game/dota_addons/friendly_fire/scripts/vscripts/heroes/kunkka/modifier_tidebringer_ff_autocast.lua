if modifier_tidebringer_ff_autocast == nil then
	modifier_tidebringer_ff_autocast = class({})
end

function modifier_tidebringer_ff_autocast:IsHidden()
	return true
end

function modifier_tidebringer_ff_autocast:IsPurgable()
	return false
end

function modifier_tidebringer_ff_autocast:IsDebuff()
	return false
end

function modifier_tidebringer_ff_autocast:RemoveOnDeath()
	return false
end

function modifier_tidebringer_ff_autocast:OnCreated()
	if IsServer() then
		local parent = self:GetParent()
		-- Add weapon glow
		parent:AddNewModifier(parent, self:GetAbility(), "modifier_tidebringer_ff_weapon_effect", {})
		-- Attack procs
		if not self.procRecords then
			self.procRecords = {}
		end
	end
end

function modifier_tidebringer_ff_autocast:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_tidebringer_ff_autocast:GetModifierPreAttack_BonusDamage(event)
	if IsServer() then
		-- Toggled on
		local ability = self:GetAbility()
		if ability:GetAutoCastState() and ability:IsCooldownReady() then
			return ability:GetSpecialValueFor("damage_bonus")
		end
	end
	return 0
end

function modifier_tidebringer_ff_autocast:OnAttack(event)
    local parent = self:GetParent()

    -- process_procs == true in OnAttack means this is an attack that attack modifiers should not apply to
    if event.attacker ~= parent or event.process_procs then
		return
    end

    local ability = self:GetAbility()
    local target = event.target
	if IsServer() then
		local can_be_autocast
		if target.GetUnitName and ability:GetAutoCastState() and (not parent:IsSilenced()) and ability:IsCooldownReady() and ability:CastFilterResultTarget(target) == UF_SUCCESS then
			can_be_autocast = true
		else 
			can_be_autocast = false
		end
		
		if parent:GetCurrentActiveAbility() ~= ability and not can_be_autocast then
			return
		end

		ability:CastAbility()
		-- Enable proc for this attack record number
		self.procRecords[event.record] = true
	end
end

function modifier_tidebringer_ff_autocast:OnAttackFail(event)
    if event.attacker == self:GetParent() and self.procRecords[event.record] then
		self.procRecords[event.record] = nil
    end
end

function modifier_tidebringer_ff_autocast:OnAttackLanded(event)
    if IsServer() then
		-- Only attacks FROM parent
		-- process_procs == true in OnAttack means this is an attack that attack modifiers should not apply to
		local parent = self:GetParent()
		if event.attacker ~= parent or not self.procRecords[event.record] or not event.process_procs then
			return
		end
		self.procRecords[event.record] = nil

		local ability = self:GetAbility()

		local start_radius = ability:GetSpecialValueFor("cleave_starting_width")
		local end_radius = ability:GetSpecialValueFor("cleave_ending_width")
		local distance = ability:GetSpecialValueFor("cleave_distance")
		
		-- local hitUnits = ability:PerformCleaveOnAttack(
		-- event,
		-- cleaveInfo,
		-- ability:GetTalentSpecialValueFor("cleave_damage") / 100.0,
		-- "Hero_Kunkka.Tidebringer.Attack",
		-- "Hero_Kunkka.TidebringerDamage",
		-- "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf"
		-- )

		-- Force cooldown
		-- Including cooldown reduction which is why we do not use StartCooldown()
		ability:UseResources(true, false, true)
		-- Add cooldown timer
		parent:AddNewModifier(parent, ability, "modifier_tidebringer_ff_cooldown", {
		duration = ability:GetCooldownTimeRemaining()
		})
		-- Remove weapon glow effect
		parent:RemoveModifierByName("modifier_tidebringer_ff_weapon_effect")
	end
end