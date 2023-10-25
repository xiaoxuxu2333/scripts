local bindableEvent = Instance.new("BindableEvent")

bindableEvent.Event:Connect(function()
	game.ReplicatedStorage.Communication.SailEvents.RequestLaunch:FireServer(0)
	game.ReplicatedStorage.Communication.SailEvents.ClientFinishedLaunch:FireServer()
end)

for _ = 1, 1000 do
	bindableEvent:Fire()
end
