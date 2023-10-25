local localPlayer = game:GetService("Players").LocalPlayer

for i, grabItem in ipairs(workspace.GameInfo.PuzzleItems:GetChildren()) do
	localPlayer.Character:PivotTo(grabItem.CFrame)
	
	repeat
		task.wait(1)
		fireproximityprompt(grabItem.ProximityPrompt)
	until not grabItem:FindFirstChildOfClass("BasePart")
end

localPlayer.Character:PivotTo(workspace.Well.Burner.CFrame)
while true do
	task.wait()
	fireproximityprompt(workspace.Well.Burner.ProximityPrompt)
end