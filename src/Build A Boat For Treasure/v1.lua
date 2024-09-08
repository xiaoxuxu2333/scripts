local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local goldBlock = localPlayer:WaitForChild("Data"):WaitForChild("GoldBlock")
local gold = localPlayer.Data:WaitForChild("Gold")

local claimRiverResultsGoldEvent = workspace:WaitForChild("ClaimRiverResultsGold")
local stagePositions = {}
local chestTrigger, chestTriggerOriginCFrame

for _, stage in workspace:WaitForChild("BoatStages"):WaitForChild("NormalStages"):GetChildren() do
	local index = tonumber(stage.Name:match("%d+"))
	if index then
		stagePositions[index] = stage.DarknessPart.CFrame
	end
	if stage.Name == "TheEnd" then
		chestTrigger = stage.GoldenChest.Trigger
		chestTriggerOriginCFrame = chestTrigger.CFrame
	end
end

local stagesData = {}
for _, data in localPlayer.OtherData:GetChildren() do
	if data.Name:match("Stage%d+") then
		stagesData[tonumber(data.Name:match("%d+"))] = data
	end
end

local UI = loadstring(game:HttpGet("https://gitee.com/xiaoxuxu233/mirror/raw/master/wizard.lua"))()
local window = UI:NewWindow("Unnamed")
local main = window:NewSection("主要功能")

main:CreateToggle("自动刷金条&块", function(enabled)
	goldFarming = enabled
	if not goldFarming then return end

	local status = {}

	local text = Drawing.new("Text")
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Color = Color3.new(1, 1, 1)
	text.Center = false
	text.Position = Vector2.new(50, 50)
	text.Text = ""
	text.Visible = true

	local platform = Instance.new("Part")
	platform.Anchored = true
	platform.Size = Vector3.new(4, 1, 4)
	platform.Parent = workspace

	local oldGold = gold.Value
	local timer = 0
	local root = localPlayer.Character.HumanoidRootPart
	local unlockChest, characterAdded
	local connections = {}

	table.insert(connections, RunService.Heartbeat:Connect(function()
		if unlockChest and root.Parent then
			chestTrigger.CFrame = root.CFrame
			--firetouchinterest(chestTrigger, root, 0)
		else
			chestTrigger.CFrame = chestTriggerOriginCFrame
		end
		
		local t = time()
		if t - timer > 60 then
			timer = t
			status["每分钟金条"] = gold.Value - oldGold
			status["每小时金条"] = (gold.Value - oldGold) * 60
			oldGold = gold.Value
		end
		
		for i = 1, #stagesData do
			status[i] = stagesData[i].Value
		end
		
		local info = ""
		for stat, value in status do
			info = info .. string.format("%s: %s\n", stat, value)
		end
		text.Text = info
	end))

	table.insert(connections, localPlayer.CharacterAdded:Connect(function(newChar)
		root = newChar:WaitForChild("HumanoidRootPart")
		platform.CFrame = stagePositions[1]
		root.CFrame = platform.CFrame * CFrame.new(0, 10, 0)
	end))

	table.insert(connections, localPlayer.PlayerGui.ChildAdded:Connect(function(newGui)
		if newGui.Name == "RiverResultsGui" then
			newGui:WaitForChild("LocalScript").Enabled = false
		end
	end))

	table.insert(connections, game.Lighting.Changed:Connect(function()
		if game.Lighting.FogEnd < 100000 then
			unlockChest = nil
		end
	end))

	while goldFarming do
		local startTime = time()
		local char = localPlayer.Character
		
		for i = 1, 9 do
			if not goldFarming then break end
			if i == 3 then
				task.delay(0.5, function()
					unlockChest = true
				end)
			end
			
			platform.CFrame = stagePositions[i]
			root.CFrame = platform.CFrame * CFrame.new(0, 10, 0)
			task.wait(i ~= 1 and 2 or 7.6)
		end

		while unlockChest and goldFarming do
			task.wait()
		end
		claimRiverResultsGoldEvent:FireServer()

		status["用时时间"] = string.format("%.4f秒", time() - startTime)
	end

	for _, connection in connections do
		connection:Disconnect()
	end
	text:Destroy()
	platform:Destroy()
	chestTrigger.CFrame = chestTriggerOriginCFrame
end)

main:CreateToggle("自动刷金块", function(enabled)
	goldBlockFarming = enabled
	if not goldBlockFarming then return end

	local status = {}

	local text = Drawing.new("Text")
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Color = Color3.new(1, 1, 1)
	text.Center = false
	text.Position = Vector2.new(50, 50)
	text.Text = ""
	text.Visible = true

	local platform = Instance.new("Part")
	platform.Anchored = true
	platform.Size = Vector3.new(4, 1, 4)
	platform.Parent = workspace

	local oldGold = goldBlock.Value
	local timer = 0
	local root = localPlayer.Character.HumanoidRootPart
	local characterAdded

	local connections = {}

	table.insert(connections, localPlayer.CharacterAdded:Connect(function(newChar)
		root = newChar:WaitForChild("HumanoidRootPart")
		platform.CFrame = stagePositions[1]
		root.CFrame = platform.CFrame * CFrame.new(0, 10, 0)
	end))

	table.insert(connections, localPlayer.PlayerGui.ChildAdded:Connect(function(newGui)
		if newGui.Name == "RiverResultsGui" then
			newGui:WaitForChild("LocalScript").Enabled = false
		end
	end))

	platform.CFrame = stagePositions[1]
	root.CFrame = platform.CFrame * CFrame.new(0, 10, 0)
	task.wait(7.6)

	table.insert(connections, RunService.Heartbeat:Connect(function()
		if root.Parent then
			chestTrigger.CFrame = root.CFrame
			--firetouchinterest(chestTrigger, root, 0)
		end
		
		local t = time()
		if t - timer > 60 then
			timer = t
			status["每分钟金块"] = goldBlock.Value - oldGold
			status["每小时金块"] = (goldBlock.Value - oldGold) * 60
			oldGold = goldBlock.Value
		end
		
		local info = ""
		for stat, value in status do
			info = info .. string.format("%s: %s\n", stat, value)
		end
		text.Text = info
	end))
	
	while goldBlockFarming do
		task.wait()
	end

	for _, connection in connections do
		connection:Disconnect()
	end
	text:Destroy()
	platform:Destroy()
	chestTrigger.CFrame = chestTriggerOriginCFrame
end)
