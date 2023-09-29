local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local random = Random.new()

local plrPulled = Instance.new("BindableEvent")

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
	local param2 = CFrame.lookAt(Vector3.zero, --random:NextUnitVector()
		Vector3.yAxis
	)
	local param3 = {}
	local param4 = {238, 40}
	
	local ball = findBall()
	if ball then
		local unit = ball.zoomies.VectorVelocity.Unit
		param2 = CFrame.lookAt(Vector3.zero, -unit)
	end

	for _, alive in ipairs(workspace.Alive:GetChildren()) do
		local plr = Players:GetPlayerFromCharacter(alive)
		param3[tostring(plr.UserId)] = alive.HumanoidRootPart.Position
	end

	game.ReplicatedStorage.Remotes.ParryAttempt:FireServer(param1, param2, param3, param4)
end

local function checkDist(v1, v2)
	return (v1 - v2).Magnitude
end

local function start()
	local thread = coroutine.running()

	local range = workspace:FindFirstChild("range") or Instance.new("CylinderHandleAdornment")
	range.Name = "range"
	range.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	range.Color3 = Color3.new(1, 1, 1)
	range.Height = 1
	range.Radius = 25
	range.InnerRadius = range.Radius - 1
	range.Parent = workspace

	local spamRange = workspace:FindFirstChild("spamRange") or Instance.new("CylinderHandleAdornment")
	spamRange.Name = "spamRange"
	spamRange.CFrame = CFrame.new(0, -0.001, 0) * CFrame.Angles(math.rad(90), 0, 0)
	spamRange.Color3 = Color3.new(0, 0, 1)
	spamRange.Height = 1
	spamRange.Radius = 25
	spamRange.InnerRadius = spamRange.Radius - 1
	spamRange.Parent = workspace

	local lastTargetRange = workspace:FindFirstChild("lastTargetRange") or Instance.new("CylinderHandleAdornment")
	lastTargetRange.Name = "lastTargetRange"
	lastTargetRange.CFrame = CFrame.new(0, -0.002, 0) * CFrame.Angles(math.rad(90), 0, 0)
	lastTargetRange.Color3 = Color3.new(1, 0, 1)
	lastTargetRange.Height = 1
	lastTargetRange.Radius = 100
	lastTargetRange.InnerRadius = lastTargetRange.Radius - 1
	lastTargetRange.Visible = false
	lastTargetRange.Parent = workspace
	
	local ballLookVector = workspace:FindFirstChild("ballLookVector") or Instance.new("ConeHandleAdornment")
	ballLookVector.Name = "ballLookVector"
	ballLookVector.CFrame = CFrame.new(0, 0, -2)
	ballLookVector.Color3 = Color3.new(1, 1, 1)
	ballLookVector.Height = 2
	ballLookVector.Radius = 1
	ballLookVector.Parent = workspace
	
	local lastParryTime = workspace:GetServerTimeNow()

	local lastTarget

	local function updateRanges()
		while coroutine.status(thread) ~= "dead" do
			local ball = findBall()

			range.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
			spamRange.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
			lastTargetRange.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
			ballLookVector.Adornee = ball
			
			if ball and ball:FindFirstChild("zoomies") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local velocity = ball.zoomies.VectorVelocity
				local unit = velocity.Unit
	
				ballLookVector.CFrame = ball.CFrame.Rotation:Inverse() * CFrame.new(unit * 2, unit * 4)
				
				local speed = velocity.Magnitude
				local dist = checkDist(ball.Position, player.Character.HumanoidRootPart.Position)
				
				if (speed / 2.74) > range.Radius then
					range.Radius = math.max(speed / 2.74, 25)
					range.InnerRadius = range.Radius - 1
				end
				
				spamRange.Radius += 0.25 -- range.Radius / 1.75 --math.clamp(spamRange.Radius + 0.125, 25, 250)
				spamRange.InnerRadius = spamRange.Radius - 1

				local target = ball:GetAttribute("target")
				
				if target == player.Name then
					range.Color3 = Color3.new(1, 1, 0)

					if dist < range.Radius then
						range.Color3 = Color3.new(1, 0, 0)

						--spamRange.Radius = range.Radius / 2 --math.clamp(spamRange.Radius + 0.125, 25, 250)
						--spamRange.InnerRadius = spamRange.Radius - 1

						if lastTargetRange.Radius <= spamRange.Radius then
							range.Color3 = Color3.new(0, 0, 1)
						end
					else
						range.Color3 = Color3.new(1, 1, 0)
					end
				else
					if target ~= "" then
						lastTarget = workspace.Alive[target]
						lastTargetRange.Radius = checkDist(lastTarget.HumanoidRootPart.Position, player.Character.HumanoidRootPart.Position)
						lastTargetRange.InnerRadius = lastTargetRange.Radius - 1
					end
					range.Color3 = Color3.new(1, 1, 1)
				end
			end

			task.wait()

			if ball and not ball.Parent then
				range.Radius = 25
				range.InnerRadius = range.Radius - 1

				spamRange.Radius = 25
				spamRange.InnerRadius = spamRange.Radius - 1

				lastTargetRange.Radius = 100
				lastTargetRange.InnerRadius = lastTargetRange.Radius - 1

				range.Color3 = Color3.new(1, 1, 1)
			end
		end
	end

	local function rainbow()
		local tween_1 = TweenService:Create(spamRange, TweenInfo.new(1, Enum.EasingStyle.Linear), {Color3 = Color3.new(1, 0, 0)})
		local tween_2 = TweenService:Create(spamRange, TweenInfo.new(1, Enum.EasingStyle.Linear), {Color3 = Color3.new(0, 1, 0)})
		local tween_3 = TweenService:Create(spamRange, TweenInfo.new(1, Enum.EasingStyle.Linear), {Color3 = Color3.new(0, 0, 1)})

		while coroutine.status(thread) ~= "dead" do
			tween_1:Play()
			tween_1.Completed:Wait()
			tween_2:Play()
			tween_2.Completed:Wait()
			tween_3:Play()
			tween_3.Completed:Wait()
		end
	end

	local co_1 = coroutine.create(rainbow)
	local co_2 = coroutine.create(updateRanges)

	coroutine.resume(co_1)
	coroutine.resume(co_2)

	while true do
		local ball = findBall()

		if ball and ball:FindFirstChild("zoomies") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local speed = ball.zoomies.VectorVelocity.Magnitude
			local dist = checkDist(ball.Position, player.Character.HumanoidRootPart.Position)

			local target = ball:GetAttribute("target")

			if target == player.Name then
				if dist < range.Radius then
					spawn(parry)

					if lastTargetRange.Radius > spamRange.Radius then
						local changed = false
						local changedConn = ball.Changed:Once(function()
							changed = true
						end)

						repeat
							speed = ball.zoomies.VectorVelocity.Magnitude
							task.wait()
						until changed or speed < 1

						changedConn:Disconnect()
					else
						--game.ReplicatedStorage.Remotes.PlrForcefielded:FireServer()
						print("spam")
						repeat
							for _ = 1, 2 do
								spawn(parry)
							end
							task.wait()
							dist = checkDist(ball.Position, player.Character.HumanoidRootPart.Position)
						until dist > spamRange.Radius or not ball.Parent
					end
					lastParryTime = workspace:GetServerTimeNow()
				end
			end
		end

		task.wait()
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
