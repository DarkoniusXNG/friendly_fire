if chaos_knight_reality_rift_ff == nil then
	chaos_knight_reality_rift_ff = class({})
end

LinkLuaModifier("modifier_chaos_knight_reality_rift_ff", "heroes/chaos_knight/modifier_chaos_knight_reality_rift_ff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_reality_rift_armor_reduction_talent", "heroes/chaos_knight/modifier_reality_rift_armor_reduction_talent.lua", LUA_MODIFIER_MOTION_NONE)

function chaos_knight_reality_rift_ff:IsStealable()
	return true
end

function chaos_knight_reality_rift_ff:IsHiddenWhenStolen()
	return false
end

function chaos_knight_reality_rift_ff:CastFilterResultTarget(target)
	if IsServer() then
		local caster = self:GetCaster()
		
		if target ~= nil and target:IsMagicImmune() then
			-- Talent that allows Reality Rift to target Spell Immune units
			local talent = caster:FindAbilityByName("special_bonus_unique_chaos_knight")
			if talent then
				if talent:GetLevel() ~= 0 then
					return UF_SUCCESS
				end
			end
			
			return UF_FAIL_MAGIC_IMMUNE_ENEMY
		end

		local allowed = UnitFilter(target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), caster:GetTeamNumber())
		return allowed
	end

	return UF_SUCCESS
end

function chaos_knight_reality_rift_ff:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	
	-- Calculate direction
	local direction = (target_location - caster_location):Normalized()
	direction.z = 0
	
	-- Calculate distance
	local distance = (target_location - caster_location):Length2D()
	
	-- Calculate the end position
	local min_range = self:GetSpecialValueFor("min_range")
	local max_range = self:GetSpecialValueFor("max_range")
	self.end_position = caster_location + direction*distance*RandomFloat(min_range, max_range)
	
	-- Sound and cast animation on the caster
	EmitSoundOn("Hero_ChaosKnight.RealityRift", caster)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	
	self.FX = {}
	local oRiftFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(oRiftFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_location, true)
	ParticleManager:SetParticleControlEnt(oRiftFX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControl(oRiftFX, 2, self.end_position)
	ParticleManager:SetParticleControlOrientation(oRiftFX, 2, direction, Vector(0,1,0), Vector(1,0,0))
	table.insert(self.FX, oRiftFX)
	
	local search_radius = self:GetSpecialValueFor("illusion_search_radius")
	self.illusions = FindUnitsInRadius(caster:GetTeamNumber(), caster_location, nil, search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
	
	for _, illusion in ipairs(self.illusions) do
		if caster ~= illusion and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
			illusion:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
			local iRiftFX = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControlEnt(iRiftFX, 0, illusion, PATTACH_POINT_FOLLOW, "attach_hitloc", illusion:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(iRiftFX, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
			ParticleManager:SetParticleControl(iRiftFX, 2, self.end_position)
			ParticleManager:SetParticleControlOrientation(iRiftFX, 2, direction, Vector(0,1,0), Vector(1,0,0))
			table.insert(self.FX, iRiftFX)
		end
	end
	return true
end

function chaos_knight_reality_rift_ff:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	for _, fx in ipairs(self.FX) do
		ParticleManager:DestroyParticle(fx, false)
		ParticleManager:ReleaseParticleIndex(fx)
	end
	for _, illusion in ipairs(self.illusions) do
		if caster ~= illusion and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
			illusion:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
		end
	end
	StopSoundOn("Hero_ChaosKnight.RealityRift", caster) -- Sound doesn't stop in normal dota
end

function chaos_knight_reality_rift_ff:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		
		for _, fx in ipairs(self.FX) do
			ParticleManager:ReleaseParticleIndex(fx)
		end
		
		local duration = self:GetSpecialValueFor("reduction_duration")
		if target ~= nil and (not target:TriggerSpellAbsorb(self)) then
			
			-- Sound on the target
			EmitSoundOn("Hero_ChaosKnight.RealityRift.Target", target)
			
			-- Teleport
			FindClearSpaceForUnit(caster, self.end_position, true)
			FindClearSpaceForUnit(target, self.end_position, true)
			
			-- Facing of the caster and the target - do not use npc:SetForwardVector() !
			caster:FaceTowards(target:GetAbsOrigin()) 	-- FaceTowards exists only on Server
			target:FaceTowards(caster:GetAbsOrigin())	-- FaceTowards exists only on Server
			
			target:AddNewModifier(caster, self, "modifier_chaos_knight_reality_rift_ff", {duration = duration})
			
			caster:MoveToTargetToAttack(target)			-- MoveToTargetToAttack exists only on Server
			
			for _, illusion in ipairs(self.illusions) do
				if caster ~= illusion and illusion:IsIllusion() and illusion:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
					FindClearSpaceForUnit(illusion, self.end_position, true)
					illusion:FaceTowards(target:GetAbsOrigin())
					illusion:MoveToTargetToAttack(target)
				end
			end
		end
	end
end

function chaos_knight_reality_rift_ff:ProcsMagicStick()
	return true
end
