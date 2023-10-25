print("EXECUTING")

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

function breakVelocity(model)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(model:GetDescendants()) do
			if v.IsA(v, "BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end

	local teleportPart = workspace:FindFirstChild("TeleportPart")
	local character = player.Character
	local humanoid = (character ~= nil) and character:FindFirstChild("Humanoid")
	local seatPart = (humanoid ~= nil) and humanoid.SeatPart
	local cart = (seatPart ~= nil) and seatPart.Parent

	if input.KeyCode == Enum.KeyCode.T then
		if (cart ~= nil) and (teleportPart ~= nil) then
			cart:PivotTo(teleportPart.CFrame)
			breakVelocity(cart)
		end
	elseif input.KeyCode == Enum.KeyCode.X then
		if (cart ~= nil) then
			if (teleportPart ~= nil) then
				teleportPart:Destroy()
			end

			local newTeleportPart = Instance.new("Part", workspace)
			newTeleportPart.Name = "TeleportPart"
			newTeleportPart.Anchored = true
			newTeleportPart.CanCollide = false
			newTeleportPart.CFrame = cart:GetPivot()
		end
	end
end)
