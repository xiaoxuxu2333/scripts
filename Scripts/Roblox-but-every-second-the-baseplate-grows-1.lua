task.wait(5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local placeId = game.PlaceId

RunService.Heartbeat:Connect(function()
	for i, coin in ipairs(workspace:WaitForChild("CoinStorage"):GetChildren()) do
		coin.CFrame = Players.LocalPlayer.Character:GetPivot()
	end
end)

for i = 60, 1, -1 do
	print(i)
	task.wait(1)
end

while task.wait() do
	if httprequest then
		local servers = {}
		local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", placeId)})
		local body = HttpService:JSONDecode(req.Body)
		if body and body.data then
			for i, v in next, body.data do
				if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
					table.insert(servers, 1, v.id)
				end
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], Players.LocalPlayer)
		else
			print("Serverhop", "Couldn't find a server.")
		end
	end
end
