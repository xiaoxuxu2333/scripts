local plr = game.Players.LocalPlayer
local events = game.ReplicatedStorage:WaitForChild("Events")

local function GetRing()
	for i, ring in ipairs(workspace:GetChildren()) do
		if ring.Name == "Ring" and (ring.Player2.Value == plr or ring.Player1.Value == plr) then
			return ring
		end
	end
end

local ring = GetRing()

if ring then
	local connection
	connection = ring.Prompt.BillboardGui.TextLabel.Changed:Connect(function()
		if GetRing() ~= ring then
			connection:Disconnect()
			return
		end
		
		local question = string.split(ring.Prompt.BillboardGui.TextLabel.Text, " ")
	
		local number1 = question[1]
		local algorithm = question[2]
		local number2 = question[3]
		
		local answer
		
		if algorithm == "+" then
			answer = number1 + number2
		else
			answer = number1 * number2
		end
		
		events.Answer:FireServer(answer)
	end)
end