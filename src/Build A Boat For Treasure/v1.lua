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
	
	local status = {
		["每分钟赚钱"] = "0",
	}
	
	local text = Drawing.new("Text")
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Color = Color3.new(1, 1, 1)
	text.Center = false
	text.Position = Vector2.new(50, 50)
	text.Text = ""
	text.Visible = true
	
	local oldFunction
	oldFunction = hookmetamethod(game, "__namecall", function(self, ...)
		if self == claimRiverResultsGoldEvent and not checkcaller() and getnamecallmethod() == "FireServer" then
			return
		end
		
		return oldFunction(self, ...)
	end)
	
	local oldGold = localPlayer.Data.Gold.Value
	local timer = 0
	local root = localPlayer.Character.HumanoidRootPart
	local starterCFrame = root.CFrame
	local anchoredCFrame = starterCFrame
	local unlockChest
	local update = RunService.Heartbeat:Connect(function()
		root.CFrame = anchoredCFrame
		root.AssemblyLinearVelocity = Vector3.zero
		
		if unlockChest and root.Parent then
			firetouchinterest(normalStages.TheEnd.GoldenChest.Trigger, root, 0)
		end
		
		local t = time()
		if t - timer > 60 then
			timer = t
			status["每分钟赚钱"] = tostring(localPlayer.Data.Gold.Value - oldGold)
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
	
	local characterAdded = localPlayer.CharacterAdded:Connect(function(newChar)
		root = newChar:WaitForChild("HumanoidRootPart")
	end)
	
	while goldFarming do
	    local startTime = time()
		local char = localPlayer.Character
		
		for i = 1, 10 do
			if i == 4 then
				unlockChest = true
			elseif i == 10 then
			    claimRiverResultsGoldEvent:FireServer()
			end
			
			local caveStage = normalStages["CaveStage" .. i]
			anchoredCFrame = caveStage.DarknessPart.CFrame
			do
				local duration = 2
				while duration > 0 and goldFarming do
					duration -= task.wait()
				end
			end
		end
		
		if not goldFarming then break end
		
		local newChar = localPlayer.Character ~= char or localPlayer.CharacterAdded:Wait()
		unlockChest = nil
		anchoredCFrame = starterCFrame
		do
			local duration = 5
			while duration > 0 and goldFarming do
				duration -= task.wait()
			end
		end
		status["此次用时时间"] = tostring(math.floor(time() - startTime)) .. "秒"
	end
	
	hookmetamethod(game, "__namecall", oldFunction)
	update:Disconnect()
	characterAdded:Disconnect()
	text:Destroy()
end)
