function Glimpse(keys)
    local caster = keys.caster
    local ability = keys.ability
	local target = keys.target
	local particle = keys.particle_glimpse
    
	local ability_level = ability:GetLevel() - 1
	
	local current_time = GameRules:GetGameTime()
    local backtrack_time = ability:GetLevelSpecialValueFor("backtrack_time", ability_level)
	
	-- Check for Linken's Sphere
	if target:GetTeam() ~= caster:GetTeam() then
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end
	
	-- if target is an illusion, kill instantly and do nothing else.
	if target:IsIllusion() then
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.ability = ability
		damage_table.damage = 99999
		ApplyDamage(damage_table)
		return nil
	end
	    
    local target_pos = target:GetAbsOrigin()
	
	local past_position
	if not target.positions or not target.positions[math.floor(current_time-backtrack_time)] then 
    	return nil
	else
		past_position = target.positions[math.floor(current_time-backtrack_time)]
	end
    
	local direction = target_pos - past_position
	local distance = direction:Length2D()
	direction.z = 0.0
	direction = direction:Normalized()
    
    local projectile_speed = 600
	local duration = math.max(0.05, math.min(1.8, distance / projectile_speed))
	local actual_speed = direction*(distance / duration)
			
	local projectile =
	{
		Ability = ability,
		EffectName = particle,
		vSpawnOrigin = target_pos, 
		fDistance = distance,
		Source = caster,                				
		vVelocity = actual_speed,
		fStartRadius = 0,
		fEndRadius = 0,				
		bProvidesVision = true,
		iVisionRadius = 300,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}			  

	ProjectileManager:CreateLinearProjectile(projectile)                      

	local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_travel.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(nFXIndex, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true)
	ParticleManager:SetParticleControl(nFXIndex, 1, past_position)
	ParticleManager:SetParticleControl(nFXIndex, 2, Vector(duration, duration, duration))
	
	local nFXIndex2 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_targetend.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(nFXIndex2, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true)
	ParticleManager:SetParticleControl(nFXIndex2, 1, past_position)
	ParticleManager:SetParticleControl(nFXIndex2, 2, Vector(duration, duration, duration))
	
	local nFXIndex3 = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_glimpse_targetstart.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(nFXIndex3, 0, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true)
	ParticleManager:SetParticleControl(nFXIndex3, 2, Vector(duration, duration, duration))
	
	target:EmitSound("Hero_Disruptor.Glimpse.Target")
	Timers:CreateTimer(duration + FrameTime(), function()
		target:StopSound("Hero_Disruptor.Glimpse.Target")
		if not target:IsMagicImmune() and not target:IsInvulnerable() then
			FindClearSpaceForUnit(target, past_position, true)
			target:EmitSound("Hero_Disruptor.Glimpse.End")
			target:Interrupt()
		end
	end)
end