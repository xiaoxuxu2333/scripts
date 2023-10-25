local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local localLeaderstats = localPlayer.leaderstats
local localBackpack = localPlayer.Backpack
local localCharacter = localPlayer.Character
local localRemote = localCharacter.clientMain.Remote
local localKnife = localBackpack:FindFirstChildWhichIsA("Tool") or localCharacter:FindFirstChildWhichIsA("Tool")
local localKnifeRemote = localKnife and localKnife.Knife.Remote
local localHumanoid = localCharacter.Humanoid

-- Death
-- Teleport
-- unragdoll
-- Swing, Knife
-- Hit, Humanoid

--for i, player in ipaisr

function GiveKnife()
	if localRemote then
		localRemote:FireServer("Teleport")
		repeat task.wait() Setup() until localKnife
	end
end

function Hit()
	if localKnifeRemote and localHumanoid then
		localKnifeRemote:FireServer("Hit", localHumanoid)
	end
end

function Setup()
	localCharacter = localPlayer.Character
	localBackpack = localPlayer.Backpack
	localRemote = localCharacter and localCharacter:WaitForChild("clientMain"):WaitForChild("Remote")
	localKnife = localBackpack:FindFirstChildWhichIsA("Tool") or (localCharacter and localCharacter:FindFirstChildWhichIsA("Tool"))
	localKnifeRemote = localKnife and localKnife:WaitForChild("Knife"):WaitForChild("Remote")
	localHumanoid = localCharacter and localCharacter:WaitForChild("Humanoid")
end

if not localKnife then
	GiveKnife()
end
localKnife.Parent = localBackpack

while true do
	while localCharacter.Parent do
		task.wait()
		Hit()
	end
	
	task.wait()
	Setup()
	
	if not localKnife then
		GiveKnife()
	end
	localKnife.Parent = localBackpack
end