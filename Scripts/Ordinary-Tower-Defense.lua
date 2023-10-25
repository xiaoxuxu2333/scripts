for _, tower in ipairs(game.ReplicatedStorage.Towers:GetChildren()) do
	local config = tower:FindFirstChild("Config")
	if config then
		print(tower.Name, "$" .. config.Price.Value)
	end
end

