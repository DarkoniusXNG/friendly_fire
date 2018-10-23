if silencer_last_word_ff == nil then
	silencer_last_word_ff = class({})
end

LinkLuaModifier("modifier_custom_last_word_silence_active", "heroes/silencer/modifier_custom_last_word_silence_active.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_custom_last_word_active", "heroes/silencer/modifier_custom_last_word_active.lua", LUA_MODIFIER_MOTION_NONE)

function silencer_last_word_ff:IsStealable()
	return true
end

function silencer_last_word_ff:IsHiddenWhenStolen()
	return false
end

function silencer_last_word_ff:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if IsServer() then
		-- Checking if target has spell block, if target has spell block, there is no need to execute the spell
		if target and not target:TriggerSpellAbsorb(self) then
			-- Sound on the target
			target:EmitSound("Hero_Silencer.LastWord.Cast")

			-- Applying the timer debuff
			local timer_duration = self:GetSpecialValueFor("debuff_duration")
			target:AddNewModifier(caster, self, "modifier_custom_last_word_active", {duration = timer_duration})
		end
	end
end

function silencer_last_word_ff:ProcsMagicStick()
	return true
end
