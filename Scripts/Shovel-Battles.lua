local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local gameAssets = ReplicatedStorage:WaitForChild("gameAssets")
local events = gameAssets:WaitForChild("events")

local localPlayer = Players.LocalPlayer
local localCharacter = localPlayer.Character
local localBackpack = localPlayer.Backpack
local localShovel = localBackpack:FindFirstChildWhichIsA("Tool") or localCharacter:FindFirstChildWhichIsA("Tool")
local localSettings = require(localShovel:WaitForChild("Settings"))

local hitSound = "Minecraft"

local target
local targetCharacter

local highlight = Instance.new("Highlight", workspace)
local bodyGyro = Instance.new("BodyGyro", localCharacter.HumanoidRootPart)

function FindNearestPlayer()
	local distance = 1024
	local nearestPlayer
	
	for i, player in ipairs(Players:GetPlayers()) do
		if player.Character
			and (player.Character:GetPivot().Position - localCharacter:GetPivot().Position).Magnitude < distance
			and player ~= localPlayer
			and player.Character:FindFirstChild("immune")
			and not player.Character.immune.Value
			and player.Character:FindFirstChild("Humanoid")
			and player.Character.Humanoid.Health > 0
		then
			distance = (player.Character:GetPivot().Position - localCharacter:GetPivot().Position).Magnitude
			nearestPlayer = player
		end
	end
	
	return nearestPlayer
end

while localCharacter.Parent do
	task.wait()
	
	target = FindNearestPlayer()
	targetCharacter = target and target.Character
	local targetPart = targetCharacter and targetCharacter:FindFirstChildWhichIsA("BasePart")
	
	if targetPart then
		highlight.Adornee = targetCharacter
		
		local args = {
		    [1] = targetCharacter, -- Hitter
		    [2] = targetPart, -- Hit Part
		    [3] = localSettings.damage, -- Damage
		    [4] = localSettings.power, -- Power
		    [5] = localSettings.powerUp, -- Power Up
		    [6] = localSettings.ragdollTime, -- Ragdoll Time
		    [7] = localShovel.shovel, -- Handle
		    [8] = hitSound -- Hit Sound
		}
		
		localShovel.Parent = localCharacter
		
		if (targetCharacter:GetPivot().Position - localCharacter:GetPivot().Position).Magnitude < 10 then
			localShovel:Activate()
			events.hit:FireServer(unpack(args))
		end
		
		localCharacter.Humanoid:MoveTo(targetCharacter:GetPivot().Position + -((targetCharacter:GetPivot().Position - localCharacter:GetPivot().Position).Unit * 8))
		bodyGyro.CFrame = CFrame.lookAt(localCharacter:GetPivot().Position, targetCharacter:GetPivot().Position)
	end
end
highlight:Destroy()
bodyGyro:Destroy()
