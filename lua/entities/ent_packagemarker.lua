AddCSLuaFile()

ENT.Type = "anim"

if CLIENT then

function ENT:Draw()
	self:DrawModel()
end

end

if SERVER then
function ENT:Initialize()
	self.time = 0
	self:SetMaterial(4, "weapons/package_marker")
	self.clientResponded = false
	self.smokeStarted = false
	self.isReady = false
	self:SetNetworkedBool("failed", false)
	self:SetNetworkedBool("locked", false)
	self:SetModel("models/weapons/w_grenade.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
	self:SetRenderMode(RENDERMODE_TRANSALPHA )
end
end
function ENT:Think()
	if SERVER then
	self.time = self.time + 1
	if self.time == 20 then
		self:SetNetworkedVector("lastValidPos", util.FindSky(self:GetPos(), self))
		if self:GetNetworkedVector("lastValidPos") != Vector(0,0,0) then
			self:SetNetworkedBool("ready", true)
		else
			self:SetNetworkedBool("failed", true)
			self.Owner:Give("weapon_packagemarker")
			self.Owner:SelectWeapon("weapon_packagemarker")
		end
	end
	if self.smokeStarted then
		local effectdata = EffectData()
		effectdata:SetStart(Vector(0, 255, 0))
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "packagemarker_smoke", effectdata )
	end
	if self:GetNetworkedBool("locked") && !self.smokeStarted then
		self.smokeStarted = true
		self:EmitSound("weapons/smokegrenade/sg_explode.wav")
	end
	if self.time > 100 && !self:GetNetworkedBool("ready") then
		self:Remove()
	end
	else //if CLIENT
	if self:GetNetworkedBool("failed") && !self.clientResponded then
		self.clientResponded = true
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.pos = self:GetPos()
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.brightness = 2
			dlight.Decay = 1024
			dlight.Size = 512
			dlight.DieTime = CurTime() + 0.5
		end
		self:EmitSound("buttons/button10.wav")
		notification.AddLegacy( "The sky above the package marker must be clear!", NOTIFY_ERROR, 5 )
	end
	if self:GetNetworkedBool("locked") && !self.clientResponded then
		self.clientResponded = true
		notification.AddProgress( 123, "Position marked, shipping..." ) 
		timer.Simple( 5, function()
			notification.Kill( 123 )
		end)
	end
	if self:GetNetworkedBool("ready") && !self:GetNetworkedBool("locked") then
		if self.lastBlipTime == nil || CurTime() > self.lastBlipTime + 1 then
			self:EmitSound("buttons/blip1.wav")
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.pos = self:GetPos()
				dlight.r = 0
				dlight.g = 255
				dlight.b = 0
				dlight.brightness = 2
				dlight.Decay = 1024
				dlight.Size = 512
				dlight.DieTime = CurTime() + 0.5
			end
			self.lastBlipTime = CurTime()
		end
	end
	end
	self:NextThink(CurTime()+0.1)
	return true
end


