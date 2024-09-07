local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local normalStages = workspace:WaitForChild("BoatStages"):WaitForChild("NormalStages")
local claimRiverResultsGoldEvent = workspace:WaitForChild("ClaimRiverResultsGold")

local stagesData = {}
for _, data in localPlayer.OtherData:GetChildren() do
	if data.Name:match("Stage%d+") then
		stagesData[tonumber(data.Name:match("%d+"))] = data
	end
end

local UI = loadstring(game:HttpGet("https://gitee.com/xiaoxuxu233/mirror/raw/master/wizard.lua"))()
local window = UI:NewWindow("Unnamed")
local main = window:NewSection("主要功能")

main:CreateToggle("自动刷钱", function(enabled)
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
	
	local oldGold = localPlayer.Data.Gold.Value
	local timer = 0
	local root = localPlayer.Character.HumanoidRootPart
	local unlockChest, characterAdded
	local update = RunService.Heartbeat:Connect(function()
		if unlockChest and root.Parent then
			firetouchinterest(normalStages.TheEnd.GoldenChest.Trigger, root, 0)
		end
		
		local t = time()
		if t - timer > 60 then
			timer = t
			status["每分钟金条"] = localPlayer.Data.Gold.Value - oldGold
			status["每小时金条"] = (localPlayer.Data.Gold.Value - oldGold) * 60
			oldGold = localPlayer.Data.Gold.Value
		end
		
		for i = 1, #stagesData do
			status[i] = stagesData[i].Value
		end
		
		local info = ""
		for stat, value in status do
			info = info .. string.format("%s: %s\n", stat, value)
		end
		text.Text = info
	end)
	
	local connections = {}
	
	table.insert(connections, localPlayer.CharacterAdded:Connect(function(newChar)
		root = newChar:WaitForChild("HumanoidRootPart")
		platform.CFrame = normalStages.CaveStage1.DarknessPart.CFrame
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
		
		for i = 1, 10 do
			if i == 2 then
			    task.delay(1.5, function()
				    unlockChest = true
				end)
			elseif i == 10 then
			    claimRiverResultsGoldEvent:FireServer()
			end
			
			local caveStage = normalStages["CaveStage" .. i]
			platform.CFrame = caveStage.DarknessPart.CFrame
			root.CFrame = platform.CFrame * CFrame.new(0, 10, 0)
			do
				local duration = 2
				while duration > 0 and goldFarming do
					duration -= task.wait()
				end
			end
			status["此次用时时间"] = nil
		end
		
		if not goldFarming then break end
		do
			local duration = 3.15
			while duration > 0 and goldFarming do
				duration -= task.wait()
			end
		end
		status["此次用时时间"] = string.format("%.4f秒", time() - startTime)
	end
	
	update:Disconnect()
	for _, connection in connections do
	    connection:Disconnect()
	end
	text:Destroy()
	platform:Destroy()
end)
