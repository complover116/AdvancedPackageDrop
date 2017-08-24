SWEP.PrintName = "Package Drop Marker"

SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "complover116"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.UseHands = true

SWEP.HoldType = "Grenade"
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = false
SWEP.Weight = 200

SWEP.Primary.Damage = 0
SWEP.Primary.TakeAmmo = 0
SWEP.Primary.ClipSize = 0
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false


SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	self:SetSubMaterial(4, "package_marker")
	self.canFire = true
end

function SWEP:PrimaryAttack()
	if !self.canFire then return end
	self.canFire = false
	self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
	timer.Simple(0.5, function()
	self:SendWeaponAnim(ACT_VM_THROW)
	self:EmitSound("weapons/cbar_miss1.wav")
	if SERVER then
		local marker = ents.Create("ent_packagemarker")
		marker:SetPos(self.Owner:EyePos())
		if ( !IsValid( marker ) ) then return end
		marker:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
		marker:SetAngles( self.Owner:EyeAngles() )
		marker:Spawn()
		local phys = marker:GetPhysicsObject()
		local velocity = self.Owner:GetAimVector()
		velocity = velocity * 1000
		velocity = velocity + ( VectorRand() * 10 ) -- a random element
		phys:ApplyForceCenter( velocity )
		self.Owner.packageMarker = marker
		marker.Owner = self.Owner
	end
	self.Owner:ViewPunch(Angle(2, 2, 0))
	timer.Simple(0.3, function()
	if SERVER then
		self.Owner:StripWeapon("weapon_packagemarker")
	end
	end)
	end)
end