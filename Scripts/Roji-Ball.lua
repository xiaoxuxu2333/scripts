local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local status = ReplicatedStorage:WaitForChild("Status")

local localPlayer = Players.LocalPlayer

local marker = workspace:WaitForChild("Marker")

localPlayer.PlayerGui.Cmdr:Destroy()

game:GetService("RunService").Heartbeat:Connect(function()
	local networkPing = localPlayer:GetNetworkPing()
	local ball = marker:FindFirstChild("Ball")
	if ball and status.Target.Value == localPlayer.Character then
		print("incoming")
		
		if (ball.PrimaryPart.Position - localPlayer.Character.PrimaryPart.Position).Magnitude < 25 * (networkPing + 1) then
			print("swing")
			for i, v in ipairs(getconnections(localPlayer.PlayerGui.MainUI.SwingButton.Activated)) do
				v:Fire()
			end
		end
	end
end)
