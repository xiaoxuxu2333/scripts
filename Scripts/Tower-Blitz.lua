local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local events = ReplicatedStorage:WaitForChild("Events")

if game.PlaceId == 4739557376 then
	local startServerFunction = events:WaitForChild("StartServer")
	local updateMapFunction = events:WaitForChild("UpdateMap")
	local updateAttritubesEvent = events:WaitForChild("UpdateAttributes")
	local startGameFunction = events:WaitForChild("StartGame")
		
	startServerFunction:InvokeServer("Solo", "Invite")
	updateMapFunction:InvokeServer("Roundabout")
	updateAttritubesEvent:FireServer("LockTowers")
	updateAttritubesEvent:FireServer("Apocalypse")
	startGameFunction:InvokeServer()
elseif game.PlaceId == 5527929546 then
	local cash = localPlayer:WaitForChild("Cash")
	local voteGamemodeEvent = events:WaitForChild("VoteGamemode")
	local placeTowerFunction = events:WaitForChild("PlaceTower")
	local upgradeTowerFunction = events:WaitForChild("UpgradeTower")
	local towerStorage = ReplicatedStorage:WaitForChild("TowerStorage")
	
	local function PlaceTower(name, position, angle)
		local config = require(towerStorage[tower.Name])
		
		repeat task.wait() until cash.Value >= config.StarterStats.Cost
		
		local newTower = placeTowerFunction:InvokeServer(name, position, angle)
		return newTower
	end
	
	local function UpgradeTower(tower, path)
		local config = require(towerStorage[tower.Name])
		
		repeat task.wait() until cash.Value >= config.UpgradeList["Path" .. path]["Upgrade" .. tower:GetAttritube("Path" .. path .. "Level) + 1].Cost
		
		local newTower = placeTowerFunction:InvokeServer(name, position, angle)
		return newTower
		
		--require(towerStorage[tower.Name]).UpgradeList.Path1.Upgrade1
	end
	
	voteGamemodeEvent:FireServer("Hard")
	repeat task.wait(0.3) until cash.Value >= 600
	local newTower = placeTowerFunction:InvokeServer("Sharpshooter", Vector3.new(-3.823051691055298, 5.1420416831970215, 9.103227615356445), 0)
	repeat task.wait(0.3) until cash.Value >= 180
	newTower = upgradeTowerFunction:InvokeServer(newTower, 1)
	repeat task.wait(0.3) until cash.Value >= 300
	newTower = upgradeTowerFunction:InvokeServer(newTower, 1)
	repeat task.wait(0.3) until cash.Value >= 600
	local newTower2 = placeTowerFunction:InvokeServer("Sharpshooter", Vector3.new(-3.870901107788086, 5.142022609710693, 14.434207916259766), 0)
	repeat task.wait(0.3) until cash.Value >= 180
	newTower2 = upgradeTowerFunction:InvokeServer(newTower2, 1)
	repeat task.wait(0.3) until cash.Value >= 300
	newTower2 = upgradeTowerFunction:InvokeServer(newTower2, 1)
	repeat task.wait(0.3) until cash.Value >= 450
	newTower2 = upgradeTowerFunction:InvokeServer(newTower2, 2)
	repeat task.wait(0.3) until cash.Value >= 500
	newTower2 = upgradeTowerFunction:InvokeServer(newTower2, 2)
	repeat task.wait(0.3) until cash.Value >= 1250
	newTower2 = upgradeTowerFunction:InvokeServer(newTower2, 2)
	repeat task.wait(0.3) until cash.Value >= 1150
	newTower = upgradeTowerFunction:InvokeServer(newTower, 1)
	repeat task.wait(0.3) until cash.Value >= 3000
	newTower2 = upgradeTowerFunction:InvokeServer(newTower2, 2)
	repeat task.wait(0.3) until cash.Value >= 600
	local newTower3 = placeTowerFunction:InvokeServer("Sharpshooter", Vector3.new(-1.5, 6.517041206359863, 11.75), 0)
	repeat task.wait(0.3) until cash.Value >= 180
	newTower3 = upgradeTowerFunction:InvokeServer(newTower3, 1)
	repeat task.wait(0.3) until cash.Value >= 300
	newTower3 = upgradeTowerFunction:InvokeServer(newTower3, 1)
	repeat task.wait(0.3) until cash.Value >= 600
	local newTower4 = placeTowerFunction:InvokeServer("Sharpshooter", Vector3.new(-6.75, 6.517041206359863, 11.75), 0)
	repeat task.wait(0.3) until cash.Value >= 180
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 1)
	repeat task.wait(0.3) until cash.Value >= 300
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 1)
	repeat task.wait(0.3) until cash.Value >= 450
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 2)
	repeat task.wait(0.3) until cash.Value >= 500
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 2)
	repeat task.wait(0.3) until cash.Value >= 500
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 2)
	repeat task.wait(0.3) until cash.Value >= 1250
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 2)
	repeat task.wait(0.3) until cash.Value >= 1150
	newTower3 = upgradeTowerFunction:InvokeServer(newTower3, 1)
	repeat task.wait(0.3) until cash.Value >= 3000
	newTower4 = upgradeTowerFunction:InvokeServer(newTower4, 2)
end
