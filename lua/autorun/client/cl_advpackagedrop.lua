AddCSLuaFile()

function APD_requestPackage(packageinfo)

	APD_packageAssemblyData = {itemNum=#packageinfo.contents, items={}, startTime = CurTime()}
	for k, item in pairs(packageinfo.contents) do
			if ADVPACK_ITEMLIST[item] == nil then
				print("Error: item "..item.." not defined in the package item list!")
				return
			end
			APD_packageAssemblyData.items[#APD_packageAssemblyData.items+1] = {totalTime=ADVPACK_ITEMLIST[item].assembleTime, itemName=ADVPACK_ITEMLIST[item].name}
	end
	net.Start("package_request")
	net.WriteTable(packageinfo)
	net.SendToServer()
	
	print("Package request sent")
end

concommand.Add("apd_requestrandom", function(ply, cmd, args)
	local packageinfo = {contents={}}
	local time = 0
	while time < 12 do
		packageinfo.contents[#packageinfo.contents+1] = ADVPACK_ITEMNAMELIST[math.random(1, #ADVPACK_ITEMNAMELIST)]
		time = time + ADVPACK_ITEMLIST[packageinfo.contents[#packageinfo.contents]].assembleTime
	end
	APD_requestPackage(packageinfo)
end)

hook.Add( "HUDPaint", "APD_HUD", function()
	if LocalPlayer():GetNetworkedInt("packageStat") == ADVPACK_STATUS_ASSEMBLING then
		if APD_packageAssemblyData == nil then
			draw.WordBox( 5, 0, 0, "Package assembling...", "Trebuchet24", Color(0,0,200), Color(255,255,255) )
		else
			local timeLeft = 0
			local flag = false
			local timePassed = CurTime() - APD_packageAssemblyData.startTime
			for item, itemData in ipairs(APD_packageAssemblyData.items) do
				if itemData.totalTime > timePassed then
					itemData.timeLeft = itemData.totalTime - timePassed
					timePassed = 0
					timeLeft = timeLeft + itemData.timeLeft
				else
					itemData.timeLeft = 0
					timePassed = timePassed - itemData.totalTime
				end
				local text = itemData.itemName
				surface.SetDrawColor( 0, 0, 255, 255 )
				surface.DrawRect( 0, 24*item+10, #text*7, 24) 
				surface.SetDrawColor( 0, 255, 0, 255 )
				surface.DrawRect( 0, 24*item+10, #text*7*(itemData.totalTime - itemData.timeLeft)/itemData.totalTime, 24)
				draw.SimpleText(text, "Trebuchet18", 0, 24*item+10, Color(255,255,255))
			end
			draw.WordBox( 5, 0, 0, "Package assembling, "..math.Round(timeLeft).."s remaining", "Trebuchet24", Color(0,0,200), Color(255,255,255) )
		end
	end
	if LocalPlayer():GetNetworkedInt("packageStat") == ADVPACK_STATUS_IDLE then
		draw.WordBox( 5, 0, 0, "Package drop ready", "Trebuchet24", Color(0,0,200), Color(255,255,255) ) 
	end
	if LocalPlayer():GetNetworkedInt("packageStat") == ADVPACK_STATUS_LOCKING then
		draw.WordBox( 5, 0, 0, "Waiting for package marker...", "Trebuchet24", Color(0,0,200), Color(255,255,255) ) 
	end
	if LocalPlayer():GetNetworkedInt("packageStat") == ADVPACK_STATUS_SHIPPING then
		draw.WordBox( 5, 0, 0, "Package is being shipped...", "Trebuchet24", Color(0,0,200), Color(255,255,255) ) 
	end
end )