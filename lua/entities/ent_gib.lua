AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName		= "Package"
ENT.Author			= "complover116"
ENT.Contact			= "complover116@gmail.com"
ENT.Purpose			= "Contains useful stuff!"
ENT.Instructions	= ""
if CLIENT then

function ENT:Draw()
	self:DrawModel()
end

end

if SERVER then
function ENT:Initialize()
	self.time = 0
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
	self:SetRenderMode(RENDERMODE_TRANSALPHA )
end
function ENT:Think()
	self.time = self.time + 1
	if self.time > 50 then
		self:Remove()
	end
end
end

