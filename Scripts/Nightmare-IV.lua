local localPlayer = game:GetService("Players").LocalPlayer

for i, butterfly in ipairs(workspace.Butterflies:GetChildren()) do
	localPlayer.Character:PivotTo(butterfly.CFrame)
	repeat
		task.wait()
		fireproximityprompt(butterfly.ProximityPrompt)
	until not butterfly.Parent or not butterfly:FindFirstChild("ProximityPrompt")
end