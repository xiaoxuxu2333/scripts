local ReplicatedStorage = game:GetService("ReplicatedStorage")

local petSys = ReplicatedStorage:WaitForChild("PetSys")
local remotes = petSys:WaitForChild("Remotes")
local purchaseSignal = remotes:WaitForChild("PurchaseSignal")
local delete = remotes:WaitForChild("Delete")

local eggName = "Common Egg"

game:GetService("RunService").Heartbeat:Connect(function()
	local array = purchaseSignal:InvokeServer(eggName)

	if array[1] and array[3].Name ~= "Dragon" then
		print("Not a Dragon")
		delete:FireServer({array[3].Id})
	end
end)