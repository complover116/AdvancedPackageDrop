AddCSLuaFile("APD/GUI.lua")
AddCSLuaFile("APD/HUDAnim.lua")

APD = {}
include("APD/worldToSkybox.lua")

util.AddNetworkString("package_request")
util.AddNetworkString("package_animate_hud")
resource.AddFile( "sound/complover116/AdvPackageDrop/package_open.wav" )
resource.AddFile( "sound/complover116/AdvPackageDrop/package_impacthigh.wav" )
resource.AddFile( "sound/complover116/AdvPackageDrop/package_impactlow.wav" )



net.Receive( "package_request", function(length, ply)
	if ply:GetNetworkedInt("packageStat") == nil || ply:GetNetworkedInt("packageStat") == ADVPACK_STATUS_IDLE then
		ply.packageInfo = net.ReadTable()
		ply.packageTime = CurTime()
		ply.packageShipDelay = 15
		ply.packageAssembleDelay = 0
		for item, amount in pairs(ply.packageInfo.contents) do
			if ADVPACK_ITEMLIST[item] == nil then
				print("Error: item "..item.." not defined in the package item list!")
				return
			end
			ply.packageAssembleDelay = ply.packageAssembleDelay + ADVPACK_ITEMLIST[item].assembleTime*amount
		end
		ply:SetNetworkedInt("packageStat", ADVPACK_STATUS_ASSEMBLING)
		print("Granting package request to "..ply:GetName())
		ply:Give("weapon_packagemarker")
		ply:SelectWeapon("weapon_packagemarker")
		net.Start("package_animate_hud")
		local CSPackageAnimData = {shippingTime = 15, contents=ply.packageInfo.contents}
		net.WriteTable(CSPackageAnimData)
		net.Send(ply)
	end
end) 


concommand.Add("apd_cancel", function(ply, cmd, args)
	ply:SetNetworkedInt("packageStat", ADVPACK_STATUS_IDLE)
end)
concommand.Add("apd_strip", function(ply, cmd, args)
	ply:StripWeapons()
	ply:StripAmmo()
end)
hook.Add("Think", "ADVPACKTHINK", function()
	for k, ply in pairs(player.GetAll()) do
		if ply:GetNetworkedInt("packageStat") == ADVPACK_STATUS_LOCKING then
			if ply.packageMarker != nil && ply.packageMarker:IsValid() && ply.packageMarker:GetNetworkedBool("ready") then
				ply.packageSpawnPos = util.FindSky(ply.packageMarker:GetPos(), ply.packageMarker)
				if ply.packageSpawnPos == nil then
					print("Could not find the sky for "..ply:GetName().."'s package!")
					ply.packageSpawnPos = ply.packageMarker:GetNetworkedVector("lastValidPos")
				end
				ply.packageMarker:SetNetworkedBool("locked", true)
				ply:SetNetworkedInt("packageStat", ADVPACK_STATUS_SHIPPING)
				ply.packageTime = CurTime()
				sound.Play("npc/env_headcrabcanister/launch.wav", ply.packageSpawnPos, 0, 100, 1)
				print(ply:GetName().."'s package locked, now shipping...")
				print(ply.packageSpawnPos)
			end
		end
		if ply:GetNetworkedInt("packageStat") == ADVPACK_STATUS_ASSEMBLING then
			if CurTime() > ply.packageTime + ply.packageAssembleDelay then
				ply:SetNetworkedInt("packageStat", ADVPACK_STATUS_LOCKING)
				ply.packageTime = CurTime()
				print(ply:GetName().."'s package assembled, now locking...")
			end
		end
		if ply:GetNetworkedInt("packageStat") == ADVPACK_STATUS_SHIPPING then
			if CurTime() > ply.packageTime + ply.packageShipDelay then
				print(ply:GetName().."'s package sent, now idle")
				local packageMarkerToRemove = ply.packageMarker
				if ply.packageMarker != nil && ply.packageMarker:IsValid() then timer.Simple(5, function() SafeRemoveEntity(packageMarkerToRemove) end) end
				local pack = ents.Create("ent_advpackage")
				pack:SetPos(ply.packageSpawnPos)
				pack.contents = ply.packageInfo.contents
				pack:Spawn()
				pack:Activate()
				
				ply:SetNetworkedInt("packageStat", ADVPACK_STATUS_IDLE)
			end
		end
	end
end)