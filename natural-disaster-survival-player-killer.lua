local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local update = RunService.Heartbeat:Connect(function()
    -- LocalPlayer.ReplicationFocus = workspace
    sethiddenproperty(LocalPlayer, "SimulationRadius", 2000)
end)

local function getPlayers()
    local players = {}

    for _, player in game.Players:GetPlayers() do
        local me = player == LocalPlayer
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = hum and hum.RootPart
        local dying = hum and hum.Health <= 0 and root and root.Parent and (root.Position.Magnitude > 1000 or root.Velocity.Magnitude > 100 or root.Position.Y < 0)

        if not me and char and hum and root and not dying then
            table.insert(players, player)
        end
    end

    return players
end

local random = Random.new()

local parts = Instance.new("Folder")
parts.Name = "Parts"
parts.Parent = workspace

local queue = {}

local function onPartAdded(part)
    if part:IsA("BasePart") then
        if part:FindFirstAncestor(workspace.ContentModel.Information.Value) then
            task.wait(5)

            local event = Instance.new("BindableEvent")

            queue[part] = event

            event.Event:Wait()
            event:Destroy()
        else
            wait()
        end

        if not part.Parent or part.Anchored then return end

        part.Parent = parts
    end
end

for _, part in workspace.Structure:GetDescendants() do
    if part:IsA("BasePart") then
        task.spawn(onPartAdded, part)
    end
end

workspace.Structure.DescendantAdded:Connect(onPartAdded)

while RunService.Heartbeat:Wait() do
    for part, event in queue do
        if (part.AssemblyRootPart and part.AssemblyRootPart.Anchored == false) or not part.Parent then
            event:Fire()
            queue[part] = nil
        end
    end

    for _, v in workspace.Island:GetDescendants() do
        if v:IsA("BasePart") then
            v.Velocity = Vector3.zero
        end
    end

    local players = getPlayers()

    for i, part in parts:GetChildren() do
        local char = players[(i % #players) + 1].Character
        local t = tick() + i * 10

        if char and char:FindFirstChild("HumanoidRootPart") then
            part.Velocity = ((char.HumanoidRootPart.Position - part.Position).Unit * 1000) + Vector3.new(math.cos(t) * part.Size.X / 2, 0, math.sin(t) * part.Size.Z / 2)
        else
            part.Velocity = Vector3.zero
        end

        part.CanCollide = false
        part.CanTouch = false
    end

    for _, v in workspace.Island:GetDescendants() do
        if v:IsA("BasePart") then
            v.Velocity = Vector3.zero
        end
    end
end
