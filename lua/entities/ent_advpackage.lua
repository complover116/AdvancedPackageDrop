AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName		= "Package"
ENT.Author			= "complover116"
ENT.Contact			= "complover116@gmail.com"
ENT.Purpose			= "Contains useful stuff!"
ENT.Instructions	= ""
ENT.Spawnable = true
ENT.AdminOnly = true

if CLIENT then

function ENT:Draw()
	self:DrawModel()
end

end

if SERVER then
function ENT:Initialize()
	self:SetModel("models/props_junk/wood_crate001a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	if self.contents == nil then
		self.contents = {"item_battery", "item_healthvial"}
	end
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() phys:SetMass(200) phys:EnableDrag(false) end
	self:SetUseType( SIMPLE_USE )
end
function ENT:Use(activator, caller, useType, value)
	timer.Simple(0, function()
	local effectdata = EffectData()
	effectdata:SetStart(Vector(255, 255, 255))
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "package_open", effectdata )
	for i = 1, 9 do
		if i == 8 then i = i + 1 end
		local gib = ents.Create("ent_gib")
		local pos = Vector(math.random(-10, 10), math.random(-10, 10), math.random(0, 4))
		gib:SetPos(self:GetPos()+pos)
		gib:SetModel("models/props_junk/wood_crate001a_chunk0"..i..".mdl")
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity(pos*100)
	end
	local corner1, corner2 = self:GetCollisionBounds()
	for k, v in pairs(self.contents) do
		item = ents.Create(v)
		item:SetPos(self:GetPos() + corner1 + (corner2-corner1)*math.random())
		item:Spawn()
	end
	self:Remove()
	end)
end
function ENT:PhysicsCollide( data, phys )
	if data.Speed > 100 && data.Speed < 1000 then
		self:EmitSound("complover116/AdvPackageDrop/package_impactlow.wav", data.Speed/200 + 50, math.random(70, 110))
	end
	if data.Speed > 1000 then
		local effectdata = EffectData()
		effectdata:SetStart(Vector(255, 255, 255))
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "package_impact", effectdata )
		self:EmitSound("complover116/AdvPackageDrop/package_impacthigh.wav", 90, math.random(70, 110))
	end
end
end

