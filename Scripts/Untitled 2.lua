local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

local PlaceId = game.PlaceId
local JobId = game.JobId

local Api = "https://games.roblox.com/v1/games/"

local servers = Api .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"

local Grabable = workspace:WaitForChild("Grabable")

local function ListServers(cursor)
	local Raw = game:HttpGet(servers .. ((cursor and "&cursor="..cursor) or ""))
	return HttpService:JSONDecode(Raw)
end

Grabable.ChildAdded:Connect(function(item)
	task.wait()
	
	local Owner = item:FindFirstChild("Owner")
	
	if item.Name == "PurpleSeed" and Owner and Owner.Value == LocalPlayer then
		item:PivotTo(Character:GetPivot())
	end
end)


local trees = false


for _,v in pairs(game.Workspace:GetDescendants()) do
	if v.Name == "Interact" and v.Parent.Name == "Leaf" then
		trees = true
		---
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://261082034" -- Will play a notification song when it finds, you can change if u want just change the id.
		SoundService:PlayLocalSound(sound)
		----
		v:FireServer()

		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "紫树找到了",
			Color = Color3.new(0.666667, 0, 1)
		})
	end
end

wait(1.5)

if not trees then
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "紫树未找到",
		Color = Color3.new(0.27451, 0.27451, 0.27451)
	})

	while task.wait(5) do
		print("换服中")
		
		coroutine.resume(coroutine.create(function()
			local Next
			repeat
				local Servers = ListServers(Next)
				for i,v in next, Servers.data do
					if v.playing < v.maxPlayers and v.id ~= _id then
						local s,r = pcall(TeleportService.TeleportToPlaceInstance,TeleportService,PlaceId,v.id,LocalPlayer)
						if s then break end
					end
				end

				Next = Servers.nextPageCursor
			until not Next
		end))
	end
end