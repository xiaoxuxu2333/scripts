if _G.AutoParry then
	task.cancel(_G.AutoParry)
end

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BallAdded = Remotes:WaitForChild("BallAdded")
local BallRemoved = Remotes:WaitForChild("BallRemoved")
local ParryButtonPress = Remotes:WaitForChild("ParryButtonPress")
local ParryAttempt = Remotes:WaitForChild("ParryAttempt")
local ParrySuccess = Remotes:WaitForChild("ParrySuccess")
local ParrySuccessAll = Remotes:WaitForChild("ParrySuccessAll")
local VisualCD = Remotes:WaitForChild("VisualCD")

local Player = Players.LocalPlayer
local Character = Player.Character

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://5273899897"
ClickSound.Volume = 10
ClickSound.PlaybackSpeed = 20

local ParryEvent = Instance.new("BindableEvent")
ParryEvent.Event:Connect(function()
	SoundService:PlayLocalSound(ClickSound)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
	print("sended")
end)

local function GetTime()
	return workspace:GetServerTimeNow()
end

local function FindRealBall()
	for _, ball in next, workspace.Balls:GetChildren() do
		if ball:GetAttribute("realBall") then
			return ball
		end
	end
end

local function Clean()
	if workspace.CurrentCamera:FindFirstChild("RangeCHA") then
		workspace.CurrentCamera.RangeCHA:Destroy()
	end
end

_G.AutoParry = task.spawn(function()
	Clean()
	
	local RangeCHA = Instance.new("CylinderHandleAdornment")
	RangeCHA.Height = 0
	RangeCHA.Color3 = Color3.new(1, 1, 1) 
	RangeCHA.Transparency = 0.5
	RangeCHA.CFrame = CFrame.Angles(math.rad(90), 0, 0)
	RangeCHA.Name = "RangeCHA"
	RangeCHA.Parent = workspace.CurrentCamera
	
	local lastParryTime = GetTime()
	
	while true do
		Character = Player.Character
		RangeCHA.Adornee = Character and Character:FindFirstChild("HumanoidRootPart")
		
		local realBall = FindRealBall()
		if realBall then
			while realBall.Parent do
				task.wait()
				local distance = realBall.AssemblyLinearVelocity.Magnitude / 1.8
				
				RangeCHA.Radius = distance
				RangeCHA.Color3 = realBall:GetAttribute("target") == Player.Name and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
			
				if realBall:GetAttribute("target") == Player.Name
					and (realBall.Position - Character.HumanoidRootPart.Position).Magnitude <= distance
				then
					ParryEvent:Fire()
					VisualCD.OnClientEvent:Wait()
					VisualCD.OnClientEvent:Wait()
					
					--lastParryTime = GetTime()
					
					--[[local cd = false
					repeat
						local _, blocked = VisualCD.OnClientEvent:Wait()
						cd = blocked
					until not cd]]
					
					--ParrySuccessAll.OnClientEvent:Wait()
				end
			end
		else
			RangeCHA.Radius = 10
			RangeCHA.Color3 = Color3.new(1, 1, 1)
		end
		
		task.wait()
	end
end)