//CSModel setup for hud
local packageModel = ClientsideModel("models/props_junk/wood_crate001a.mdl")
packageModel:SetNoDraw(true)

local CSModels = {}
for name, data in pairs(ADVPACK_ITEMLIST) do
	if CSModels[name] == nil then
		CSModels[name] = ClientsideModel(data.model)
		CSModels[name]:SetNoDraw(true)
	end
end

//Colors and materials
local smokeMat = Material("particle/particle_smokegrenade")
local windowColor = Color(50, 50, 50, 100)
local fullBright = Color(255, 255, 255)
//Anim params setup
local packageAnimData = nil
local STATE_IDLE = 0
local STATE_INIT = 1
local STATE_OPENING = 2
local STATE_ASSEMBLING = 3
local STATE_ASSEMBLY_DONE = 4
local STATE_LOCKING = 5
local STATE_SHIPPING = 6

local PACKAGE_START_Z = 150
local PACKAGE_GOAL_Z = -40
local ITEM_SPIN_Z = 30
local PACKAGE_END_Z = -200
local GRAVITY = -500

local WINDOW_GOAL_WIDTH = 200
local WINDOW_GOAL_HEIGHT = 250

local windowGoalWidth = 0
local windowGoalHeight = 0

local state = STATE_IDLE

local packageZ = PACKAGE_START_Z
local packageX = 0
local packageY = 0
local packageVelZ = 0
local packageVelX = 0
local packageJitter = 0
local packageAng = Angle(0, math.random(0, 359), 0)

local windowWidth = 0
local windowHeight = 0

local indProgressBarAnim = 0
local lastTime = CurTime()
local assemblyStartTime = 0

//Falling items!

