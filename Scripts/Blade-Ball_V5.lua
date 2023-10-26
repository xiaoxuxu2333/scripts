if game.ReplicatedStorage:FindFirstChild("Security") then
	game.ReplicatedStorage.Security:Destroy()
end
if game.Players.LocalPlayer.PlayerScripts.Client:FindFirstChild("DeviceChecker") then
	game.Players.LocalPlayer.PlayerScripts.Client.DeviceChecker:Destroy()
end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local rng = Random.new()

local range = workspace:FindFirstChild("range") or Instance.new("CylinderHandleAdornment")
range.Name = "range"
range.CFrame = CFrame.Angles(math.rad(90), 0, 0)
range.Color3 = Color3.new(1, 1, 1)
range.AlwaysOnTop = true
range.Transparency = 0.75
range.Height = 0
range.Parent = workspace
	
local spamRange = workspace:FindFirstChild("spamRange") or Instance.new("CylinderHandleAdornment")
spamRange.Name = "spamRange"
spamRange.CFrame = CFrame.Angles(math.rad(90), 0, 0)
spamRange.Color3 = Color3.new(0, 0, 1)
spamRange.AlwaysOnTop = true
spamRange.Transparency = 0.75
spamRange.Height = 0
spamRange.Parent = workspace

local mover = workspace:FindFirstChild("mover") or Instance.new("AlignPosition")
mover.Name = "mover"
mover.Mode = Enum.PositionAlignmentMode.OneAttachment
mover.ForceLimitMode = Enum.ForceLimitMode.PerAxis
mover.MaxAxesForce = Vector3.new(50000, 0, 50000)
mover.MaxVelocity = 100
mover.Responsiveness = 200
mover.Parent = workspace

local function sendNotification(title, text)
	StarterGui:SetCore("SendNotification", {
		Title = title,
		Text = text,
		Duration = 0,
	})
end

local function getBall()
	return workspace.Balls:GetChildren()[1]
end

local function getBallTarget(ball)
	return workspace.Alive:FindFirstChild(ball:GetAttribute("target"))
end

local function isBallStopped(zoomies)
	return zoomies.VectorVelocity.magnitude == 0
end

local bugBall = false

do
	local deb = false
	
	function parry(canSpam)
		if player.Character.Parent ~= workspace.Alive then return end
		
		local suc, res = pcall(function()
			local hitTime = 0
			local direction = CFrame.new()
			local p3 = {}
		
			local ball = getBall()
			if ball
				and not canSpam
			then
				direction = CFrame.new(Vector3.zero, if deb then
					ball.zoomies.VectorVelocity.unit
					else -ball.zoomies.VectorVelocity.unit
				)
				deb = not deb
			end
			
			for _, plr in ipairs(Players:GetPlayers()) do
				local char = plr.Character
				if not char or not char:FindFirstChild("Head") then continue end
				local pos = Vector3.zero
				
				p3[tostring(plr.UserId)] = if not bugBall then pos else char.Head
			end
			
			game.ReplicatedStorage.Remotes.ParryAttempt:FireServer(hitTime, direction, p3, {0, 0})
		end)
		
		if not suc then
			warn(res)
		end
	end
end

local function isTeammate(target)
	local suc, res = pcall(function()
		if target.Head:FindFirstChild("Icon")
			and player.Character.Head:FindFirstChild("Icon")
		then
			return target.Head.Icon.ImageLabel.ImageColor3 == player.Character.Head.Icon.ImageLabel.ImageColor3
		end
		
		return false
	end)
	
	if not suc then
		warn(res)
	end
	
	return suc and res
end

local function isOthersInvis()
	local suc, res = pcall(function()
		for _, char in ipairs(workspace.Alive:GetChildren()) do
			if char == player.Character or isTeammate(char) then continue end
			if char.Torso.Transparency < 1 then
				return false
			end
		end
		
		if #workspace.Alive:GetChildren() <= 1
			or workspace.Floating:FindFirstChild("hed")
		then
			return false
		end
	
		return true
	end)
	
	if not suc then
		warn(res)
	end
	
	return suc and res
end

local function getMap()
	return workspace.Map:GetChildren()[1]
end

local function isTargetForcefieldded(target)
	local suc, res = pcall(function()
		return (target.HumanoidRootPart:FindFirstChild("MaxShield") or target.HumanoidRootPart:FindFirstChild("Shield")) ~= nil
	end)
	
	if not suc then
		warn(res)
	end
	
	return suc and res
end

local function isBallPulled()
	local suc, res = pcall(function()
		local pullPart = workspace.Floating:FindFirstChild("MaxPull") or workspace.Floating:FindFirstChild("Pull")
		
		return pullPart
	end)
	
	if not suc then
		warn(res)
	end
	
	return suc and res
end

local function isInfinityBall(ball)
	local suc, res = pcall(function()
		local target = getBallTarget(ball)
		local dist = (ball.Position - target.HumanoidRootPart.Position).magnitude
		local speed = ball.zoomies.VectorVelocity.magnitude
		
		if dist < 20 and speed < 36 then
			return true
		end
		
		return false
	end)
	
	if not suc then
		warn(res)
	end
	
	return suc and res
end

local function isBallFrozen()
	local suc, res = pcall(function()
		local freezePart = (workspace.Floating:FindFirstChild("MaxFreezeFX") or workspace.Floating:FindFirstChild("FreezeFX"))
		
		return freezePart ~= nil
	end)
	
	if not suc then
		warn(res)
	end
	
	return suc and res
end

