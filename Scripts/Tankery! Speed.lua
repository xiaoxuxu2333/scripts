local Teams = game:GetService('Teams')
local Players = game:GetService('Players')

local player = Players.LocalPlayer
local objects = player.Objects
local gui = player.PlayerGui

function steer(v)
	gui.Steer.Value *= 1.05
end

function throttle(v)
	gui.Throttle.Value *= 1.4675
end

function camMode(v)
	gui['Client Main'].CamMode.Value = 0
end

function cleanUpMap(v)
	v = v or workspace.RoundScript.Map.Value
	for i, v in ipairs(v:GetChildren()) do
		local lower = v.Name:lower()
		if lower:find('tree')
			or lower:find('break')
			or lower:find('leave')
			or lower:find('trunk')
		then
			v:Destroy()
		end
		
		if v:IsA('BasePart') then
			v.CanCollide = true
		end
	end
end

if _G.cs then
	for i, v in ipairs(_G.cs) do
		v:Disconnect()
	end
end

_G.cs = {}

table.insert(_G.cs, workspace.RoundScript.Map.Changed:Connect(cleanUpMap))

table.insert(_G.cs, gui.Throttle.Changed:Connect(throttle))

--[[table.insert(_G.cs, player:GetPropertyChangedSignal('CameraMaxZoomDistance'):Connect(function()
	player.CameraMaxZoomDistance = 10000
end))]]

--table.insert(_G.cs, gui['Client Main'].CamMode.Changed:Connect(camMode))

table.insert(_G.cs, objects.Tank.Changed:Connect(function(v)
	task.wait()
	local bG = Instance.new('BodyGyro')
	bG.MaxTorque = Vector3.new(25, 0, 25)
	bG.Parent = v.Handle
	--v.Handle.HingeConstraint.AngularSpeed = math.huge
	--v.Handle.HingeConstraint.ServoMaxTorque = math.huge
	--v.Handle.HingeConstraint.AngularResponsiveness = 100
	--v.Turret.HingeConstraint.AngularSpeed = math.huge
	--v.Turret.HingeConstraint.AngularResponsiveness = 45
	v.DriveSeat.BodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
	v.DriveSeat.BodyAngularVelocity.P = math.huge
	v.DriveSeat.BodyAngularVelocity:GetPropertyChangedSignal('MaxTorque'):Connect(function() v.DriveSeat.BodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0) end)
	for i, v in ipairs(v.Hinges:GetChildren()) do
		v.MotorMaxAcceleration = math.huge
		v.MotorMaxTorque = math.huge
		
		v:GetPropertyChangedSignal('MotorMaxTorque'):Connect(function()
		    v.MotorMaxTorque = math.huge
		end)
	end
end))

table.insert(_G.cs, gui.DescendantAdded:Connect(function(v)
	if v.Name == 'Steer' or v.Name == 'Throttle' then
		table.insert(_G.cs, v.Changed:Connect(v.Name == 'Steer' and steer or throttle))
	--elseif v.Name == 'CamMode' then
		--table.insert(_G.cs, v.Changed:Connect(camMode))
	end
end))

table.insert(_G.cs, Players.PlayerAdded:Connect(function(player_)
	if player_:GetRankInGroup(2922224) >= 254 then
		player:Kick('An Admin Has Joined.')
	end
end))

--player.CameraMaxZoomDistance = 10000

cleanUpMap()