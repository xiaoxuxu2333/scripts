local debounce = false

local zones = {
	BasementClose = "地下室",
	BasementFar = "地下室",
	BasementStairs = "地下室",
	DiningRoom = "餐厅",
	Foyer = "门口",
	Garage = "车库",
	Kitchen = "厨房",
	LivingRoom = "客厅",
	Nursery = "婴儿室",
	OutsideBasement = "地下室",
	Outside = "门口",
	Bathroom1 = "卫生间",
	Bathroom2 = "卫生间",
	Bedroom1 = "卧室",
	Bedroom2 = "卧室",
	Corridor2 = "走廊",
	Corridor3 = "走廊",
}

workspace.Map.Orbs.ChildAdded:Connect(function(orb)
	task.wait()
	print("幽灵宝珠")
	game.Players:Chat("幽灵宝珠")
end)
workspace.Map.Prints.ChildAdded:Connect(function(fingerprint)
	print("指纹")
	game.Players:Chat("指纹")
end)
for _, zone in ipairs(workspace.Map.Zones:GetChildren()) do
	zone:WaitForChild("EMF").Changed:Connect(function(value)
		if value == 5 then
			print("电磁场等级5")
			game.Players:Chat("电磁场等级5")
		end
	end)
	if zone:FindFirstChild("Temperature") then
		zone.Temperature.Changed:Connect(function(value)
			if value < 0 then
				if not debounce then
					debounce = true
					print("冰冻温度")
					game.Players:Chat("冰冻温度")
					task.wait(10)
					debounce = false
				end
			end
		end)
	end
end
workspace.ChildAdded:Connect(function(child)
	task.wait()
	if child.Name == "Ghost" then
		local highlight = Instance.new("Highlight", child)
		game.Players:Chat("鬼来了")
	end
end)
workspace.ChildRemoved:Connect(function(child)
	task.wait()
	if child.Name == "Ghost" then
		local highlight = Instance.new("Highlight", child)
		game.Players:Chat("鬼没了")
	end
end)
