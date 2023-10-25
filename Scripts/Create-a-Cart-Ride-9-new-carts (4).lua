local function characterAdded(character)
	local function seated(active, currentSeatPart)
		if active then
			local cart = currentSeatPart.Parent
			cart.DamagePart.Touched:Connect(function(otherPart)
				if otherPart.Name == "Rail" then
					game.ReplicatedStorage.Events.ChangeCartColor:FireServer("Neon", otherPart.Color)
				end
			end)
		end
	end
	
	character:WaitForChild("Humanoid").Seated:Connect(seated)
end

characterAdded(game.Players.LocalPlayer.Character)
game.Players.LocalPlayer.CharacterAdded:Connect(characterAdded)