local players = game:GetService("Players")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local character = player.character
local mouse = player:GetMouse()

local function bombThrow()
	for _ = 1, 10 do
		game.ReplicatedStorage.Remote.Bomb.BombThrow:Fire(
			player, 
			character.Bomb.Primary, 
			mouse.Hit.Position,
			Vector3.zero
		)
	end
end

mouse.Button1Down:Connect(function()
	runService:UnbindFromRenderStep("BombThrow")
	runService:BindToRenderStep("BombThrow", 1, bombThrow)
end)
mouse.Button1Up:Connect(function()
	runService:UnbindFromRenderStep("BombThrow")
end)

