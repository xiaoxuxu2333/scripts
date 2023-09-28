_G.Toggle = not _G.Toggle

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ParryAttempt = Remotes:WaitForChild("ParryAttempt")
local ParrySuccess = Remotes:WaitForChild("ParrySuccess")
local VisualCD = Remotes:WaitForChild("VisualCD")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

if _G.Toggle then
	local ClickSound = Instance.new("Sound")
	ClickSound.SoundId = "rbxassetid://5273899897"
	ClickSound.Volume = 10
	ClickSound.PlaybackSpeed = 20
	
	local RangeCHA = Instance.new("CylinderHandleAdornment")
	RangeCHA.Height = 0
	RangeCHA.Color3 = Color3.new(1, 1, 1) 
	RangeCHA.Transparency = 0.5
	RangeCHA.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	RangeCHA.Parent = workspace.CurrentCamera
	
	local lastParryTime = 0
	local cooldown = false
	
	while _G.Toggle do
		local character = Player.Character
		
		if character and character:FindFirstChild("HumanoidRootPart") then
			local humanoidRootPart = character.HumanoidRootPart
			local playerPos = humanoidRootPart.Position
			
			RangeCHA.Adornee = humanoidRootPart
			
			for _, ball in workspace.Balls:GetChildren() do
				ball.Transparency = 0
				if ball:GetAttribute("target") == "" then continue end
				
				local maxDistance = ball.AssemblyLinearVelocity.Magnitude / 1.9
				local ballPos = ball.Position
				
				RangeCHA.Radius = maxDistance
				
				if ball:GetAttribute("target") == Player.Name
					and (ballPos - playerPos).Magnitude < maxDistance
				then
					SoundService:PlayLocalSound(ClickSound)
					RangeCHA.Color3 = Color3.new(1, 0, 0)
					local currentParryTime = tick() - lastParryTime
					print(currentParryTime)
					
					ParryAttempt:FireServer(0, CFrame.new(), {}, {})
					
					local timer = 1.2
					while timer > 0 or ball:GetAttribute("target") == Player.Name do
						timer -= RunService.Heartbeat:Wait()
					end
					
					lastParryTime = tick()
				else
					RangeCHA.Color3 = Color3.new(1, 1, 1)
				end
			end
		end
		
		RunService.RenderStepped:Wait()
	end
	
	RangeCHA:Destroy()
end
