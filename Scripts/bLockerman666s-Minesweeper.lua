local parts = workspace.Flag.Parts
local directions = {
	Vector3.new(0, 0, -1),
	Vector3.new(0, 0, 1),
	Vector3.new(-1, 0, 0),
	Vector3.new(1, 0, 0),
	Vector3.new(-1, 0, -1),
	Vector3.new(1, 0, -1),
	Vector3.new(-1, 0, 1),
	Vector3.new(1, 0, 1)
}

while true do
	task.wait(1)
	for i, part in ipairs(parts:GetChildren()) do
		local number = tonumber(part.NumberGui.TextLabel.Text)
		local isSwept = part.Color ~= Color3.fromRGB(117, 205, 100) and part.Color ~= Color3.fromRGB(103, 180, 88)
		
		if number and isSwept then
			for i, direction in ipairs(directions) do
				local parts = workspace:GetPartBoundsInBox(part.CFrame * CFrame.new(direction), part.Size)
				for i = 1, number do
					for i, part in ipairs(parts) do
						local isSwept = part.Color ~= Color3.fromRGB(117, 205, 100) and part.Color ~= Color3.fromRGB(103, 180, 88)
						if not isSwept then
							part.NumberGui.TextLabel.Text = ""
						end
					end
				end
			end
		end
	end
	
	for i, part in ipairs(parts:GetChildren()) do
		local number = tonumber(part.NumberGui.TextLabel.Text)
		local isSwept = part.Color ~= Color3.fromRGB(117, 205, 100) and part.Color ~= Color3.fromRGB(103, 180, 88)
		
		if number and isSwept then
			for i, direction in ipairs(directions) do
				local parts = workspace:GetPartBoundsInBox(part.CFrame * CFrame.new(direction), part.Size)
				for i, part in ipairs(parts) do
					local isSwept = part.Color ~= Color3.fromRGB(117, 205, 100) and part.Color ~= Color3.fromRGB(103, 180, 88)
					if not isSwept then
						part.NumberGui.TextLabel.Text = part.NumberGui.TextLabel.Text == "" and number or tonumber(part.NumberGui.TextLabel.Text) + number
					end
				end
			end
		end
	end
end

