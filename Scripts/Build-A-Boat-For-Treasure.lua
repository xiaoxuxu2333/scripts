_G.AutoFarm = true
















































local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local normalStages = workspace:WaitForChild("BoatStages"):WaitForChild("NormalStages")
local claimRiverResultsGoldEvent = workspace:WaitForChild("ClaimRiverResultsGold")

local part = Instance.new("Part")
part.Anchored = true
part.Size = Vector3.new(4, 1, 4)
part.Parent = workspace

local connection = RunService.Heartbeat:Connect(function()
	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local position = localPlayer.Character.HumanoidRootPart.Position
		part.Position = Vector3.new(position.X, 61.5, position.Z)
	end
end)

while _G.AutoFarm do
	for i = 1, 10 do
		local caveStage = normalStages["CaveStage" .. i]
		localPlayer.Character:PivotTo(caveStage.DarknessPart.CFrame)
		task.wait(2)
		--claimRiverResultsGoldEvent:FireServer()
		
		if not _G.AutoFarm then
			break
		end
	end
	
	localPlayer.Character:PivotTo(normalStages.TheEnd.GoldenChest.Trigger.CFrame * CFrame.new(-5, -1.7, 0) * CFrame.Angles(0, math.rad(-90), 0))
	
	if not _G.AutoFarm then
		break
	end
	
	localPlayer.CharacterAdded:Wait()
	task.wait(6)
end

local spawns = workspace[localPlayer.TeamColor.Name .. "Team"].Spawns:GetChildren()
localPlayer.Character:PivotTo(spawns[math.random(#spawns)].CFrame * CFrame.new(0, 3.5, 0))
connection:Disconnect()
part:Destroy()