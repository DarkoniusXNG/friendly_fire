if modifier_sven_storm_bolt_ff == nil then
	modifier_sven_storm_bolt_ff = class({})
end

function modifier_sven_storm_bolt_ff:IsDebuff()
	return true
end

function modifier_sven_storm_bolt_ff:IsStunDebuff()
	return true
end

function modifier_sven_storm_bolt_ff:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_sven_storm_bolt_ff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sven_storm_bolt_ff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_sven_storm_bolt_ff:GetOverrideAnimation(params)
	return ACT_DOTA_DISABLED
end

function modifier_sven_storm_bolt_ff:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
