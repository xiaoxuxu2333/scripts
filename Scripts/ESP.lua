local players = game:GetService('Players')
local vehicles = workspace:WaitForChild('Vehicles')

local function espVehicle(vehicle)
	local player = players:FindFirstChild(vehicle.Name:sub(8))
	if player == players.LocalPlayer then return end
	local hullNode = vehicle:WaitForChild('HullNode')
	
	local a = Instance.new("BoxHandleAdornment")
	a.Name = player.Name
	a.Parent = hullNode
	a.Adornee = hullNode
	a.AlwaysOnTop = true
	a.ZIndex = 10
	a.Size = hullNode.Size
	a.Transparency = 0.5
	a.Color = player.TeamColor
		
	local BillboardGui = Instance.new("BillboardGui")
	local TextLabel = Instance.new("TextLabel")
	BillboardGui.Adornee = hullNode
	BillboardGui.Name = player.Name
	BillboardGui.Parent = hullNode
	BillboardGui.Size = UDim2.new(0, 100, 0, 150)
	BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
	BillboardGui.AlwaysOnTop = true
	TextLabel.Parent = BillboardGui
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0, 0, 0, -50)
	TextLabel.Size = UDim2.new(0, 100, 0, 100)
	TextLabel.Font = Enum.Font.SourceSansSemibold
	TextLabel.TextSize = 20
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextStrokeTransparency = 0
	TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	TextLabel.Text = 'Name: ' .. player.Name
	TextLabel.ZIndex = 10
end

for i, vehicle in ipairs(vehicles:GetChildren()) do
	task.spawn(function()
		espVehicle(vehicle)
	end)
end

vehicles.ChildAdded:Connect(espVehicle)