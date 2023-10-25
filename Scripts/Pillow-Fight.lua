local localPlayer = game:GetService("Players").LocalPlayer

localPlayer.CharacterAdded:Connect(function(character)
	character:WaitForChild("Ragdoll"):Destroy()
	character:WaitForChild("HumanoidRootPart").ChildAdded:Connect(function(child)
		task.wait()
		child:Destroy()
	end)
end)