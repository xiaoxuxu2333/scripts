local LocalPlayer = game.Players.LocalPlayer
local ResetStuds = game.ReplicatedStorage.ResetStuds
LocalPlayer:RequestStreamAroundAsync(Vector3.new(23.17, 5, -127023))

local burger = workspace:WaitForChild("burger")
local win = burger.ProximityPrompt

coroutine.wrap(function()
	while true do
		task.wait()
		win.HoldDuration = 0
		fireproximityprompt(win)
	end
end)()

game.GuiService.ErrorMessageChanged:Connect(function()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

while true do
	LocalPlayer.Character:MoveTo(burger.Position)
	task.wait(0.3)
	ResetStuds:FireServer()
	task.wait(0.05)
end
