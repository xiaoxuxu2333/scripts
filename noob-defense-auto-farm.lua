game:GetService("ReplicatedStorage")
game.ReplicatedStorage:WaitForChild("Functions")
game.ReplicatedStorage:WaitForChild("Events")

local Place = game.ReplicatedStorage.Functions:WaitForChild("SpawnTower")
local Sell = game.ReplicatedStorage.Functions:WaitForChild("SellTower")
local SpeedUpGame = game.ReplicatedStorage.Events:WaitForChild("SpeedUpGame")
local VoteForMap = game.ReplicatedStorage.Events:WaitForChild("VoteForMap")
local EndScreen = game.ReplicatedStorage.Events:WaitForChild("EndScreen")
local ReplayGame = game.ReplicatedStorage.Events:WaitForChild("ReplayGame")

local function place(name, pos, upgrade)
    return Place:InvokeServer(name, CFrame.new(pos), upgrade)
end

local function upgrade(tower, pos)
	local maxLvl = tower

	if maxLvl.Config:FindFirstChild("Upgrade") then
		repeat
			maxLvl = maxLvl.Config.Upgrade.Value
		until not maxLvl.Config:FindFirstChild("Upgrade")

		return place(maxLvl.Name, pos, tower)
	end
end

local function move(tower, pos)
	return place(tower.Name, pos, tower)
end

local toPlaces = {
	"Sakura Samurai Noob",
	"Upgrade Engineer Noob",
    "Fallen Devil Noob",
    "Fallen Angel Noob", 
    -- "Gladiator Angel Noob", 
    -- "Gladiator Angel Noob",
	-- "Bassist Noob",
	"King of the Empire Noob",
}

local toPlaces = {
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"HENNIM7878",
	"Destiny Noob"
}

local waypoints = workspace:FindFirstChild("Waypoints", true)
while not waypoints do
	workspace.DescendantAdded:Wait()
	waypoints = workspace:FindFirstChild("Waypoints", true)
end
local waypoint = waypoints:WaitForChild("1")
for i = 1, 3 do
	waypoint:WaitForChild(i)
end
local start = 1

local function moveAllTowers(pos)
	for _, tower in workspace.Towers:GetChildren() do
		if tower:IsA("Script") then continue end
		task.spawn(move, tower, pos)
	end
end

local function placeTowers()
	local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)

	for _, name in toPlaces do
		task.spawn(function()
			local t = place(
				name,
				pos
				-- Vector3.new(-10, 1.23, 4)
			)
			if t then
				upgrade(t, pos)
			end
		end)
		task.wait()
	end
end

SpeedUpGame:FireServer()
SpeedUpGame:FireServer()
SpeedUpGame:FireServer()
VoteForMap:FireServer("Insane")
placeTowers()

-- for _, v in workspace:GetChildren() do
--     pcall(v.Destroy, v)
-- end

-- for _, v in game.Players.LocalPlayer.PlayerScripts:GetChildren() do
--     pcall(v.Destroy, v)
-- end

-- for _, v in game.Players.LocalPlayer.PlayerGui:GetChildren() do
--     pcall(v.Destroy, v)
-- end

task.spawn(function()
	local boss = workspace.Mobs:WaitForChild("King Samurai Zombie", 9e9)

	local conn
	conn = boss:WaitForChild("MovingTo").Changed:Connect(function(t)
		if t > 0.6 then
			moveAllTowers(Vector3.new(49, 1.23, 14))
			conn:Disconnect()
		end
	end)
end)

task.spawn(function()
	local boss = workspace.Mobs:WaitForChild("Fallen God Angel", 9e9)

	local conn
	conn = boss:WaitForChild("MovingTo").Changed:Connect(function(t)
		if t > 0.4535955343045658 then
			if start == 9 then return end
			start = 9
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
			conn:Disconnect()
		elseif t > 0.3850687568095433 then
			if start == 8 then return end
			start = 8
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		elseif t > 0.3429635408638993 then
			if start == 7 then return end
			start = 7
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		elseif t > 0.3006385834523465 then
			if start == 6 then return end
			start = 6
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		elseif t > 0.22698317259997966 then
			if start == 5 then return end
			start = 5
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		elseif t > 0.2 then
			if start == 4 then return end
			start = 4
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		elseif t > 0.1 then
			if start == 3 then return end
			start = 3
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		elseif t > 0.086 then
			if start == 2 then return end
			start = 2
			local pos = (waypoint[start].Position + (waypoint[start + 1].Position - waypoint[start].Position) / 3) + Vector3.new(0, 0, 0)
			moveAllTowers(pos)
		end
	end)
end)

EndScreen.OnClientEvent:Wait()
ReplayGame:FireServer()
