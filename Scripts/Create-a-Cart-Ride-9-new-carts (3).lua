local colorPart = Instance.new("Part")

coroutine.wrap(function()
	while true do
		game.TweenService:Create(colorPart, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Color = Color3.new(1, 0, 0)}):Play()
		wait(1)
		game.TweenService:Create(colorPart, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Color = Color3.new(0, 1, 0)}):Play()
		wait(1)
		game.TweenService:Create(colorPart, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Color = Color3.new(0, 0, 1)}):Play()
		wait(1)
	end
end)()

while true do
	local args = {
	    [1] = "Glass",
	    [2] = colorPart.Color
	}
	
	game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ChangeCartColor"):FireServer(unpack(args))
	task.wait()
end