AddCSLuaFile()

function EFFECT:Init( data )
	local vOffset = data:GetOrigin()
	local Color = data:GetStart()

	local NumParticles = 10

	local emitter = ParticleEmitter( vOffset, true )

	for i = 0, NumParticles do

		local Pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )

		local particle = emitter:Add( "particle/particle_smokegrenade", vOffset + Pos * 20 )
		if ( particle ) then

			particle:SetVelocity( Pos * 150 )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 8 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			local Size = math.Rand( 25, 50 )
			particle:SetStartSize( Size )
			particle:SetEndSize( 0 )

			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -2, 2 ) )

			particle:SetAirResistance( 100 )
			particle:SetGravity( Vector( 0, 0, 0 ) )

			local RandDarkness = math.Rand( 0.8, 1.0 )
			particle:SetColor( Color.r * RandDarkness, Color.g * RandDarkness, Color.b * RandDarkness)
			particle:SetNextThink( CurTime()+0.1 )
			particle:SetThinkFunction(function(self)
				self:SetAngles((LocalPlayer():GetPos()-vOffset):Angle())
				self:SetNextThink(CurTime()+0.1)
			end)
			particle:SetAngles((LocalPlayer():GetPos()-vOffset):Angle())

			particle:SetLighting( true )

		end
		
	end

	emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end