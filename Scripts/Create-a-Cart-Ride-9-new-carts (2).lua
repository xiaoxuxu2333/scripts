_G.Toggle = true

while _G.Toggle do
	task.wait()
	local driverSeat = game.Players.LocalPlayer.Character.Humanoid.SeatPart
	if not driverSeat then
		continue
	end
	
	local cart = driverSeat.Parent
	local base = cart:FindFirstChild("Base")
	if not base then
		continue
	end
	local baseForce = base:WaitForChild("BaseForce")
	local bodyVelocity = Instance.new("BodyVelocity", driverSeat)
	bodyVelocity.MaxForce = Vector3.zero
	bodyVelocity.P = math.huge
	bodyVelocity.Velocity = Vector3.one * math.huge
	
	while game.Players.LocalPlayer.Character.Humanoid.SeatPart do
		bodyVelocity.MaxForce = (base.CFrame.LookVector * -baseForce.Force) * 10
		task.wait()
	end
end
