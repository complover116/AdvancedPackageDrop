function APD.ShowGUI()
	local packageInfo = {contents={}}
	local frame = vgui.Create("DFrame")
	frame:SetSize(200, 100)
	frame:SetTitle("APD Request")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()
end