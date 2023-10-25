local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local equipEvent = ReplicatedStorage:WaitForChild("Equip")

function Equip(toolName)
	equipEvent:FireServer("EQUIP", toolName)
end

function Unequip(toolName)
	equipEvent:FireServer("UNEQUIP", toolName)
end

Unequip("Trowel")
Equip("Trowel")

local trowel
repeat
	task.wait()
	trowel = localPlayer.Backpack:FindFirstChild("Trowel")
until trowel

trowel.Parent = game.Players.LocalPlayer.Character
trowel.Parent = workspace
