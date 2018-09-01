if modifier_tidebringer_ff_cooldown == nil then
	modifier_tidebringer_ff_cooldown = class({})
end

function modifier_tidebringer_ff_cooldown:IsHidden()
  return true
end

function modifier_tidebringer_ff_cooldown:IsPurgable()
  return false
end

function modifier_tidebringer_ff_cooldown:IsDebuff()
  return false
end

function modifier_tidebringer_ff_cooldown:RemoveOnDeath()
  return false
end


function modifier_tidebringer_ff_cooldown:OnRefresh(event)
    if IsServer() then
		local ability = self:GetAbility()
		if ability:IsCooldownReady() then

		  local parent = self:GetParent()
		  -- Add weapon glow
		  parent:AddNewModifier(parent, self:GetAbility(), "modifier_tidebringer_ff_weapon_effect", {})
		  -- Remove cooldown effect
		  parent:RemoveModifierByNameAndCaster("modifier_tidebringer_ff_cooldown", parent)

		--else
		-- Change cooldown to ability's remaining time
		  --self:SetDuration(ability:GetCooldownTimeRemaining(), true)
		end
	end
end

function modifier_tidebringer_ff_cooldown:OnRemoved()
    if IsServer() then
		local parent = self:GetParent()

		-- Add weapon glow
		parent:AddNewModifier(parent, self:GetAbility(), "modifier_tidebringer_ff_weapon_effect", {})

		-- Plays an audio effect (only heard by Kunkka) when going off cooldown.
		EmitSoundOnClient("Hero_Kunkaa.Tidebringer", parent:GetPlayerOwner())
	end
end
