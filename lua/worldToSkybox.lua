function util.FindSky(pos, ent)
	local try = 0
	local traceData = {}
	traceData.filter = ent
	while try<100 do
		traceData.start = pos+Vector(0,0,500)*try
		traceData.endpos = pos+Vector(0,0,500)*(try+1)
		local result = util.TraceLine(traceData)
		if result.Hit then
			if result.HitSky then
				print("Found the sky after "..(try+1).." tries")
				return result.HitPos
			end
			print("Hit something other than the sky after "..(try+1).." tries")
			return nil
		end
		try = try + 1
	end
	print("Could not find the sky in "..(try+1).." tries")
	return nil
end