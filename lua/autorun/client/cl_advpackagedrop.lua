APD = {}
include("APD/GUI.lua")
include("APD/HUDAnim.lua")


function APD_requestPackage(packageinfo)
	net.Start("package_request")
	net.WriteTable(packageinfo)
	net.SendToServer()
	
	print("Package request sent")
end

concommand.Add("apd_requesttest", function(ply, cmd, args)
	local packageinfo = {contents={item_healthvial=3, item_battery=1}}
	APD_requestPackage(packageinfo)
end)

concommand.Add("apd_showgui", function(ply, cmd, args)
	APD.ShowGUI()
end)
