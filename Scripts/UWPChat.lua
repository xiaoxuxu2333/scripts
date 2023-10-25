local TEXT = ""
local CHANNEL = "All"

local args = {
    [1] = TEXT,
    [2] = CHANNEL
}

local DefaultChatSystemChatEvents = game.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")

if DefaultChatSystemChatEvents then
	DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
end
