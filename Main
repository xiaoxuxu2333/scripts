local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function spawn(func, ...)
	local thread = coroutine.create(func)
	
	local suc, res = coroutine.resume(thread, ...) 
	if not suc then
		error(res)
	end
	
	return thread
end

local function findBall()
	for _, ball in ipairs(workspace.Balls:GetChildren()) do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

local function parry()
	local param1 = 0.5
	local param2 = CFrame.new()
	local param3 = {}
	local param4 = {}
	
	for _, alive in ipairs(workspace.Alive:GetChildren()) do
		local plr = Players:GetPlayerFromCharacter(alive)
		param3[tostring(plr.UserId)] = Vector3.zero
	end
	
	local ball = findBall()
	if ball then
		param2 = CFrame.lookAt(player.Character.HumanoidRootPart.Position, ball.Position)
	end
	
	game.ReplicatedStorage.Remotes.ParryAttempt:FireServer(param1, param2, param3, param4)
end

local function checkDist(v1, v2)
	return (v1 - v2).Magnitude
end

local function start()
	local range = workspace:FindFirstChild("range") or Instance.new("CylinderHandleAdornment")
	range.Name = "range"
	range.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	range.Color3 = Color3.new(1, 1, 1)
	range.Height = 0
	range.Parent = workspace
	
	local spamRange = workspace:FindFirstChild("spamRange") or Instance.new("CylinderHandleAdornment")
	spamRange.Name = "spamRange"
	spamRange.CFrame = CFrame.new(0, -0.001, 0) * CFrame.Angles(math.rad(90), 0, 0)
	spamRange.Color3 = Color3.new(0, 0, 1)
	spamRange.Height = 0
	spamRange.Radius = 25.5
	spamRange.InnerRadius = spamRange.Radius - 2
	spamRange.Parent = workspace
	
	local lastParryTime = workspace:GetServerTimeNow()
	
	local maxDist = 25
	local lastTargetDist = math.huge
	
	while true do
		local ball = findBall()
		
		range.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
		spamRange.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
		range.Radius = maxDist
		range.InnerRadius = maxDist - 1
		
		if ball and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local speed = ball.AssemblyLinearVelocity.Magnitude
			local dist = checkDist(ball.Position, player.Character.HumanoidRootPart.Position)
			if (speed / 2.74) > maxDist then
				maxDist = math.max(ball.AssemblyLinearVelocity.Magnitude / 2.74, 25)
			end
			
			local target = ball:GetAttribute("target")
			
			if target == player.Name then
				range.Color3 = Color3.new(1, 1, 0)
				
				if dist < maxDist then
					range.Color3 = Color3.new(1, 0, 0)
					
					local duration = workspace:GetServerTimeNow() - lastParryTime
					spawn(parry)
					if lastTargetDist > spamRange.Radius then
						ball.Changed:Wait()
						print(ball.AssemblyLinearVelocity.Magnitude)
					else
						range.Color3 = Color3.new(0, 0, 1)
						repeat
							for _ = 1, 2 do
								spawn(parry)
							end
							task.wait()
							dist = checkDist(ball.Position, player.Character.HumanoidRootPart.Position)
						until dist > spamRange.Radius or not ball.Parent
					end
					lastParryTime = workspace:GetServerTimeNow()
				else
					range.Color3 = Color3.new(1, 1, 0)
				end
			else
				if target ~= "" then
					lastTargetDist = checkDist(workspace.Alive[target].HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
				end
				range.Color3 = Color3.new(1, 1, 1)
			end
		else -- game over
			maxDist = 25
			range.Color3 = Color3.new(1, 1, 1)
		end
		
		task.wait()
		if ball and not ball.Parent then
			maxDist = 25
		end
	end
end

if _G.started then
	coroutine.close(_G.started)
	_G.started = nil
end

_G.started = coroutine.create(start)
local suc, res = coroutine.resume(_G.started)
if not suc then
	error(res)
end