local items = {}
local curItem = 1
//Particle system!
local particles = {}
local function addItem(p_model, p_finishTime, p_name)
	items[#items+1] = {model=p_model, pos=Vector(0,0,PACKAGE_START_Z), vel=Vector(0,0,0), ang=Angle(math.random(-45, 45), 0, 0), finishTime=p_finishTime, done = false, name=p_name}
end
local function createParticle(p_material, p_pos, p_vel, p_size, p_decay)
	particles[#particles+1] = {material=p_material, pos=p_pos, vel=p_vel, size=p_size, decay=p_decay}
end
hook.Add( "HUDPaint", "APD_HUD", function()
	local deltaT = CurTime() - lastTime
	lastTime = CurTime()
	windowHeight = windowHeight + (windowGoalHeight - windowHeight)*deltaT*20
	windowWidth = windowWidth + (windowGoalWidth - windowWidth)*deltaT*20
	if state == STATE_OPENING then
			packageVelZ = packageVelZ + GRAVITY*deltaT
			packageZ = packageZ + packageVelZ*deltaT
			if packageZ <= PACKAGE_GOAL_Z then
				surface.PlaySound("complover116/AdvPackageDrop/package_impactlow.wav")
				packageJitter = 10
				state = STATE_ASSEMBLING
				for i = 1, 10 do
					createParticle(smokeMat, Vector(packageX, packageY, packageZ), VectorRand()*100, 64, 64)
				end
			end
	end
	if state == STATE_LOCKING && LocalPlayer():GetNetworkedInt("packageStat") == ADVPACK_STATUS_SHIPPING then
		state = STATE_SHIPPING
		packageVelZ = 0
		assemblyStartTime = CurTime()
	end
	if state == STATE_SHIPPING then
			
			if packageZ < PACKAGE_END_Z then
				windowGoalHeight = 25
			else
				packageVelZ = packageVelZ + GRAVITY*deltaT
				packageZ = packageZ + packageVelZ*deltaT
			end
			
			if LocalPlayer():GetNetworkedInt("packageStat") == ADVPACK_STATUS_IDLE then
				windowGoalWidth = 0
				if windowWidth < 1 then
					state = STATE_IDLE
				end
			end
	end
	if state == STATE_INIT then
		packageZ = PACKAGE_START_Z
		packageVelZ = 0
		windowHeight = 0
		windowWidth = 0
		windowGoalHeight = WINDOW_GOAL_HEIGHT
		windowGoalWidth = WINDOW_GOAL_WIDTH
		curItem = 1
		packageAng = Angle(0, math.random(0, 359), 0)
		state = STATE_OPENING
	end
	
	if state != STATE_IDLE then
		if packageJitter > 0 then
			packageJitter = packageJitter - deltaT*50
		else
			packageJitter = 0
		end
		draw.RoundedBox(10, 0, 0, windowWidth, windowHeight, windowColor)
		cam.Start3D(Vector(-100,0,0), Angle(0,0,0), 70, 0, 0, WINDOW_GOAL_WIDTH, WINDOW_GOAL_HEIGHT)
			//PARTICLES!
			for id, particle in pairs(particles) do
				particle.pos = particle.pos + particle.vel*deltaT
				particle.size = particle.size - particle.decay*deltaT
				if particle.size < 0 then
					particles[id] = nil
				else
					render.SetMaterial(particle.material)
					render.DrawSprite(particle.pos, particle.size, particle.size, fullBright)
				end
			end
			
			if state == STATE_ASSEMBLING then
				for id = 1, curItem do
					local item = items[id]
					if item == nil then
						break
					end
					if !item.done then
						item.ang = item.ang + Angle(0, deltaT*90, 0)
						if item.finishTime > CurTime() then
							item.pos = item.pos + (Vector(0, 0, ITEM_SPIN_Z) - item.pos)*deltaT*10
						else
							if curItem == id then
								if curItem > #items then
									//END THE PACKING!
								else
									curItem = curItem + 1
									assemblyStartTime = CurTime()
								end
							end
							item.pos = item.pos + item.vel*deltaT
							item.vel = item.vel + Vector(0, 0, GRAVITY*deltaT)
							if item.pos.z <= packageZ then
								item.done = true
								surface.PlaySound("complover116/AdvPackageDrop/package_impactlow.wav")
								packageJitter = 10
								for i = 1, 10 do
									createParticle(smokeMat, Vector(packageX, packageY, packageZ), VectorRand()*100, 64, 64)
								end
								if id == #items then
									state = STATE_LOCKING
								end
							end
						end
					item.model:SetPos(item.pos)
					item.model:SetupBones()
					item.model:SetAngles(item.ang)
					item.model:DrawModel()
					end
				end
			end
			
			//Package itself
			packageModel:SetPos(Vector(packageX, packageY, packageZ))
			packageModel:SetupBones()
			packageModel:SetAngles(packageAng+Angle(math.random(-packageJitter, packageJitter), 0, math.random(-packageJitter, packageJitter)))
			packageModel:DrawModel()
		cam.End3D()
		
		if items[curItem] != nil then
			draw.RoundedBox(10, 0, 0, windowWidth, 25, Color(0,0,0))
			draw.RoundedBox(10, 0, 0, windowWidth*(CurTime() - assemblyStartTime)/(items[curItem].finishTime-assemblyStartTime), 25, Color(0,200,0))
			draw.SimpleText(items[curItem].name, "Trebuchet24", windowWidth/2, 0, fullBright, TEXT_ALIGN_CENTER)
		end
		if state == STATE_SHIPPING then
			draw.RoundedBox(10, 0, 0, windowWidth, 25, Color(0,0,0))
			draw.RoundedBox(10, 0, 0, windowWidth*(CurTime() - assemblyStartTime)/(packageAnimData.shippingTime), 25, Color(0,200,0))
			draw.SimpleText("Shipping...", "Trebuchet24", windowWidth/2, 0, fullBright, TEXT_ALIGN_CENTER)
		end
		if state == STATE_LOCKING then
			draw.RoundedBox(10, 0, 0, windowWidth, 25, Color(0,0,0))
			//draw.RoundedBox(10, (CurTime()*windowWidth)%windowWidth, 0, windowWidth*0.25, 25, Color(0,200,0))
			draw.SimpleText("Waiting for marker", "Trebuchet24", windowWidth/2, 0, fullBright, TEXT_ALIGN_CENTER)
		end
	end
	//draw.WordBox( 5, 0, 0, "state:"..state.." packagez:"..packageZ, "Trebuchet24", Color(0,0,200), Color(255,255,255) ) 
end )

net.Receive( "package_animate_hud", function(length, ply)
	state = STATE_INIT
	packageAnimData = net.ReadTable()
	assemblyStartTime = CurTime()
	items = {}
	local time = CurTime()
	for item, amount in pairs(packageAnimData.contents) do
		for i = 1, amount do
			time = time + ADVPACK_ITEMLIST[item].assembleTime
			addItem(CSModels[item], time, ADVPACK_ITEMLIST[item].name)
		end
	end
end)