local function findClosestPlr()
	local closest
	local maxDist = 16
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player or not plr.Character then continue end
		if plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if dist < maxDist then
				maxDist = dist
				closest = plr
			end
		end
	end
	
	return closest
end

getgenv().coroutines = coroutines or {}

for i, co in ipairs(coroutines) do
	coroutine.close(co)
	coroutines[i] = nil
end

table.insert(coroutines, task.spawn(function()
	while true do
		task.wait()

		bugBall = UserInputService:IsKeyDown(Enum.KeyCode.G)

		local ball = getBall()
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		local rootAtt = root and root:FindFirstChild("RootAttachment")
		
		range.Adornee = root
		spamRange.Adornee = root
		mover.Attachment0 = rootAtt

		if root
			and ball
			and player.Character.Parent == workspace.Alive
		then
			local tar = getBallTarget(ball)
			if tar == nil or tar:FindFirstChild("HumanoidRootPart") == nil then continue end
			if tar == player.Character then
				--task.spawn(parry, true)
			else
				mover.Position = tar.HumanoidRootPart.Position
			end

			print(ball.zoomies.VectorVelocity)
		end
		mover.Enabled = player.Character.Parent == workspace.Alive
	end
end))

table.insert(coroutines, task.spawn(function()
	while true do
		task.wait()
		local map = getMap()
		if map == nil then continue end
		for _, v in ipairs(map:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
		local platform = workspace:FindFirstChild("platform") or Instance.new("Part")
		platform.Name = "platform"
		platform.Anchored = true
		if map:FindFirstChild("BottomCircle") then
			platform.Position = map.BottomCircle.Position-(Vector3.yAxis*0)
		elseif map:FindFirstChild("BALLSPAWN") then
			platform.Position = map.BALLSPAWN.Position-(Vector3.yAxis*0)
		end
		platform.Size = Vector3.new(2048, 1, 2048)
		platform.Parent = workspace
		
	end
end))


local duration = 30
local lastTime = workspace:GetServerTimeNow()

table.insert(coroutines, task.spawn(function()
	while false do
		task.wait()
		
		local ball = getBall()
		local zoomies = ball and ball:FindFirstChild("zoomies")
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		
		while zoomies
			and root
			and ball.Parent
			and root.Parent
		do
			task.wait()
			if isBallStopped(zoomies) then continue end
			
			local tar = getBallTarget(ball)
			local tarRoot = tar and tar:FindFirstChild("HumanoidRootPart")
			local spd = zoomies.VectorVelocity.magnitude
			local maxDist = math.max(spd / 3, range.Radius)
			local maxSpamDist = math.clamp(maxDist / 2, 24, 100)
			
			range.Radius = maxDist
			spamRange.Radius = maxSpamDist
			range.InnerRadius = maxSpamDist

			range.CFrame = root.CFrame.Rotation:Inverse() * CFrame.lookAt(root.Position, ball.Position).Rotation * CFrame.Angles(math.rad(90), 0, 0)
			spamRange.CFrame = root.CFrame.Rotation:Inverse() * CFrame.lookAt(root.Position, ball.Position).Rotation * CFrame.Angles(math.rad(90), 0, 0)
			
			if tarRoot
				and tarRoot.Parent
				and root.Parent
				and player.Character.Parent == workspace.Alive
			then
				--local dist = ((tarRoot.Position + (tarRoot.velocity / 9)) - (ball.Position + (ball.velocity / 9))).magnitude
				local dist = (tarRoot.Position-ball.Position).magnitude
				
				if tarRoot == root
					and dist < range.Radius
				then
					range.Radius += 5
					
					local time = workspace:GetServerTimeNow()
			
					duration = time - lastTime
					lastTime = time
					
					repeat
						task.spawn(parry)
						task.wait()
					until isOthersInvis()
						or getBallTarget(ball) ~= tar
						or isBallStopped(zoomies)
						--or dist < spamRange.Radius
						or not ball.Parent

					
					
					if isBallPulled() and tar:FindFirstChild("ParryHighlight") then
						sendNotification("Script", "Got Pulled")
						--game.ReplicatedStorage.Remotes.Freeze:FireServer()
						game.ReplicatedStorage.Remotes.PlrForcefielded:FireServer()
					end
					
					while isOthersInvis() do
						task.spawn(parry, true)
						
						mover.Position = ball.Position
						
						task.wait()
					end
				elseif tarRoot ~= root
					and not isTeammate(tar)
				then
					local tarDist = (root.Position - tarRoot.Position).magnitude
					
					local looped = false
					
					--local tempTargetParrying = tar:FindFirstChild("ParryHighlight")
					
					while tarDist < spamRange.Radius
						and ball.Parent
						and not isBallStopped(zoomies)
						and dist < spamRange.Radius * 1.25
						and (duration < 0.75 or tarDist < 10)
						--and tempTargetParrying
					do
						task.wait()
						
						if not bugBall then
							--game.ReplicatedStorage.Remotes.PlrForcefielded:FireServer()
						end
						
						for _ = 1, math.min(math.floor(spamRange.Radius / tarDist), 18) do
							task.spawn(parry, true)
						end
						
						--root.CFrame = tarRoot.CFrame
						mover.Position = tarRoot.Position + (rng:NextUnitVector() * 10)
						
						tarDist = (root.Position - tarRoot.Position).magnitude
						dist = (ball.Position - tarRoot.Position).magnitude
						
						looped = true
					end
					
					if looped then
						spamRange.Radius = 24
						range.InnerRadius = 0
					end
				end
			end
		end
		
		range.Radius = 15
		spamRange.Radius = 24
		range.InnerRadius = 0
	end
end))
