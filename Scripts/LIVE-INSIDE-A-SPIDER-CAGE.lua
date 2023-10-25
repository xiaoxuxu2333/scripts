local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local localCharacter
local localBackpack

function FindNearestSpider()
	local distance = 1024
	local spider
	
	for i, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local isSpider = character and character:FindFirstChild("SpiderJoint", true) ~= nil
		
		if character
			and isSpider
			and (character:GetPivot().Position - localCharacter:GetPivot().Position).Magnitude < distance
		then
			distance = (character:GetPivot().Position - localCharacter:GetPivot().Position).Magnitude
			spider = player
		end
	end
	
	return spider
end

RunService.Heartbeat:Connect(function()
	localCharacter = localPlayer.Character
	localBackpack = localPlayer.Backpack
	
	local spider = FindNearestSpider()
	
	for i, drop in ipairs(workspace.Drops:GetChildren()) do
		drop:PivotTo(localCharacter:GetPivot())
	end
	
	for i, tool in ipairs(localBackpack:GetChildren()) do
		if tool:FindFirstChild("Shot", true) then
			tool.Parent = localCharacter
		end
	end
	
	if spider and spider.Character then
		local args = {
			    [1] = true,
			    [2] = spider.Character:FindFirstChildWhichIsA("BasePart")
		}
		
		for i, shotEvent in ipairs(localCharacter:GetDescendants()) do
			if shotEvent.Name == "Shot" then
				shotEvent:FireServer(unpack(args))
			end
		end
	end
end)

