local front = false
local back = false

game.UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Z then
		front = true
		while front do
			task.wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame += game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector / 2
		end
	elseif input.KeyCode == Enum.KeyCode.C then
		back = true
		while back do
			task.wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame -= game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector / 2
		end
	end
end)

game.UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Z then
		front = false
	elseif input.KeyCode == Enum.KeyCode.C then
		back = false
	end
end)

