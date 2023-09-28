if _G.AutoParry then
	task.cancel(_G.AutoParry)
end

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BallAdded = Remotes:WaitForChild("BallAdded")
local BallRemoved = Remotes:WaitForChild("BallRemoved")
local ParryButtonPress = Remotes:WaitForChild("ParryButtonPress")
local ParryAttempt = Remotes:WaitForChild("ParryAttempt")
local VisualCD = Remotes:WaitForChild("VisualCD")

local Player = Players.LocalPlayer
local Character = Player.Character

_G.AutoParry = task.spawn(function()
	if workspace.CurrentCamera:FindFirstChild("RangeCHA") then
		workspace.CurrentCamera.RangeCHA:Destroy()
	end
	
	local RangeCHA = Instance.new("CylinderHandleAdornment")
	RangeCHA.Height = 0
	RangeCHA.Color3 = Color3.new(1, 1, 1) 
	RangeCHA.Transparency = 0.5
	RangeCHA.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	RangeCHA.Name = "RangeCHA"
	RangeCHA.Parent = workspace.CurrentCamera
	
	local ClickSound = Instance.new("Sound")
	ClickSound.SoundId = "rbxassetid://5273899897"
	ClickSound.Volume = 10
	ClickSound.PlaybackSpeed = 20
	
	local lastParryTime = tick()
	
	while true do
		Character = Player.Character
		
		local realBall
		for _, ball in next, workspace.Balls:GetChildren() do
			if ball:GetAttribute("realBall") then
				realBall = ball
				break
			end
		end
		
		RangeCHA.Adornee = Character and Character:FindFirstChild("HumanoidRootPart")
		
		if realBall then
			local distance = realBall.AssemblyLinearVelocity.Magnitude / 1.8
			
			RangeCHA.Radius = distance
			RangeCHA.Color3 = realBall:GetAttribute("target") == Player.Name and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
		
			if realBall:GetAttribute("target") == Player.Name and (realBall.Position - Character.HumanoidRootPart.Position).Magnitude <= distance then
				task.wait()
				
				SoundService:PlayLocalSound(ClickSound)
				for _ = 1, 500 do
					ParryAttempt:FireServer(0, CFrame.new(), {}, {})
				end
				
				local lastTime = tick()
				local isCooldowning = true
				local conn = VisualCD.OnClientEvent:Connect(function(alive, idk, cooldownSeconds)
					if not cooldownSeconds then
						isCooldowning = false
					end
				end)
				
				repeat
					if tick() - lastParryTime < 0.3 then break end
					RunService.RenderStepped:Wait()
				until tick() - lastTime > 1.2 or not isCooldowning
				
				conn:Disconnect()
				
				lastParryTime = tick()
			end
		else
			RangeCHA.Radius = 10
			RangeCHA.Color3 = Color3.new(1, 1, 1)
		end
		
		RunService.Heartbeat:Wait()
	end
end)
