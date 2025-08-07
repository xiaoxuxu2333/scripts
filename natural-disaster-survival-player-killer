local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local update = RunService.Heartbeat:Connect(function()
    -- LocalPlayer.ReplicationFocus = workspace
    sethiddenproperty(LocalPlayer, "SimulationRadius", 2000)
end)

local function getPlayers()
    local players = game.Players:GetPlayers()
    table.remove(players, table.find(players, LocalPlayer))

    for _, player in players do
        if player.Character == nil or player.Character:FindFirstChild("Humanoid") == nil or player.Character.Humanoid.Health <= 0 or player.Character:FindFirstChild("HumanoidRootPart") == nil or player.Character.HumanoidRootPart.Velocity.Magnitude > 100 or player.Character.HumanoidRootPart.Position.Magnitude > 2000 then
            table.remove(players, table.find(players, player))
        end
    end

    return players
end

local random = Random.new()

local parts = {}

local disconnected = Instance.new("BindableEvent")

local anchoredParts = {}

local function onPartAdded(part)
    if part:IsA("BasePart") then
        task.wait(0.5)
        repeat
            task.wait()
        until (part.AssemblyRootPart and part.AssemblyRootPart.Anchored == false) or not part.Parent

        local ap = Instance.new("AlignPosition")
        local att = Instance.new("Attachment", part)
        local bav = Instance.new("BodyAngularVelocity")
        local bf = Instance.new("BodyForce")

        ap.Attachment0 = att
        ap.Responsiveness = 20
        ap.MaxForce = 10000000
        ap.MaxVelocity = 500
        ap.Parent = part

        bav.MaxTorque = Vector3.one * 1000000000
        bav.AngularVelocity = Vector3.yAxis * 1000
        bav.Parent = part

        bf.Force = Vector3.new(0, part:GetMass() * workspace.Gravity, 0)
        bf.Parent = part

        part.CanCollide = false

        table.insert(parts, part)
    end
end

local function onPartRemoved(part)
    if part:IsA("BasePart") then
        table.remove(parts, table.find(parts, part))
    end
end

for _, part in workspace.Structure:GetDescendants() do
    if part:IsA("BasePart") then
        task.spawn(onPartAdded, part)
    end
end

workspace.Structure.DescendantAdded:Connect(onPartAdded)
workspace.Structure.DescendantRemoving:Connect(onPartRemoved)

while task.wait() do
    local players = getPlayers()

    local count = 0
    for _, v in parts do
        count += 1
        local ap = v:FindFirstChild("AlignPosition")
        if not ap then continue end
        local char = players[(count % #players) + 1].Character
        ap.Attachment1 = char and char:FindFirstChild("RootAttachment", true)
        v.Velocity += random:NextUnitVector() * 100
        local t = tick() + count * 10
        ap.Attachment0.Position = Vector3.new(math.cos(t) * v.Size.X / 2, 0, math.sin(t) * v.Size.Z / 2)
    end

    for _, v in workspace.Island:GetDescendants() do
        if v:IsA("BasePart") then
            v.Velocity = Vector3.zero
        end
    end
end
